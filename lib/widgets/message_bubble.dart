import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:todo_app/models/message_model.dart';
import 'package:todo_app/utils/colors.dart';
import 'package:todo_app/utils/consts.dart';

class MessageBubble extends StatelessWidget {
  final MessageData message;
  final bool isCurrentUser;
  final String? currentUserImage;

  const MessageBubble({
    super.key,
    required this.message,
    required this.isCurrentUser,
    this.currentUserImage,
  });

  String _formatTime(String? dateString) {
    if (dateString == null || dateString.isEmpty) return '';
    try {
      final date = DateTime.parse(dateString);
      final hour = date.hour;
      final minute = date.minute.toString().padLeft(2, '0');
      final period = hour >= 12 ? 'PM' : 'AM';
      final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
      return '$displayHour:$minute $period';
    } catch (e) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
      child: Row(
        mainAxisAlignment:
            isCurrentUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isCurrentUser) ...[
            // Avatar for received messages
            Container(
              width: 32.w,
              height: 32.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [kPrimaryColor, kLightPrimaryColor],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: message.senderImage != null &&
                      message.senderImage!.isNotEmpty
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(32.r),
                      child: Image.network(
                        "$imageUrl${message.senderImage!}",
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Center(
                            child: Text(
                              message.senderUsername
                                      ?.substring(0, 1)
                                      .toUpperCase() ??
                                  'U',
                              style: TextStyle(
                                fontSize: 14.sp,
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
                        message.senderUsername
                                ?.substring(0, 1)
                                .toUpperCase() ??
                            'U',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.bold,
                          color: kWhite,
                        ),
                      ),
                    ),
            ),
            SizedBox(width: 8.w),
          ],
          // Message content
          Flexible(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
              decoration: BoxDecoration(
                color: isCurrentUser ? kPrimaryColor : kWhite,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16.r),
                  topRight: Radius.circular(16.r),
                  bottomLeft: isCurrentUser ? Radius.circular(16.r) : Radius.zero,
                  bottomRight: isCurrentUser ? Radius.zero : Radius.circular(16.r),
                ),
                boxShadow: [
                  BoxShadow(
                    color: kGrey.withOpacity(0.1),
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message.message ?? '',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: isCurrentUser ? kWhite : kBlack,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _formatTime(message.createdAt),
                        style: TextStyle(
                          fontSize: 10.sp,
                          color: isCurrentUser
                              ? kWhite.withOpacity(0.7)
                              : kGrey,
                        ),
                      ),
                      if (isCurrentUser) ...[
                        SizedBox(width: 4.w),
                        Icon(
                          message.isRead == 1
                              ? Icons.done_all
                              : Icons.done,
                          size: 12.sp,
                          color: message.isRead == 1
                              ? Colors.blue.shade300
                              : kWhite.withOpacity(0.7),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
          if (isCurrentUser) ...[
            SizedBox(width: 8.w),
            // Avatar for sent messages
            Container(
              width: 32.w,
              height: 32.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [Colors.purple, Colors.purpleAccent],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: currentUserImage != null && currentUserImage!.isNotEmpty
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(32.r),
                      child: Image.network(
                        "$imageUrl$currentUserImage",
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Center(
                            child: Text(
                              'U',
                              style: TextStyle(
                                fontSize: 14.sp,
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
                        'U',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.bold,
                          color: kWhite,
                        ),
                      ),
                    ),
            ),
          ],
        ],
      ),
    );
  }
}

