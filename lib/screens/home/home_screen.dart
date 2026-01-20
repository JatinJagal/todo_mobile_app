import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:todo_app/providers/upcoming_task_cubit/upcoming_task_cubit.dart';
import 'package:todo_app/providers/upcoming_task_cubit/upcoming_task_state.dart';
import 'package:todo_app/screens/tasks/create_task_screen.dart';
import 'package:todo_app/screens/users/users_list_screen.dart';
import 'package:todo_app/utils/colors.dart';
import 'package:todo_app/widgets/upcoming_task_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    context.read<UpcomingTaskCubit>().getUpcomingTasks();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kGrey.withOpacity(0.05),
      appBar: AppBar(
        backgroundColor: kWhite,
        elevation: 0,
        title: Text(
          'Home',
          style: TextStyle(
            fontSize: 24.sp,
            fontWeight: FontWeight.bold,
            color: kBlack,
          ),
        ),
        actions: [
          // IconButton(
          //   icon: Icon(Icons.refresh, color: kPrimaryColor, size: 24.sp),
          //   onPressed: () {
          //     context.read<UpcomingTaskCubit>().getUpcomingTasks();
          //   },
          // ),
          IconButton(
            icon: Icon(
              Icons.group_add_outlined,
              color: kPrimaryColor,
              size: 24.sp,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => UsersListScreen()),
              );
            },
          ),
        ],
      ),
      body: BlocBuilder<UpcomingTaskCubit, UpcomingTaskState>(
        builder: (context, state) {
          if (state is UpcomingTaskLoading) {
            return Center(
              child: CircularProgressIndicator(color: kPrimaryColor),
            );
          }

          if (state is UpcomingTaskFailure) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 80.sp, color: Colors.red),
                  SizedBox(height: 16.h),
                  Text(
                    'Error loading upcoming tasks',
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
                      context.read<UpcomingTaskCubit>().getUpcomingTasks();
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

          if (state is UpcomingTaskSuccess) {
            if (state.tasks.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.event_available_outlined,
                      size: 80.sp,
                      color: kGrey,
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      'No upcoming tasks',
                      style: TextStyle(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.w600,
                        color: kBlack,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      'Create tasks to see them here',
                      style: TextStyle(fontSize: 14.sp, color: kGrey),
                    ),
                  ],
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () async {
                context.read<UpcomingTaskCubit>().getUpcomingTasks();
              },
              color: kPrimaryColor,
              child: SingleChildScrollView(
                padding: EdgeInsets.all(16.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header Section
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(12.w),
                          decoration: BoxDecoration(
                            color: kPrimaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: Icon(
                            Icons.event_available_outlined,
                            color: kPrimaryColor,
                            size: 24.sp,
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Upcoming Tasks',
                              style: TextStyle(
                                fontSize: 22.sp,
                                fontWeight: FontWeight.bold,
                                color: kBlack,
                              ),
                            ),
                            Text(
                              '${state.tasks.length} task${state.tasks.length != 1 ? 's' : ''}',
                              style: TextStyle(fontSize: 14.sp, color: kGrey),
                            ),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(height: 24.h),
                    // Tasks List
                    ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: state.tasks.length,
                      itemBuilder: (context, index) {
                        final task = state.tasks[index];
                        return UpcomingTaskCard(
                          task: task,
                          onTap: () {
                            // TODO: Navigate to task details screen
                          },
                        );
                      },
                    ),
                  ],
                ),
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CreateTaskScreen()),
          );
        },
        backgroundColor: kPrimaryColor,
        icon: Icon(Icons.add, color: kWhite),
        label: Text(
          'Create Task',
          style: TextStyle(color: kWhite, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
