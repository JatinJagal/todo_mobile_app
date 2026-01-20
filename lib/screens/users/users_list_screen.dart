import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:todo_app/models/list_users_model.dart';
import 'package:todo_app/providers/send_chat_request_cubit/send_chat_request_cubit.dart';
import 'package:todo_app/providers/send_chat_request_cubit/send_chat_request_state.dart';
import 'package:todo_app/providers/users_list_cubit/users_list_cubit.dart';
import 'package:todo_app/providers/users_list_cubit/users_list_state.dart';
import 'package:todo_app/screens/users/chat_request_screen.dart';
import 'package:todo_app/screens/users/conversation_screen.dart';
import 'package:todo_app/utils/colors.dart';
import 'package:todo_app/utils/consts.dart';

class UsersListScreen extends StatefulWidget {
  const UsersListScreen({super.key});

  @override
  State<UsersListScreen> createState() => _UsersListScreenState();
}

class _UsersListScreenState extends State<UsersListScreen> {
  final List<ListUsersModel> _filteredUsers = [];
  List<ListUsersModel> _allUsers = [];

  @override
  void initState() {
    super.initState();
    context.read<UsersListCubit>().getAllUsersList();
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

  void _handleChatRequest(ListUsersModel user) {
    if (user.id != null) {
      context.read<SendChatRequestCubit>().sendChatRequest(user.id!);
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kGrey.withOpacity(0.05),
      appBar: AppBar(
        backgroundColor: kWhite,
        elevation: 0,
        title: Text(
          'Users',
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
        actions: [
          TextButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ChatRequestScreen(),
                ),
              );
            },
            icon: Icon(
              Icons.mark_chat_unread,
              color: kPrimaryColor,
              size: 20.sp,
            ),
            label: Text(
              'Request',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: kPrimaryColor,
              ),
            ),
          ),
        ],
      ),
      body: BlocBuilder<UsersListCubit, UsersListState>(
        builder: (context, state) {
          if (state is UsersListLoading) {
            return Center(
              child: CircularProgressIndicator(color: kPrimaryColor),
            );
          }

          if (state is UsersListFailure) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 80.sp, color: Colors.red),
                  SizedBox(height: 16.h),
                  Text(
                    'Error loading users',
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
                      context.read<UsersListCubit>().getAllUsersList();
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

          if (state is UsersListSuccess) {
            _allUsers = state.users;
            // Initialize filtered users if empty
            if (_filteredUsers.isEmpty) {
              _filteredUsers.addAll(_allUsers);
            }

            return Column(
              children: [
                // Users List
                Expanded(
                  child: ListView.builder(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    itemCount: _filteredUsers.length,
                    itemBuilder: (context, index) {
                      final user = _filteredUsers[index];
                      return _buildUserTile(user);
                    },
                  ),
                ),
              ],
            );
          }

          return SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildUserTile(ListUsersModel user) {
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
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        leading: Container(
          width: 60.w,
          height: 60.w,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [kPrimaryColor, kLightPrimaryColor],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: kPrimaryColor.withOpacity(0.3),
                blurRadius: 8,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: user.image != null && user.image!.isNotEmpty
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(60.r),
                  child: Image.network(
                    "$imageUrl${user.image!}",
                    fit: BoxFit.cover,
                    width: 60.w,
                    height: 60.w,
                    errorBuilder: (context, error, stackTrace) {
                      return Center(
                        child: Text(
                          user.username?.substring(0, 1).toUpperCase() ?? 'U',
                          style: TextStyle(
                            fontSize: 24.sp,
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
                    user.username?.substring(0, 1).toUpperCase() ?? 'U',
                    style: TextStyle(
                      fontSize: 24.sp,
                      fontWeight: FontWeight.bold,
                      color: kWhite,
                    ),
                  ),
                ),
        ),
        title: Text(
          user.username ?? 'Unknown User',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
            color: kBlack,
          ),
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 4.h),
            Row(
              children: [
                Icon(Icons.email_outlined, size: 14.sp, color: kGrey),
                SizedBox(width: 4.w),
                Expanded(
                  child: Text(
                    user.useremail ?? 'N/A',
                    style: TextStyle(fontSize: 14.sp, color: kGrey),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            SizedBox(height: 4.h),
            Row(
              children: [
                Icon(Icons.calendar_today_outlined, size: 14.sp, color: kGrey),
                SizedBox(width: 4.w),
                Flexible(
                  child: Text(
                    'Joined: ${_formatDate(user.createdAt)}',
                    style: TextStyle(fontSize: 12.sp, color: kGrey),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: SizedBox(width: 100.w, child: _buildStatusButton(user)),
      ),
    );
  }

  Widget _buildStatusButton(ListUsersModel user) {
    final status = user.status?.toLowerCase() ?? 'none';

    // If status is "none" or null, show Send Request button
    if (status == 'none' || status.isEmpty) {
      return BlocConsumer<SendChatRequestCubit, SendChatRequestState>(
        listener: (context, state) {
          if (state is SendChatRequestSuccess && state.receiverId == user.id) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Chat request sent to ${user.username ?? 'user'}',
                ),
                backgroundColor: Colors.green,
                behavior: SnackBarBehavior.floating,
                duration: Duration(seconds: 2),
              ),
            );
            // Refresh users list to update status
            context.read<UsersListCubit>().getAllUsersList();
          } else if (state is SendChatRequestFailure &&
              state.receiverId == user.id) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.error),
                backgroundColor: Colors.red,
                behavior: SnackBarBehavior.floating,
                duration: Duration(seconds: 2),
              ),
            );
          }
        },
        builder: (context, state) {
          final isLoading =
              state is SendChatRequestLoading && state.receiverId == user.id;
          return SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: isLoading || user.id == null
                  ? null
                  : () {
                      _handleChatRequest(user);
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: kPrimaryColor,
                foregroundColor: kWhite,
                disabledBackgroundColor: kPrimaryColor.withOpacity(0.6),
                elevation: 0,
                padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 6.h),
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
                        valueColor: AlwaysStoppedAnimation<Color>(kWhite),
                      ),
                    )
                  : Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.send, size: 12.sp, color: kWhite),
                        SizedBox(width: 4.w),
                        Flexible(
                          child: Text(
                            isLoading ? 'Sending...' : 'Send Request',
                            style: TextStyle(
                              fontSize: 10.sp,
                              fontWeight: FontWeight.w600,
                              color: kWhite,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
            ),
          );
        },
      );
    }

    // If status is "accepted", show Chat button
    if (status == 'accepted') {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: user.id == null
              ? null
              : () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ConversationScreen(
                        receiverId: user.id!,
                        receiverName: user.username ?? 'User',
                        receiverImage: user.image,
                      ),
                    ),
                  );
                },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            foregroundColor: kWhite,
            elevation: 0,
            padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 6.h),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.r),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.chat_bubble_outline, size: 12.sp, color: kWhite),
              SizedBox(width: 4.w),
              Text(
                'Chat',
                style: TextStyle(
                  fontSize: 10.sp,
                  fontWeight: FontWeight.w600,
                  color: kWhite,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // If status is "pending", show Pending button (disabled)
    if (status == 'pending') {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: null,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.orange.withOpacity(0.1),
            foregroundColor: kGrey,
            disabledBackgroundColor: Colors.orange.withOpacity(0.1),
            disabledForegroundColor: kGrey,
            elevation: 0,
            padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 6.h),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.r),
              side: BorderSide(color: Colors.orange, width: 1),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.pending_outlined, size: 12.sp, color: kGrey),
              SizedBox(width: 4.w),
              Text(
                'Pending',
                style: TextStyle(
                  fontSize: 10.sp,
                  fontWeight: FontWeight.w600,
                  color: kGrey,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // If status is "rejected", show Rejected button (disabled)
    if (status == 'rejected') {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: null,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red.withOpacity(0.1),
            foregroundColor: kGrey,
            disabledBackgroundColor: Colors.red.withOpacity(0.1),
            disabledForegroundColor: kGrey,
            elevation: 0,
            padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 6.h),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.r),
              side: BorderSide(color: Colors.red, width: 1),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.cancel_outlined, size: 12.sp, color: kGrey),
              SizedBox(width: 4.w),
              Text(
                'Rejected',
                style: TextStyle(
                  fontSize: 10.sp,
                  fontWeight: FontWeight.w600,
                  color: kGrey,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Default fallback (shouldn't reach here)
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: null,
        style: ElevatedButton.styleFrom(
          backgroundColor: kGrey.withOpacity(0.1),
          foregroundColor: kGrey,
          disabledBackgroundColor: kGrey.withOpacity(0.1),
          disabledForegroundColor: kGrey,
          elevation: 0,
          padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 6.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.r),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.help_outline, size: 12.sp, color: kGrey),
            SizedBox(width: 4.w),
            Text(
              'Unknown',
              style: TextStyle(
                fontSize: 10.sp,
                fontWeight: FontWeight.w600,
                color: kGrey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
