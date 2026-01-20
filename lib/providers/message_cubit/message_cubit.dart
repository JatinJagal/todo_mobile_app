import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todo_app/models/message_model.dart';
import 'package:todo_app/providers/message_cubit/message_state.dart';
import 'package:todo_app/repository/users_activity_repository.dart';

class MessageCubit extends Cubit<MessageState> {
  final UsersActivityRepository usersActivityRepository;
  MessageCubit(this.usersActivityRepository) : super(MessageInitial());

  Future<void> sendMessage(int receiverId, String message) async {
    emit(MessageLoading());
    final result = await usersActivityRepository.sendMessage(receiverId, message);
    result.either(
      (left) {
        emit(MessageFailure(error: left));
      },
      (right) {
        emit(MessageSuccess(message: right));
      },
    );
  }
}

class ConversationCubit extends Cubit<ConversationState> {
  final UsersActivityRepository usersActivityRepository;
  ConversationCubit(this.usersActivityRepository)
      : super(ConversationInitial());

  Future<void> getConversation(int receiverId, {int limit = 20, int offset = 0}) async {
    emit(ConversationLoading());
    final result = await usersActivityRepository.getConversation(
      receiverId,
      limit: limit,
      offset: offset,
    );
    result.either(
      (left) {
        emit(ConversationFailure(error: left));
      },
      (right) {
        emit(ConversationSuccess(messages: right));
      },
    );
  }

  void addReceivedMessage(MessageData message) {
    if (state is ConversationSuccess) {
      final currentState = state as ConversationSuccess;
      // Check if message already exists to prevent duplicates
      final messageExists = currentState.messages.any((msg) => msg.id == message.id);
      if (!messageExists) {
        final updatedMessages = List<MessageData>.from(currentState.messages)
          ..add(message);
        // Sort messages by created_at to maintain order
        updatedMessages.sort((a, b) {
          final aTime = a.createdAt ?? '';
          final bTime = b.createdAt ?? '';
          return aTime.compareTo(bTime);
        });
        emit(ConversationSuccess(messages: updatedMessages));
        print('ConversationCubit: ✅ Added new message (id: ${message.id})');
      } else {
        // Update existing message if it has changed
        final updatedMessages = currentState.messages.map((msg) {
          if (msg.id == message.id) {
            return message; // Use the new message data
          }
          return msg;
        }).toList();
        emit(ConversationSuccess(messages: updatedMessages));
        print('ConversationCubit: ✅ Updated existing message (id: ${message.id})');
      }
    } else {
      // If state is not ConversationSuccess, initialize with the new message
      print('ConversationCubit: State not ready, initializing with new message');
      emit(ConversationSuccess(messages: [message]));
    }
  }

  void addSentMessage(MessageData message) {
    if (state is ConversationSuccess) {
      final currentState = state as ConversationSuccess;
      // Check if message already exists to prevent duplicates
      final messageExists = currentState.messages.any((msg) => msg.id == message.id);
      if (!messageExists) {
        final updatedMessages = List<MessageData>.from(currentState.messages)
          ..add(message);
        emit(ConversationSuccess(messages: updatedMessages));
      } else {
        // Update existing message if it has changed
        final updatedMessages = currentState.messages.map((msg) {
          if (msg.id == message.id) {
            return message; // Use the new message data
          }
          return msg;
        }).toList();
        emit(ConversationSuccess(messages: updatedMessages));
      }
    }
  }

  void updateMessageReadStatus(int senderId) {
    if (state is ConversationSuccess) {
      final currentState = state as ConversationSuccess;
      final updatedMessages = currentState.messages.map((message) {
        if (message.senderId == senderId && message.isRead == 0) {
          return MessageData(
            id: message.id,
            senderId: message.senderId,
            receiverId: message.receiverId,
            message: message.message,
            isRead: 1,
            createdAt: message.createdAt,
            updatedAt: message.updatedAt,
            senderUsername: message.senderUsername,
            senderImage: message.senderImage,
            receiverUsername: message.receiverUsername,
            receiverImage: message.receiverImage,
            sender: message.sender,
            receiver: message.receiver,
          );
        }
        return message;
      }).toList();
      emit(ConversationSuccess(messages: updatedMessages));
    }
  }

  // Update conversation messages from WebSocket conversation_updated event
  void updateConversationMessages(List<MessageData> newMessages) {
    // Sort messages by created_at to maintain order
    final sortedMessages = List<MessageData>.from(newMessages);
    sortedMessages.sort((a, b) {
      final aTime = a.createdAt ?? '';
      final bTime = b.createdAt ?? '';
      return aTime.compareTo(bTime);
    });
    
    emit(ConversationSuccess(messages: sortedMessages));
    print('ConversationCubit: ✅ Updated conversation with ${sortedMessages.length} messages');
  }

  // Silent sync without showing loading state
  Future<void> syncConversation(int receiverId, {int limit = 20, int offset = 0}) async {
    final result = await usersActivityRepository.getConversation(
      receiverId,
      limit: limit,
      offset: offset,
    );
    result.either(
      (left) {
        // Silently fail - don't emit error for background sync
        print('Sync failed: $left');
      },
      (right) {
        // Update messages if state is ConversationSuccess
        if (state is ConversationSuccess) {
          final currentState = state as ConversationSuccess;
          // Only update if we have new messages or different count
          if (right.length != currentState.messages.length) {
            emit(ConversationSuccess(messages: right));
          } else {
            // Check if any messages have been updated (e.g., read status, content)
            bool hasChanges = false;
            for (int i = 0; i < right.length; i++) {
              if (i < currentState.messages.length) {
                final newMsg = right[i];
                final oldMsg = currentState.messages[i];
                if (newMsg.id != oldMsg.id || 
                    newMsg.isRead != oldMsg.isRead ||
                    newMsg.message != oldMsg.message ||
                    newMsg.updatedAt != oldMsg.updatedAt) {
                  hasChanges = true;
                  break;
                }
              } else {
                hasChanges = true;
                break;
              }
            }
            if (hasChanges) {
              emit(ConversationSuccess(messages: right));
            }
          }
        } else {
          // If not in success state, emit the new state
          emit(ConversationSuccess(messages: right));
        }
      },
    );
  }
}

class MarkReadCubit extends Cubit<MarkReadState> {
  final UsersActivityRepository usersActivityRepository;
  MarkReadCubit(this.usersActivityRepository) : super(MarkReadInitial());

  Future<void> markMessageRead(int senderId) async {
    emit(MarkReadLoading(senderId: senderId));
    final result = await usersActivityRepository.markMessageRead(senderId);
    result.either(
      (left) {
        emit(MarkReadFailure(error: left, senderId: senderId));
      },
      (right) {
        emit(MarkReadSuccess(data: right, senderId: senderId));
      },
    );
  }
}

