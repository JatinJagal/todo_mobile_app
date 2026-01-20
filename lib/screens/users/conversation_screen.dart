import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:todo_app/models/message_model.dart';
import 'package:todo_app/providers/message_cubit/message_cubit.dart';
import 'package:todo_app/providers/message_cubit/message_state.dart';
import 'package:todo_app/providers/user_profile_cubit/user_profile_cubit.dart';
import 'package:todo_app/providers/user_profile_cubit/user_profile_state.dart';
import 'package:todo_app/services/local_storage_service.dart';
import 'package:todo_app/services/socket_service.dart';
import 'package:todo_app/utils/colors.dart';
import 'package:todo_app/utils/consts.dart';
import 'package:todo_app/utils/global.dart';
import 'package:todo_app/widgets/message_bubble.dart';

class ConversationScreen extends StatefulWidget {
  final int receiverId;
  final String receiverName;
  final String? receiverImage;

  const ConversationScreen({
    super.key,
    required this.receiverId,
    required this.receiverName,
    this.receiverImage,
  });

  @override
  State<ConversationScreen> createState() => _ConversationScreenState();
}

class _ConversationScreenState extends State<ConversationScreen>
    with WidgetsBindingObserver {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final SocketService _socketService = SocketService(); // Singleton instance
  StreamSubscription? _messageSubscription;
  int? _currentUserId;
  String? _currentUserImage;
  int _offset = 0;
  final int _limit = 20;
  bool _hasMarkedAsRead = false;
  bool _isSyncing = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeUser();
    _loadConversation();
    _setupSocket();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      // Refresh conversation when app comes to foreground
      _syncConversation();
      // Ensure socket is connected
      _ensureSocketConnected();
    }
  }

  Future<void> _ensureSocketConnected() async {
    if (!_socketService.isConnected) {
      print('ConversationScreen: Socket not connected, reconnecting...');
      final token = await LocalStorageService.i.getStorageValue(kToken);
      if (token.isNotEmpty) {
        _socketService.connect(token);
      }
    }
  }

  void _initializeUser() {
    final profileState = context.read<UserProfileCubit>().state;
    if (profileState is UserProfileSuccess) {
      _currentUserId = profileState.data.data?.user?.id;
      _currentUserImage = profileState.data.data?.user?.userImage;
    }
  }

  void _loadConversation() {
    context.read<ConversationCubit>().getConversation(
      widget.receiverId,
      limit: _limit,
      offset: _offset,
    );
  }

  void _markMessagesAsRead() {
    // Mark messages from the receiver as read (only once)
    if (!_hasMarkedAsRead) {
      _hasMarkedAsRead = true;
      context.read<MarkReadCubit>().markMessageRead(widget.receiverId);
    }
  }

  void _setupSocket() async {
    final token = await LocalStorageService.i.getStorageValue(kToken);
    if (token.isEmpty) {
      print('ConversationScreen: No token available for socket connection');
      return;
    }

    print('ConversationScreen: Setting up WebSocket connection...');
    print('ConversationScreen: Current connection state: ${_socketService.isConnected}');

    // Connect socket (singleton, so it won't create multiple connections)
    _socketService.connect(token);

    // Wait a bit for connection to establish and verify connection
    await Future.delayed(Duration(milliseconds: 2000));

    if (!_socketService.isConnected) {
      print('ConversationScreen: ⚠️ Socket not connected after delay, will retry...');
      // Retry connection
      Future.delayed(Duration(seconds: 2), () {
        if (mounted && !_socketService.isConnected) {
          print('ConversationScreen: Retrying WebSocket connection...');
          _socketService.connect(token);
        }
      });
    } else {
      print('ConversationScreen: ✅ Socket connected successfully');
    }

    // Cancel existing subscription if any
    _messageSubscription?.cancel();
    _messageSubscription = null;
    
    print('ConversationScreen: Setting up message stream subscription...');
    
    // Set up new subscription to WebSocket stream
    _messageSubscription = _socketService.messageStream.listen(
      (data) {
        if (!mounted) {
          print('ConversationScreen: ⚠️ Received message but widget not mounted');
          return;
        }

        print('ConversationScreen: 📨 Received WebSocket data');
        print('ConversationScreen: Data keys: ${data.keys.toList()}');
        print('ConversationScreen: Full data: $data');

        // Get event type from the data (check multiple possible fields)
        final eventType = data['event_type'] ?? 
                         data['type'] ?? 
                         data['event'] ?? 
                         data['eventType'];

        print('ConversationScreen: ✅ Event type detected: $eventType');
        
        // Handle different WebSocket events based on backend structure
        if (eventType == 'conversation_updated') {
          // Handle conversation update - backend sends full conversation data
          print('ConversationScreen: Handling conversation_updated event');
          _handleConversationUpdated(data);
        } else if (eventType == 'receive_message') {
          // Handle new message received
          print('ConversationScreen: Handling receive_message event');
          _handleIncomingMessage(data);
        } else if (eventType == 'messages_read') {
          // Handle messages read event
          print('ConversationScreen: Handling messages_read event');
          _handleMessagesRead(data);
        } else {
          // Fallback: try to handle as message if it has message structure
          // This handles cases where the backend sends messages without explicit event type
          if (data.containsKey('message') || 
              data.containsKey('sender_id') || 
              data.containsKey('receiver_id') ||
              data.containsKey('senderId') ||
              data.containsKey('receiverId') ||
              (data.containsKey('data') && data['data'] is Map)) {
            print('ConversationScreen: Handling as message (no explicit event type)');
            _handleIncomingMessage(data);
          } else {
            print('ConversationScreen: ⚠️ Unknown event type or structure: $data');
          }
        }
      },
      onError: (error) {
        print('ConversationScreen: ❌ WebSocket stream error: $error');
        // Try to reconnect
        if (mounted) {
          Future.delayed(Duration(seconds: 2), () async {
            if (mounted) {
              final token = await LocalStorageService.i.getStorageValue(kToken);
              if (token.isNotEmpty && mounted) {
                _socketService.connect(token);
              }
            }
          });
        }
      },
      cancelOnError: false, // Don't cancel on error, keep listening
    );
  }

  void _handleIncomingMessage(Map<String, dynamic> data) {
    try {
      print('ConversationScreen: Processing incoming message data: $data');
      
      // Handle if data is wrapped in 'data' field (common API pattern)
      Map<String, dynamic> messageDataMap = data;
      
      // Check multiple possible nesting structures
      if (data.containsKey('data') && data['data'] is Map) {
        messageDataMap = Map<String, dynamic>.from(data['data']);
        print('ConversationScreen: Found message in data field');
      } else if (data.containsKey('message') && data['message'] is Map) {
        messageDataMap = Map<String, dynamic>.from(data['message']);
        print('ConversationScreen: Found message in message field');
      } else if (data.containsKey('payload') && data['payload'] is Map) {
        messageDataMap = Map<String, dynamic>.from(data['payload']);
        print('ConversationScreen: Found message in payload field');
      }

      // If messageDataMap is still the original data, check if it already has message fields
      if (messageDataMap == data && 
          !messageDataMap.containsKey('sender_id') && 
          !messageDataMap.containsKey('receiver_id') &&
          !messageDataMap.containsKey('senderId') &&
          !messageDataMap.containsKey('receiverId')) {
        print('ConversationScreen: ⚠️ No message structure found, syncing conversation instead');
        _syncConversation();
        return;
      }

      // Normalize field names - handle both snake_case and camelCase
      final normalizedData = <String, dynamic>{};
      messageDataMap.forEach((key, value) {
        // Convert camelCase to snake_case for consistency
        String normalizedKey = key;
        if (key == 'senderId')
          normalizedKey = 'sender_id';
        else if (key == 'receiverId')
          normalizedKey = 'receiver_id';
        else if (key == 'isRead')
          normalizedKey = 'is_read';
        else if (key == 'createdAt')
          normalizedKey = 'created_at';
        else if (key == 'updatedAt')
          normalizedKey = 'updated_at';
        else if (key == 'senderUsername')
          normalizedKey = 'sender_username';
        else if (key == 'senderImage')
          normalizedKey = 'sender_image';
        else if (key == 'receiverUsername')
          normalizedKey = 'receiver_username';
        else if (key == 'receiverImage')
          normalizedKey = 'receiver_image';

        normalizedData[normalizedKey] = value;
      });

      final receiverId = normalizedData['receiver_id'];
      final senderId = normalizedData['sender_id'];

      print(
        'ConversationScreen: receiverId=$receiverId, senderId=$senderId, widget.receiverId=${widget.receiverId}, currentUserId=$_currentUserId',
      );

      // Check if message is for this conversation
      // Message is for this conversation if:
      // 1. Current user is receiver and sender is the other person, OR
      // 2. Current user is sender and receiver is the other person
      final isForThisConversation =
          (receiverId != null && senderId != null) &&
          ((receiverId == _currentUserId && senderId == widget.receiverId) ||
              (senderId == _currentUserId &&
                  receiverId == widget.receiverId) ||
              (receiverId == widget.receiverId) ||
              (senderId == widget.receiverId));

      if (isForThisConversation) {
        // Parse the message data and add instantly via socket
        try {
          print(
            'ConversationScreen: ✅ Processing message for this conversation',
          );
          final messageData = MessageData.fromJson(normalizedData);
          if (mounted) {
            context.read<ConversationCubit>().addReceivedMessage(messageData);
            _scrollToBottom();
            print('ConversationScreen: ✅ Message added to UI successfully');
          }
        } catch (e, stackTrace) {
          print('ConversationScreen: ❌ Error parsing WebSocket message: $e');
          print('ConversationScreen: Stack trace: $stackTrace');
          print('ConversationScreen: Data that failed: $normalizedData');
          // Try to sync conversation as fallback
          if (mounted) {
            print('ConversationScreen: 🔄 Falling back to sync conversation');
            _syncConversation();
          }
        }
      } else {
        print(
          'ConversationScreen: ⏭️ Message not for this conversation (receiverId=$receiverId, senderId=$senderId, currentUserId=$_currentUserId, widget.receiverId=${widget.receiverId})',
        );
      }
    } catch (e, stackTrace) {
      print('ConversationScreen: ❌ Error in _handleIncomingMessage: $e');
      print('ConversationScreen: Stack trace: $stackTrace');
      // Fallback: sync conversation
      if (mounted) {
        print('ConversationScreen: 🔄 Falling back to sync conversation due to error');
        _syncConversation();
      }
    }
  }

  void _handleConversationUpdated(Map<String, dynamic> data) {
    // Handle conversation_updated event - backend sends full conversation data
    // Based on reference: message.data.conversation contains the updated conversation
    try {
      print('ConversationScreen: Processing conversation_updated event');
      print('ConversationScreen: Full data: $data');
      
      // Extract conversation data from message.data.conversation (as per reference code)
      List<dynamic>? messagesList;
      
      if (data.containsKey('data') && data['data'] is Map) {
        final dataMap = data['data'] as Map<String, dynamic>;
        print('ConversationScreen: Found data map: ${dataMap.keys}');
        
        // Check for conversation field (as per reference: message.data.conversation)
        if (dataMap.containsKey('conversation') && dataMap['conversation'] is List) {
          messagesList = dataMap['conversation'] as List;
          print('ConversationScreen: Found conversation list with ${messagesList.length} items');
        } else if (dataMap.containsKey('messages') && dataMap['messages'] is List) {
          messagesList = dataMap['messages'] as List;
          print('ConversationScreen: Found messages list with ${messagesList.length} items');
        } else if (dataMap.containsKey('data') && dataMap['data'] is List) {
          messagesList = dataMap['data'] as List;
          print('ConversationScreen: Found data list with ${messagesList.length} items');
        }
      } else if (data.containsKey('conversation') && data['conversation'] is List) {
        // Direct conversation field
        messagesList = data['conversation'] as List;
        print('ConversationScreen: Found direct conversation list with ${messagesList.length} items');
      }
      
      if (messagesList != null && messagesList.isNotEmpty) {
        print('ConversationScreen: Processing ${messagesList.length} messages from conversation_updated');
        
        // Parse messages and update conversation
        try {
          final messages = messagesList
              .map((msg) {
                try {
                  // Normalize field names
                  final normalizedMsg = <String, dynamic>{};
                  if (msg is Map) {
                    msg.forEach((key, value) {
                      String normalizedKey = key.toString();
                      if (key == 'senderId') normalizedKey = 'sender_id';
                      else if (key == 'receiverId') normalizedKey = 'receiver_id';
                      else if (key == 'isRead') normalizedKey = 'is_read';
                      else if (key == 'createdAt') normalizedKey = 'created_at';
                      else if (key == 'updatedAt') normalizedKey = 'updated_at';
                      else if (key == 'senderUsername') normalizedKey = 'sender_username';
                      else if (key == 'senderImage') normalizedKey = 'sender_image';
                      else if (key == 'receiverUsername') normalizedKey = 'receiver_username';
                      else if (key == 'receiverImage') normalizedKey = 'receiver_image';
                      normalizedMsg[normalizedKey] = value;
                    });
                  }
                  return MessageData.fromJson(normalizedMsg);
                } catch (e) {
                  print('ConversationScreen: Error parsing individual message: $e');
                  print('ConversationScreen: Message data: $msg');
                  return null;
                }
              })
              .where((msg) => msg != null)
              .cast<MessageData>()
              .toList();
          
          if (mounted && messages.isNotEmpty) {
            // Check if this conversation is relevant to current screen
            final firstMessage = messages.first;
            
            // Check if any message in the conversation is for this screen
            final isRelevant = messages.any((msg) => 
              (msg.senderId == widget.receiverId || 
               msg.receiverId == widget.receiverId ||
               msg.senderId == _currentUserId ||
               msg.receiverId == _currentUserId)
            );
            
            if (isRelevant) {
              print('ConversationScreen: ✅ Updating conversation with ${messages.length} messages');
              print('ConversationScreen: First message - senderId: ${firstMessage.senderId}, receiverId: ${firstMessage.receiverId}');
              print('ConversationScreen: Current userId: $_currentUserId, widget.receiverId: ${widget.receiverId}');
              
              // Update the conversation state with new messages
              context.read<ConversationCubit>().updateConversationMessages(messages);
              _scrollToBottom();
            } else {
              print('ConversationScreen: ⏭️ Conversation not relevant to this screen');
            }
          }
        } catch (e, stackTrace) {
          print('ConversationScreen: ❌ Error parsing conversation messages: $e');
          print('ConversationScreen: Stack trace: $stackTrace');
          // Fallback to sync
          if (mounted) {
            _syncConversation();
          }
        }
      } else {
        // If conversation data structure is different, fallback to sync
        print('ConversationScreen: ⚠️ Conversation data structure not recognized or empty, syncing instead');
        print('ConversationScreen: Data keys: ${data.keys}');
        if (mounted) {
          _syncConversation();
        }
      }
    } catch (e, stackTrace) {
      print('ConversationScreen: ❌ Error in _handleConversationUpdated: $e');
      print('ConversationScreen: Stack trace: $stackTrace');
      // Fallback to sync
      if (mounted) {
        _syncConversation();
      }
    }
  }

  void _handleMessagesRead(Map<String, dynamic> data) {
    // Handle messages read event
    try {
      final senderId = data['sender_id'] ?? data['senderId'];
      if (senderId != null && senderId == widget.receiverId) {
        print('ConversationScreen: ✅ Messages marked as read');
        if (mounted) {
          context.read<ConversationCubit>().updateMessageReadStatus(senderId);
        }
      }
    } catch (e) {
      print('ConversationScreen: ❌ Error handling messages_read: $e');
    }
  }

  Future<void> _syncConversation() async {
    if (_isSyncing) return;
    _isSyncing = true;

    try {
      // Silently refresh conversation without showing loading state
      await context.read<ConversationCubit>().syncConversation(
        widget.receiverId,
        limit: _limit,
        offset: 0,
      );
    } catch (e) {
      print('Error syncing conversation: $e');
    } finally {
      _isSyncing = false;
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _sendMessage() {
    final message = _messageController.text.trim();
    if (message.isEmpty) return;

    context.read<MessageCubit>().sendMessage(widget.receiverId, message);
    _messageController.clear();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _messageController.dispose();
    _scrollController.dispose();
    _messageSubscription?.cancel();
    // Don't dispose socket service - it's a singleton and should stay connected
    // The socket will be disposed when app closes, not when screen closes
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kGrey.withOpacity(0.05),
      appBar: AppBar(
        backgroundColor: kWhite,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: kBlack, size: 24.sp),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            // Receiver Avatar
            Container(
              width: 40.w,
              height: 40.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [kPrimaryColor, kLightPrimaryColor],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child:
                  widget.receiverImage != null &&
                      widget.receiverImage!.isNotEmpty
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(40.r),
                      child: Image.network(
                        "$imageUrl${widget.receiverImage!}",
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Center(
                            child: Text(
                              widget.receiverName.substring(0, 1).toUpperCase(),
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.bold,
                                color: kWhite,
                              ),
                            ),
                          );
                        },
                      ),
                    )
                  : Center(
                      child: Text(
                        widget.receiverName.substring(0, 1).toUpperCase(),
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                          color: kWhite,
                        ),
                      ),
                    ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.receiverName,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: kBlack,
                    ),
                  ),
                  Text(
                    'Online',
                    style: TextStyle(fontSize: 12.sp, color: Colors.green),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Messages List
          Expanded(
            child: BlocListener<MarkReadCubit, MarkReadState>(
              listener: (context, markReadState) {
                if (markReadState is MarkReadSuccess) {
                  // Update conversation messages to show as read
                  context.read<ConversationCubit>().updateMessageReadStatus(
                    markReadState.senderId,
                  );
                }
              },
              child: BlocConsumer<ConversationCubit, ConversationState>(
                listener: (context, state) {
                  if (state is ConversationSuccess) {
                    _scrollToBottom();
                    // Mark messages as read when conversation loads successfully
                    _markMessagesAsRead();
                  }
                },
                builder: (context, state) {
                  if (state is ConversationLoading && _offset == 0) {
                    return Center(
                      child: CircularProgressIndicator(color: kPrimaryColor),
                    );
                  }

                  if (state is ConversationFailure) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline,
                            size: 80.sp,
                            color: Colors.red,
                          ),
                          SizedBox(height: 16.h),
                          Text(
                            'Error loading messages',
                            style: TextStyle(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.w600,
                              color: kBlack,
                            ),
                          ),
                          SizedBox(height: 8.h),
                          Text(
                            state.error,
                            style: TextStyle(fontSize: 14.sp, color: kGrey),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 24.h),
                          ElevatedButton(
                            onPressed: () {
                              _offset = 0;
                              _loadConversation();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: kPrimaryColor,
                              foregroundColor: kWhite,
                            ),
                            child: Text('Retry'),
                          ),
                        ],
                      ),
                    );
                  }

                  if (state is ConversationSuccess) {
                    final messages = state.messages;

                    if (messages.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.chat_bubble_outline,
                              size: 80.sp,
                              color: kGrey,
                            ),
                            SizedBox(height: 16.h),
                            Text(
                              'No messages yet',
                              style: TextStyle(
                                fontSize: 18.sp,
                                fontWeight: FontWeight.w600,
                                color: kBlack,
                              ),
                            ),
                            SizedBox(height: 8.h),
                            Text(
                              'Start the conversation!',
                              style: TextStyle(fontSize: 14.sp, color: kGrey),
                            ),
                          ],
                        ),
                      );
                    }

                    return RefreshIndicator(
                      onRefresh: () async {
                        _offset = 0;
                        await _syncConversation();
                      },
                      color: kPrimaryColor,
                      child: ListView.builder(
                        controller: _scrollController,
                        reverse: false,
                        padding: EdgeInsets.symmetric(vertical: 8.h),
                        itemCount: messages.length,
                        itemBuilder: (context, index) {
                          final message = messages[index];
                          final isCurrentUser =
                              _currentUserId != null &&
                              (message.senderId == _currentUserId ||
                                  message.sender?.id == _currentUserId);
                          return MessageBubble(
                            message: message,
                            isCurrentUser: isCurrentUser,
                            currentUserImage: _currentUserImage,
                          );
                        },
                      ),
                    );
                  }

                  return SizedBox.shrink();
                },
              ),
            ),
          ),

          // Message Input
          BlocConsumer<MessageCubit, MessageState>(
            listener: (context, state) {
              if (state is MessageSuccess) {
                print(
                  'ConversationScreen: ✅ Message sent successfully, adding to conversation',
                );
                context.read<ConversationCubit>().addSentMessage(state.message);
                _messageController.clear();
                _scrollToBottom();
                // Also sync conversation to ensure consistency
                Future.delayed(Duration(milliseconds: 500), () {
                  if (mounted) {
                    _syncConversation();
                  }
                });
              } else if (state is MessageFailure) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.error),
                    backgroundColor: Colors.red,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            builder: (context, state) {
              final isSending = state is MessageLoading;

              return Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                decoration: BoxDecoration(
                  color: kWhite,
                  boxShadow: [
                    BoxShadow(
                      color: kGrey.withOpacity(0.1),
                      blurRadius: 10,
                      offset: Offset(0, -2),
                    ),
                  ],
                ),
                child: SafeArea(
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: kGrey.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(24.r),
                          ),
                          child: TextField(
                            controller: _messageController,
                            enabled: !isSending,
                            decoration: InputDecoration(
                              hintText: 'Type a message...',
                              hintStyle: TextStyle(
                                fontSize: 14.sp,
                                color: kGrey,
                              ),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 16.w,
                                vertical: 12.h,
                              ),
                            ),
                            maxLines: null,
                            textInputAction: TextInputAction.send,
                            onSubmitted: (_) => _sendMessage(),
                          ),
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Container(
                        decoration: BoxDecoration(
                          color: kPrimaryColor,
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          onPressed: isSending ? null : _sendMessage,
                          icon: isSending
                              ? SizedBox(
                                  width: 20.w,
                                  height: 20.h,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      kWhite,
                                    ),
                                  ),
                                )
                              : Icon(Icons.send, color: kWhite, size: 20.sp),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
