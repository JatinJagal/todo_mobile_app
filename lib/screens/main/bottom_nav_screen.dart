import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:todo_app/providers/task_list_cubit/task_list_cubit.dart';
import 'package:todo_app/providers/user_profile_cubit/user_profile_cubit.dart';
import 'package:todo_app/screens/home/home_screen.dart';
import 'package:todo_app/screens/profile/profile_screen.dart';
import 'package:todo_app/screens/tasks/tasks_screen.dart';
import 'package:todo_app/utils/colors.dart';

@RoutePage()
class BottomNavScreen extends StatefulWidget {
  const BottomNavScreen({super.key});

  @override
  State<BottomNavScreen> createState() => _BottomNavScreenState();
}

class _BottomNavScreenState extends State<BottomNavScreen> {
  @override
  void initState() {
    context.read<UserProfileCubit>().getUserProfile();
    context.read<TaskListCubit>().getTasks();
    super.initState();
  }

  int _currentIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const TasksScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: kGrey.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          type: BottomNavigationBarType.fixed,
          backgroundColor: kWhite,
          selectedItemColor: kPrimaryColor,
          unselectedItemColor: kGrey,
          selectedLabelStyle: TextStyle(
            fontSize: 12.sp,
            fontWeight: FontWeight.w600,
          ),
          unselectedLabelStyle: TextStyle(
            fontSize: 12.sp,
            fontWeight: FontWeight.w500,
          ),
          elevation: 0,
          items: [
            BottomNavigationBarItem(
              icon: Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: _currentIndex == 0
                      ? kPrimaryColor.withOpacity(0.1)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(
                  _currentIndex == 0 ? Icons.home : Icons.home_outlined,
                  size: 24.sp,
                ),
              ),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: _currentIndex == 1
                      ? kPrimaryColor.withOpacity(0.1)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(
                  _currentIndex == 1 ? Icons.task_alt : Icons.task_outlined,
                  size: 24.sp,
                ),
              ),
              label: 'Tasks',
            ),
            BottomNavigationBarItem(
              icon: Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: _currentIndex == 2
                      ? kPrimaryColor.withOpacity(0.1)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(
                  _currentIndex == 2 ? Icons.person : Icons.person_outline,
                  size: 24.sp,
                ),
              ),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}
