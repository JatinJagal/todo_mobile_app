import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:todo_app/providers/task_list_cubit/task_list_cubit.dart';
import 'package:todo_app/providers/task_list_cubit/task_list_state.dart';
import 'package:todo_app/screens/tasks/create_task_screen.dart';
import 'package:todo_app/utils/colors.dart';
import 'package:todo_app/widgets/custom_task_card.dart';

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kGrey.withOpacity(0.05),
      appBar: AppBar(
        backgroundColor: kWhite,
        elevation: 0,
        title: Text(
          'Task Lists',
          style: TextStyle(
            fontSize: 24.sp,
            fontWeight: FontWeight.bold,
            color: kBlack,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: kPrimaryColor, size: 24.sp),
            onPressed: () {
              context.read<TaskListCubit>().getTasks();
            },
          ),
          IconButton(
            icon: Icon(
              Icons.add_circle_outline,
              color: kPrimaryColor,
              size: 24.sp,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const CreateTaskScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: BlocBuilder<TaskListCubit, TaskListState>(
        builder: (context, state) {
          if (state is TaskListLoading) {
            return Center(
              child: CircularProgressIndicator(color: kPrimaryColor),
            );
          }

          if (state is TaskListFailure) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 80.sp, color: Colors.red),
                  SizedBox(height: 16.h),
                  Text(
                    'Error loading tasks',
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
                      context.read<TaskListCubit>().getTasks();
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

          if (state is TaskListSuccess) {
            if (state.tasks.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.task_outlined, size: 80.sp, color: kGrey),
                    SizedBox(height: 16.h),
                    Text(
                      'No tasks yet',
                      style: TextStyle(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.w600,
                        color: kBlack,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      'Create your first task to get started',
                      style: TextStyle(fontSize: 14.sp, color: kGrey),
                    ),
                    SizedBox(height: 24.h),
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const CreateTaskScreen(),
                          ),
                        );
                      },
                      icon: Icon(Icons.add, color: kWhite),
                      label: Text('Create Task'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kPrimaryColor,
                        foregroundColor: kWhite,
                        padding: EdgeInsets.symmetric(
                          horizontal: 24.w,
                          vertical: 12.h,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () async {
                context.read<TaskListCubit>().getTasks();
              },
              color: kPrimaryColor,
              child: ListView.builder(
                padding: EdgeInsets.all(16.w),
                itemCount: state.tasks.length,
                itemBuilder: (context, index) {
                  final task = state.tasks[index];
                  return CustomTaskCard(
                    task: task,
                    onTap: () {
                      // TODO: Navigate to task details screen
                    },
                    onEdit: () {
                      // TODO: Navigate to edit task screen
                    },
                    onDelete: () {
                      // TODO: Show delete confirmation and delete task
                      _showDeleteDialog(context, task);
                    },
                  );
                },
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

  void _showDeleteDialog(BuildContext context, task) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
          title: Text(
            'Delete Task',
            style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold),
          ),
          content: Text(
            'Are you sure you want to delete "${task.title ?? 'this task'}"?',
            style: TextStyle(fontSize: 14.sp),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel', style: TextStyle(color: kGrey)),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                // TODO: Implement delete task
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Delete functionality to be implemented'),
                    backgroundColor: kPrimaryColor,
                  ),
                );
              },
              child: Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }
}
