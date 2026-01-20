import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:todo_app/models/chat_request_model.dart';
import 'package:todo_app/providers/chat_request_action_cubit/chat_request_action_cubit.dart';
import 'package:todo_app/providers/chat_request_action_cubit/chat_request_action_state.dart';
import 'package:todo_app/providers/chat_requests_cubit/chat_requests_cubit.dart';
import 'package:todo_app/providers/chat_requests_cubit/chat_requests_state.dart';
import 'package:todo_app/providers/user_profile_cubit/user_profile_cubit.dart';
import 'package:todo_app/providers/user_profile_cubit/user_profile_state.dart';
import 'package:todo_app/screens/users/conversation_screen.dart';
import 'package:todo_app/services/local_storage_service.dart';
import 'package:todo_app/services/socket_service.dart';
import 'package:todo_app/utils/colors.dart';
import 'package:todo_app/utils/consts.dart';
import 'package:todo_app/utils/global.dart';

class ChatRequestScreen extends StatefulWidget {
  const ChatRequestScreen({super.key});

  @override
  State<ChatRequestScreen> createState() => _ChatRequestScreenState();
}

class _ChatRequestScreenState extends State<ChatRequestScreen> {
  int? _currentUserId;
  final SocketService _socketService = SocketService();
  StreamSubscription? _socketSubscription;

  @override
  void initState() {
    super.initState();
    context.read<ChatRequestsCubit>().getChatRequests();
    // Get current user ID from profile
    final profileState = context.read<UserProfileCubit>().state;
    if (profileState is UserProfileSuccess) {
      _currentUserId = profileState.data.data?.user?.id;
    } else {
      // If profile not loaded, fetch it
      context.read<UserProfileCubit>().getUserProfile();
    }
    _setupWebSocket();
  }

  void _setupWebSocket() async {
    final token = await LocalStorageService.i.getStorageValue(kToken);
    if (token.isEmpty) {
      print('ChatRequestScreen: No token available for WebSocket connection');
      return;
    }

    // Connect WebSocket
    _socketService.connect(token);

    // Listen to WebSocket events
    _socketSubscription = _socketService.messageStream.listen(
      (data) {
        if (!mounted) return;

        print('ChatRequestScreen: 📨 Received WebSocket data: $data');
        final eventType = data['event_type'] ?? data['type'] ?? data['event'];

        // Handle chat request events
        if (eventType == 'chat_request_received' ||
            eventType == 'chat_request_accepted' ||
            eventType == 'chat_request_removed') {
          print('ChatRequestScreen: ✅ Refreshing chat requests due to $eventType');
          // Refresh chat requests list when any of these events occur
          context.read<ChatRequestsCubit>().getChatRequests();
        }
      },
      onError: (error) {
        print('ChatRequestScreen: ❌ WebSocket stream error: $error');
      },
      cancelOnError: false,
    );
  }

  @override
  void dispose() {
    _socketSubscription?.cancel();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Update current user ID when profile state changes
    final profileState = context.read<UserProfileCubit>().state;
    if (profileState is UserProfileSuccess) {
      _currentUserId = profileState.data.data?.user?.id;
    }
  }

  String _formatDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) return 'N/A';
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return dateString;
    }
  }

  Color _getStatusColorValue(String? status) {
    switch (status?.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'accepted':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kGrey.withOpacity(0.05),
      appBar: AppBar(
        backgroundColor: kWhite,
        elevation: 0,
        title: Text(
          'Chat Requests',
          style: TextStyle(
            fontSize: 24.sp,
            fontWeight: FontWeight.bold,
            color: kBlack,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: kBlack, size: 24.sp),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: BlocBuilder<UserProfileCubit, UserProfileState>(
        builder: (context, profileState) {
          // Update current user ID from profile state
          if (profileState is UserProfileSuccess) {
            _currentUserId = profileState.data.data?.user?.id;
          }

          return BlocBuilder<ChatRequestsCubit, ChatRequestsState>(
            builder: (context, state) {
              if (state is ChatRequestsLoading) {
                return Center(
                  child: CircularProgressIndicator(color: kPrimaryColor),
                );
              }

              if (state is ChatRequestsFailure) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, size: 80.sp, color: Colors.red),
                      SizedBox(height: 16.h),
                      Text(
                        'Error loading chat requests',
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w600,
                          color: kBlack,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 40.w),
                        child: Text(
                          state.error,
                          style: TextStyle(fontSize: 14.sp, color: kGrey),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      SizedBox(height: 24.h),
                      ElevatedButton(
                        onPressed: () {
                          context.read<ChatRequestsCubit>().getChatRequests();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kPrimaryColor,
                          foregroundColor: kWhite,
                          padding: EdgeInsets.symmetric(
                            horizontal: 32.w,
                            vertical: 12.h,
                          ),
                        ),
                        child: Text('Retry'),
                      ),
                    ],
                  ),
                );
              }

              if (state is ChatRequestsSuccess) {
                final requests = state.requests;

                if (requests.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.mark_chat_unread_outlined,
                          size: 80.sp,
                          color: kGrey,
                        ),
                        SizedBox(height: 16.h),
                        Text(
                          'No chat requests',
                          style: TextStyle(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w600,
                            color: kBlack,
                          ),
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          'You don\'t have any chat requests yet',
                          style: TextStyle(fontSize: 14.sp, color: kGrey),
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    context.read<ChatRequestsCubit>().getChatRequests();
                  },
                  color: kPrimaryColor,
                  child: ListView.builder(
                    padding: EdgeInsets.all(16.w),
                    itemCount: requests.length,
                    itemBuilder: (context, index) {
                      final request = requests[index];
                      return _buildRequestTile(request);
                    },
                  ),
                );
              }

              return SizedBox.shrink();
            },
          );
        },
      ),
    );
  }

  Widget _buildRequestTile(ChatRequestData request) {
    final isPending = request.status?.toLowerCase() == 'pending';
    final statusColor = _getStatusColorValue(request.status);

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        color: kWhite,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: kGrey.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with avatars and status
            Row(
              children: [
                // Sender Avatar
                _buildAvatar(
                  request.senderImage,
                  request.senderUsername ?? 'S',
                  isSender: true,
                ),
                SizedBox(width: 12.w),
                Icon(Icons.arrow_forward, color: kGrey, size: 20.sp),
                SizedBox(width: 12.w),
                // Receiver Avatar
                _buildAvatar(
                  request.receiverImage,
                  request.receiverUsername ?? 'R',
                  isSender: false,
                ),
                Spacer(),
                // Status Badge and Chat Icon
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12.w,
                        vertical: 6.h,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20.r),
                        border: Border.all(color: statusColor, width: 1),
                      ),
                      child: Text(
                        request.status?.toUpperCase() ?? 'PENDING',
                        style: TextStyle(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w600,
                          color: statusColor,
                        ),
                      ),
                    ),
                    if (request.status?.toLowerCase() == 'accepted') ...[
                      SizedBox(width: 8.w),
                      IconButton(
                        onPressed: () {
                          // Determine receiver ID based on current user
                          final receiverId =
                              _currentUserId == request.senderId ||
                                  _currentUserId == request.senderUserId
                              ? request.receiverId ?? request.receiverUserId
                              : request.senderId ?? request.senderUserId;

                          if (receiverId != null) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ConversationScreen(
                                  receiverId: receiverId,
                                  receiverName:
                                      _currentUserId == request.senderId ||
                                          _currentUserId == request.senderUserId
                                      ? request.receiverUsername ?? 'User'
                                      : request.senderUsername ?? 'User',
                                  receiverImage:
                                      _currentUserId == request.senderId ||
                                          _currentUserId == request.senderUserId
                                      ? request.receiverImage
                                      : request.senderImage,
                                ),
                              ),
                            );
                          }
                        },
                        icon: Icon(
                          Icons.chat_bubble_outline,
                          color: kPrimaryColor,
                          size: 20.sp,
                        ),
                        tooltip: 'Open Chat',
                      ),
                    ],
                  ],
                ),
              ],
            ),
            SizedBox(height: 16.h),
            Divider(color: kGrey.withOpacity(0.2)),
            SizedBox(height: 12.h),
            // Sender Info
            Row(
              children: [
                Icon(Icons.person_outline, size: 16.sp, color: kGrey),
                SizedBox(width: 8.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'From: ${request.senderUsername ?? 'Unknown'}',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: kBlack,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        request.senderEmail ?? 'N/A',
                        style: TextStyle(fontSize: 12.sp, color: kGrey),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),
            // Receiver Info
            Row(
              children: [
                Icon(Icons.person_outline, size: 16.sp, color: kGrey),
                SizedBox(width: 8.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'To: ${request.receiverUsername ?? 'Unknown'}',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: kBlack,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        request.receiverEmail ?? 'N/A',
                        style: TextStyle(fontSize: 12.sp, color: kGrey),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),
            Divider(color: kGrey.withOpacity(0.2)),
            SizedBox(height: 12.h),
            // Date and Actions
            Row(
              children: [
                Icon(Icons.calendar_today_outlined, size: 14.sp, color: kGrey),
                SizedBox(width: 6.w),
                Text(
                  'Requested: ${_formatDate(request.createdAt)}',
                  style: TextStyle(fontSize: 12.sp, color: kGrey),
                ),
                Spacer(),
                if (isPending)
                  Builder(
                    builder: (context) {
                      // Check if sender is the current logged-in user
                      final isSenderCurrentUser =
                          _currentUserId != null &&
                          (request.senderId == _currentUserId ||
                              request.senderUserId == _currentUserId);

                      return BlocConsumer<
                        ChatRequestActionCubit,
                        ChatRequestActionState
                      >(
                        listener: (context, actionState) {
                          if (actionState is ChatRequestActionSuccess &&
                              actionState.requestId == request.id) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  actionState.action == 'accept'
                                      ? 'Chat request accepted successfully'
                                      : actionState.action == 'remove'
                                      ? 'Chat request removed'
                                      : 'Chat request rejected',
                                ),
                                backgroundColor: actionState.action == 'accept'
                                    ? Colors.green
                                    : Colors.orange,
                                behavior: SnackBarBehavior.floating,
                                duration: Duration(seconds: 2),
                              ),
                            );
                            // Refresh the chat requests list
                            context.read<ChatRequestsCubit>().getChatRequests();
                          } else if (actionState is ChatRequestActionFailure &&
                              actionState.requestId == request.id) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(actionState.error),
                                backgroundColor: Colors.red,
                                behavior: SnackBarBehavior.floating,
                                duration: Duration(seconds: 2),
                              ),
                            );
                          }
                        },
                        builder: (context, actionState) {
                          final isLoading =
                              actionState is ChatRequestActionLoading &&
                              actionState.requestId == request.id;
                          final isDisabled = isLoading;

                          // If sender is current user, show only Remove button
                          if (isSenderCurrentUser) {
                            return OutlinedButton(
                              onPressed: isDisabled || request.id == null
                                  ? null
                                  : () {
                                      context
                                          .read<ChatRequestActionCubit>()
                                          .removeChatRequest(request.id!);
                                    },
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(
                                  color: isDisabled
                                      ? Colors.grey
                                      : Colors.orange,
                                  width: 1,
                                ),
                                padding: EdgeInsets.symmetric(
                                  horizontal: 12.w,
                                  vertical: 6.h,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8.r),
                                ),
                              ),
                              child: isLoading
                                  ? SizedBox(
                                      width: 14.w,
                                      height: 14.h,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                              Colors.orange,
                                            ),
                                      ),
                                    )
                                  : Text(
                                      'Remove',
                                      style: TextStyle(
                                        fontSize: 12.sp,
                                        color: isDisabled
                                            ? Colors.grey
                                            : Colors.orange,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                            );
                          }

                          // If sender is not current user, show Accept and Reject buttons
                          return Row(
                            children: [
                              OutlinedButton(
                                onPressed: isDisabled || request.id == null
                                    ? null
                                    : () {
                                        context
                                            .read<ChatRequestActionCubit>()
                                            .acceptChatRequest(request.id!);
                                      },
                                style: OutlinedButton.styleFrom(
                                  side: BorderSide(
                                    color: isDisabled
                                        ? Colors.grey
                                        : Colors.green,
                                    width: 1,
                                  ),
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 12.w,
                                    vertical: 6.h,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8.r),
                                  ),
                                ),
                                child: isLoading
                                    ? SizedBox(
                                        width: 14.w,
                                        height: 14.h,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                Colors.green,
                                              ),
                                        ),
                                      )
                                    : Text(
                                        'Accept',
                                        style: TextStyle(
                                          fontSize: 12.sp,
                                          color: isDisabled
                                              ? Colors.grey
                                              : Colors.green,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                              ),
                              SizedBox(width: 8.w),
                              OutlinedButton(
                                onPressed: isDisabled || request.id == null
                                    ? null
                                    : () {
                                        context
                                            .read<ChatRequestActionCubit>()
                                            .rejectChatRequest(request.id!);
                                      },
                                style: OutlinedButton.styleFrom(
                                  side: BorderSide(
                                    color: isDisabled
                                        ? Colors.grey
                                        : Colors.red,
                                    width: 1,
                                  ),
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 12.w,
                                    vertical: 6.h,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8.r),
                                  ),
                                ),
                                child: isLoading
                                    ? SizedBox(
                                        width: 14.w,
                                        height: 14.h,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                Colors.red,
                                              ),
                                        ),
                                      )
                                    : Text(
                                        'Reject',
                                        style: TextStyle(
                                          fontSize: 12.sp,
                                          color: isDisabled
                                              ? Colors.grey
                                              : Colors.red,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                              ),
                            ],
                          );
                        },
                      );
                    },
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar(
    String? image,
    String username, {
    required bool isSender,
  }) {
    final initial = username.isNotEmpty ? username[0].toUpperCase() : 'U';

    return Container(
      width: 50.w,
      height: 50.w,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: isSender
              ? [kPrimaryColor, kLightPrimaryColor]
              : [Colors.purple, Colors.purpleAccent],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: (isSender ? kPrimaryColor : Colors.purple).withOpacity(0.3),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: image != null && image.isNotEmpty
          ? ClipRRect(
              borderRadius: BorderRadius.circular(50.r),
              child: Image.network(
                "$imageUrl$image",
                fit: BoxFit.cover,
                width: 50.w,
                height: 50.w,
                errorBuilder: (context, error, stackTrace) {
                  return Center(
                    child: Text(
                      initial,
                      style: TextStyle(
                        fontSize: 20.sp,
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
                initial,
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                  color: kWhite,
                ),
              ),
            ),
    );
  }
}
