import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:todo_app/providers/create_task_cubit/create_task_cubit.dart';
import 'package:todo_app/providers/create_task_cubit/create_task_state.dart';
import 'package:todo_app/providers/upcoming_task_cubit/upcoming_task_cubit.dart';
import 'package:todo_app/utils/colors.dart';
import 'package:todo_app/widgets/custom_button.dart';
import 'package:todo_app/widgets/custom_textfield.dart';

class CreateTaskScreen extends StatefulWidget {
  const CreateTaskScreen({super.key});

  @override
  State<CreateTaskScreen> createState() => _CreateTaskScreenState();
}

class _CreateTaskScreenState extends State<CreateTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  DateTime? _startDate;
  DateTime? _endDate;
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  String? _validateTitle(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter task title';
    }
    return null;
  }

  String? _validateDescription(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter task description';
    }
    return null;
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStartDate
          ? (_startDate ?? DateTime.now())
          : (_endDate ?? _startDate ?? DateTime.now()),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: kPrimaryColor,
              onPrimary: kWhite,
              onSurface: kBlack,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _startDate = picked;
          if (_endDate != null && _endDate!.isBefore(_startDate!)) {
            _endDate = null;
          }
        } else {
          _endDate = picked;
        }
      });
    }
  }

  Future<void> _selectTime(BuildContext context, bool isStartTime) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: isStartTime
          ? (_startTime ?? TimeOfDay.now())
          : (_endTime ?? TimeOfDay.now()),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: kPrimaryColor,
              onPrimary: kWhite,
              onSurface: kBlack,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        if (isStartTime) {
          _startTime = picked;
        } else {
          _endTime = picked;
        }
      });
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Select date';
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  String _formatTime(TimeOfDay? time) {
    if (time == null) return 'Select time';
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  String _formatDisplayDate(DateTime? date) {
    if (date == null) return 'Select date';
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
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  String _formatDisplayTime(TimeOfDay? time) {
    if (time == null) return 'Select time';
    final hour = time.hour > 12
        ? time.hour - 12
        : (time.hour == 0 ? 12 : time.hour);
    final period = time.hour >= 12 ? 'PM' : 'AM';
    return '${hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')} $period';
  }

  void _handleCreateTask() {
    if (_formKey.currentState!.validate()) {
      if (_startDate == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Please select start date'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
      if (_endDate == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Please select end date'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
      if (_startTime == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Please select start time'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
      if (_endTime == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Please select end time'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      context.read<CreateTaskCubit>().createTask(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        startDate: _formatDate(_startDate),
        endDate: _formatDate(_endDate),
        startTime: _formatTime(_startTime),
        endTime: _formatTime(_endTime),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<CreateTaskCubit, CreateTaskState>(
      listener: (context, state) {
        if (state is CreateTaskSuccess) {
          Navigator.pop(context);
          context.read<UpcomingTaskCubit>().getUpcomingTasks();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Task created successfully'),
              backgroundColor: kPrimaryColor,
            ),
          );
        } else if (state is CreateTaskFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.error), backgroundColor: Colors.red),
          );
        }
      },
      child: Scaffold(
        backgroundColor: kWhite,
        appBar: AppBar(
          backgroundColor: kWhite,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: kBlack, size: 24.sp),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            'Create Task',
            style: TextStyle(
              fontSize: 24.sp,
              fontWeight: FontWeight.bold,
              color: kBlack,
            ),
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(height: 24.h),
                  // Title Field
                  CustomTextField(
                    labelText: 'Task Title',
                    hintText: 'Enter task title',
                    controller: _titleController,
                    keyboardType: TextInputType.text,
                    validator: _validateTitle,
                    prefixIcon: Icon(
                      Icons.title_outlined,
                      color: kGrey,
                      size: 20.sp,
                    ),
                  ),
                  SizedBox(height: 24.h),
                  // Description Field
                  CustomTextField(
                    labelText: 'Description',
                    hintText: 'Enter task description',
                    controller: _descriptionController,
                    keyboardType: TextInputType.multiline,
                    maxLines: 4,
                    validator: _validateDescription,
                    prefixIcon: Icon(
                      Icons.description_outlined,
                      color: kGrey,
                      size: 20.sp,
                    ),
                  ),
                  SizedBox(height: 24.h),
                  // Start Date
                  Text(
                    'Start Date',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                      color: kBlack.withOpacity(0.8),
                    ),
                  ),
                  SizedBox(height: 8.h),
                  InkWell(
                    onTap: () => _selectDate(context, true),
                    borderRadius: BorderRadius.circular(12.r),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 16.h,
                      ),
                      decoration: BoxDecoration(
                        color: kGrey.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(
                          color: kGrey.withOpacity(0.2),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.calendar_today_outlined,
                            color: kGrey,
                            size: 20.sp,
                          ),
                          SizedBox(width: 12.w),
                          Text(
                            _formatDisplayDate(_startDate),
                            style: TextStyle(
                              fontSize: 16.sp,
                              color: _startDate == null ? kGrey : kBlack,
                            ),
                          ),
                          Spacer(),
                          Icon(
                            Icons.arrow_forward_ios,
                            color: kGrey,
                            size: 16.sp,
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 24.h),
                  // Start Time
                  Text(
                    'Start Time',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                      color: kBlack.withOpacity(0.8),
                    ),
                  ),
                  SizedBox(height: 8.h),
                  InkWell(
                    onTap: () => _selectTime(context, true),
                    borderRadius: BorderRadius.circular(12.r),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 16.h,
                      ),
                      decoration: BoxDecoration(
                        color: kGrey.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(
                          color: kGrey.withOpacity(0.2),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.access_time_outlined,
                            color: kGrey,
                            size: 20.sp,
                          ),
                          SizedBox(width: 12.w),
                          Text(
                            _formatDisplayTime(_startTime),
                            style: TextStyle(
                              fontSize: 16.sp,
                              color: _startTime == null ? kGrey : kBlack,
                            ),
                          ),
                          Spacer(),
                          Icon(
                            Icons.arrow_forward_ios,
                            color: kGrey,
                            size: 16.sp,
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 24.h),
                  // End Date
                  Text(
                    'End Date',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                      color: kBlack.withOpacity(0.8),
                    ),
                  ),
                  SizedBox(height: 8.h),
                  InkWell(
                    onTap: () => _selectDate(context, false),
                    borderRadius: BorderRadius.circular(12.r),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 16.h,
                      ),
                      decoration: BoxDecoration(
                        color: kGrey.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(
                          color: kGrey.withOpacity(0.2),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.calendar_today_outlined,
                            color: kGrey,
                            size: 20.sp,
                          ),
                          SizedBox(width: 12.w),
                          Text(
                            _formatDisplayDate(_endDate),
                            style: TextStyle(
                              fontSize: 16.sp,
                              color: _endDate == null ? kGrey : kBlack,
                            ),
                          ),
                          Spacer(),
                          Icon(
                            Icons.arrow_forward_ios,
                            color: kGrey,
                            size: 16.sp,
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 24.h),
                  // End Time
                  Text(
                    'End Time',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                      color: kBlack.withOpacity(0.8),
                    ),
                  ),
                  SizedBox(height: 8.h),
                  InkWell(
                    onTap: () => _selectTime(context, false),
                    borderRadius: BorderRadius.circular(12.r),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 16.h,
                      ),
                      decoration: BoxDecoration(
                        color: kGrey.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(
                          color: kGrey.withOpacity(0.2),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.access_time_outlined,
                            color: kGrey,
                            size: 20.sp,
                          ),
                          SizedBox(width: 12.w),
                          Text(
                            _formatDisplayTime(_endTime),
                            style: TextStyle(
                              fontSize: 16.sp,
                              color: _endTime == null ? kGrey : kBlack,
                            ),
                          ),
                          Spacer(),
                          Icon(
                            Icons.arrow_forward_ios,
                            color: kGrey,
                            size: 16.sp,
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 32.h),
                  // Create Button
                  BlocBuilder<CreateTaskCubit, CreateTaskState>(
                    builder: (context, state) {
                      return CustomButton(
                        text: 'Create Task',
                        onPressed: _handleCreateTask,
                        isLoading: state is CreateTaskLoading,
                        icon: Icon(Icons.add_task, color: kWhite, size: 20.sp),
                      );
                    },
                  ),
                  SizedBox(height: 24.h),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
