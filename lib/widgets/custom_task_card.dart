import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:todo_app/models/tasks_model.dart';
import 'package:todo_app/utils/colors.dart';

class CustomTaskCard extends StatelessWidget {
  final Tasks task;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const CustomTaskCard({
    super.key,
    required this.task,
    this.onTap,
    this.onEdit,
    this.onDelete,
  });

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

  String _formatTime(String? timeString) {
    if (timeString == null || timeString.isEmpty) return 'N/A';
    try {
      // Assuming time is in format "HH:mm:ss" or "HH:mm"
      final parts = timeString.split(':');
      if (parts.length >= 2) {
        final hour = int.parse(parts[0]);
        final minute = parts[1];
        final period = hour >= 12 ? 'PM' : 'AM';
        final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
        return '$displayHour:$minute $period';
      }
      return timeString;
    } catch (e) {
      return timeString;
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16.r),
      child: Container(
        margin: EdgeInsets.only(bottom: 16.h),
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
          border: Border.all(color: kPrimaryColor.withOpacity(0.2), width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with title and actions
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        task.title ?? 'Untitled Task',
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                          color: kBlack,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (task.description != null &&
                          task.description!.isNotEmpty) ...[
                        SizedBox(height: 8.h),
                        Text(
                          task.description!,
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: kGrey,
                            height: 1.4,
                          ),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
                // Action buttons
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (onEdit != null)
                      IconButton(
                        icon: Icon(
                          Icons.edit_outlined,
                          color: kPrimaryColor,
                          size: 20.sp,
                        ),
                        onPressed: onEdit,
                        padding: EdgeInsets.zero,
                        constraints: BoxConstraints(),
                      ),
                    SizedBox(width: 8.w),
                    if (onDelete != null)
                      IconButton(
                        icon: Icon(
                          Icons.delete_outline,
                          color: Colors.red,
                          size: 20.sp,
                        ),
                        onPressed: onDelete,
                        padding: EdgeInsets.zero,
                        constraints: BoxConstraints(),
                      ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 16.h),
            Divider(color: kGrey.withOpacity(0.2)),
            SizedBox(height: 16.h),
            // Date and Time Information
            Row(
              children: [
                // Start Date & Time
                Expanded(
                  child: _buildInfoItem(
                    icon: Icons.play_circle_outline,
                    label: 'Start',
                    date: _formatDate(task.startDate),
                    time: _formatTime(task.startTime),
                    color: Colors.green,
                  ),
                ),
                SizedBox(width: 16.w),
                // End Date & Time
                Expanded(
                  child: _buildInfoItem(
                    icon: Icons.stop_circle_outlined,
                    label: 'End',
                    date: _formatDate(task.endDate),
                    time: _formatTime(task.endTime),
                    color: Colors.red,
                  ),
                ),
              ],
            ),
            if (task.createdAt != null) ...[
              SizedBox(height: 12.h),
              Row(
                children: [
                  Icon(Icons.access_time, size: 14.sp, color: kGrey),
                  SizedBox(width: 6.w),
                  Text(
                    'Created: ${_formatDate(task.createdAt)}',
                    style: TextStyle(fontSize: 12.sp, color: kGrey),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String label,
    required String date,
    required String time,
    required Color color,
  }) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16.sp, color: color),
              SizedBox(width: 6.w),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
          SizedBox(height: 6.h),
          Text(
            date,
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w600,
              color: kBlack,
            ),
          ),
          SizedBox(height: 2.h),
          Text(
            time,
            style: TextStyle(fontSize: 12.sp, color: kGrey),
          ),
        ],
      ),
    );
  }
}
