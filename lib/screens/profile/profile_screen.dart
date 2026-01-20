import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:todo_app/providers/user_profile_cubit/user_profile_cubit.dart';
import 'package:todo_app/providers/user_profile_cubit/user_profile_state.dart';
import 'package:todo_app/routes/app_router.gr.dart';
import 'package:todo_app/services/local_storage_service.dart';
import 'package:todo_app/utils/colors.dart';
import 'package:todo_app/utils/consts.dart';
import 'package:todo_app/utils/global.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String _formatDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) return 'N/A';
    try {
      final date = DateTime.parse(dateString);
      final months = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec',
      ];
      return '${months[date.month - 1]} ${date.day.toString().padLeft(2, '0')}, ${date.year}';
    } catch (e) {
      return dateString;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kWhite,
      appBar: AppBar(
        backgroundColor: kWhite,
        elevation: 0,
        title: Text(
          'Profile',
          style: TextStyle(
            fontSize: 24.sp,
            fontWeight: FontWeight.bold,
            color: kBlack,
          ),
        ),
      ),
      body: BlocBuilder<UserProfileCubit, UserProfileState>(
        builder: (context, state) {
          if (state is UserProfileLoading) {
            return Center(
              child: CircularProgressIndicator(color: kPrimaryColor),
            );
          }

          if (state is UserProfileFailure) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 80.sp, color: Colors.red),
                  SizedBox(height: 16.h),
                  Text(
                    'Error loading profile',
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
                      context.read<UserProfileCubit>().getUserProfile();
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

          if (state is UserProfileSuccess) {
            final user = state.data.data?.user;
            if (user == null) {
              return Center(
                child: Text(
                  'No profile data available',
                  style: TextStyle(fontSize: 16.sp, color: kGrey),
                ),
              );
            }

            return SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: Column(
                children: [
                  SizedBox(height: 32.h),
                  // Profile Avatar
                  Container(
                    width: 120.w,
                    height: 120.w,
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
                          blurRadius: 20,
                          offset: Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Center(
                      child: user.userImage != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(120.r),
                              child: Image.network(
                                "$imageUrl${user.userImage!}",
                                fit: BoxFit.cover,
                                width: 120.w,
                                height: 120.w,
                              ),
                            )
                          : Text(
                              user.username?.substring(0, 1).toUpperCase() ??
                                  'U',
                              style: TextStyle(
                                fontSize: 48.sp,
                                fontWeight: FontWeight.bold,
                                color: kWhite,
                              ),
                            ),
                    ),
                  ),
                  SizedBox(height: 24.h),
                  // Username
                  Text(
                    user.username ?? 'N/A',
                    style: TextStyle(
                      fontSize: 28.sp,
                      fontWeight: FontWeight.bold,
                      color: kBlack,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  // Email
                  Text(
                    user.useremail ?? 'N/A',
                    style: TextStyle(fontSize: 16.sp, color: kGrey),
                  ),
                  SizedBox(height: 40.h),
                  // Profile Information Card
                  Container(
                    padding: EdgeInsets.all(20.w),
                    decoration: BoxDecoration(
                      color: kWhite,
                      borderRadius: BorderRadius.circular(16.r),
                      boxShadow: [
                        BoxShadow(
                          color: kGrey.withOpacity(0.1),
                          blurRadius: 10,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Profile Information',
                          style: TextStyle(
                            fontSize: 20.sp,
                            fontWeight: FontWeight.bold,
                            color: kBlack,
                          ),
                        ),
                        SizedBox(height: 24.h),
                        // User ID
                        _buildInfoRow(
                          icon: Icons.badge_outlined,
                          label: 'User ID',
                          value: user.id?.toString() ?? 'N/A',
                        ),
                        SizedBox(height: 20.h),
                        Divider(color: kGrey.withOpacity(0.2)),
                        SizedBox(height: 20.h),
                        // Username
                        _buildInfoRow(
                          icon: Icons.person_outline,
                          label: 'Username',
                          value: user.username ?? 'N/A',
                        ),
                        SizedBox(height: 20.h),
                        Divider(color: kGrey.withOpacity(0.2)),
                        SizedBox(height: 20.h),
                        // Email
                        _buildInfoRow(
                          icon: Icons.email_outlined,
                          label: 'Email',
                          value: user.useremail ?? 'N/A',
                        ),
                        SizedBox(height: 20.h),
                        Divider(color: kGrey.withOpacity(0.2)),
                        SizedBox(height: 20.h),
                        // Created At
                        _buildInfoRow(
                          icon: Icons.calendar_today_outlined,
                          label: 'Member Since',
                          value: _formatDate(user.createdAt),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 24.h),
                  // Action Buttons
                  _buildActionButton(
                    icon: Icons.edit_outlined,
                    label: 'Edit Profile',
                    onTap: () {
                      // TODO: Navigate to edit profile screen
                    },
                  ),
                  SizedBox(height: 12.h),
                  _buildActionButton(
                    icon: Icons.settings_outlined,
                    label: 'Settings',
                    onTap: () {
                      // TODO: Navigate to settings screen
                    },
                  ),
                  SizedBox(height: 12.h),
                  _buildActionButton(
                    icon: Icons.logout_outlined,
                    label: 'Logout',
                    onTap: _showLogoutDialog,
                    isDestructive: true,
                  ),
                  SizedBox(height: 32.h),
                ],
              ),
            );
          }

          return Center(
            child: Text(
              'No data available',
              style: TextStyle(fontSize: 16.sp, color: kGrey),
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(10.w),
          decoration: BoxDecoration(
            color: kPrimaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10.r),
          ),
          child: Icon(icon, color: kPrimaryColor, size: 20.sp),
        ),
        SizedBox(width: 16.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12.sp,
                  color: kGrey,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                value,
                style: TextStyle(
                  fontSize: 16.sp,
                  color: kBlack,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
        decoration: BoxDecoration(
          color: isDestructive
              ? Colors.red.withOpacity(0.1)
              : kPrimaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: isDestructive
                ? Colors.red.withOpacity(0.3)
                : kPrimaryColor.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isDestructive ? Colors.red : kPrimaryColor,
              size: 24.sp,
            ),
            SizedBox(width: 16.w),
            Text(
              label,
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: isDestructive ? Colors.red : kPrimaryColor,
              ),
            ),
            Spacer(),
            Icon(
              Icons.arrow_forward_ios,
              color: isDestructive ? Colors.red : kPrimaryColor,
              size: 16.sp,
            ),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
          title: Text(
            'Logout',
            style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold),
          ),
          content: Text(
            'Are you sure you want to logout?',
            style: TextStyle(fontSize: 14.sp),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('No', style: TextStyle(color: kGrey)),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _handleLogout();
              },
              child: Text('Yes', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  Future<void> _handleLogout() async {
    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return PopScope(
          canPop: false,
          child: Dialog(
            backgroundColor: Colors.transparent,
            child: Container(
              padding: EdgeInsets.all(20.w),
              decoration: BoxDecoration(
                color: kWhite,
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(color: kPrimaryColor),
                  SizedBox(height: 16.h),
                  Text(
                    'Logging out...',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w500,
                      color: kBlack,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );

    // Add delay
    await Future.delayed(const Duration(seconds: 1));

    // Clear token
    await LocalStorageService.i.removeToken(kToken);

    // Close loading dialog
    if (mounted) {
      Navigator.of(context).pop();
    }

    // Navigate to login screen and clear stack
    if (mounted) {
      context.router.pushAndPopUntil(
        const LoginRoute(),
        predicate: (route) => false,
      );
    }
  }
}
