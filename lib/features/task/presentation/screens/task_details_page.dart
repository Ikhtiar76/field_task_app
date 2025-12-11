// ignore_for_file: use_build_context_synchronously

import 'package:field_task_app/core/models/task_model.dart';
import 'package:field_task_app/core/widgets/submit_button.dart';
import 'package:field_task_app/features/task/presentation/blocs/create_task_bloc/create_task_bloc.dart';
import 'package:field_task_app/features/task/presentation/widgets/map_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';

class TaskDetailsScreen extends StatelessWidget {
  final TaskModel taskModel;
  const TaskDetailsScreen({super.key, required this.taskModel});

  Future<double> getDistanceFromTask(TaskModel task) async {
    // User current location
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    // Task location
    double distanceInMeters = Geolocator.distanceBetween(
      position.latitude,
      position.longitude,
      task.latitude!,
      task.longitude!,
    );

    return distanceInMeters;
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isSmallScreen = screenWidth < 360;
    final isLargeScreen = screenWidth > 400;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Task Details',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: screenWidth * 0.05,
          vertical: screenHeight * 0.02,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTaskTitle(context, taskModel.title),
            SizedBox(height: screenHeight * 0.015),

            _buildStatusAndTime(context, isSmallScreen),
            SizedBox(height: screenHeight * 0.015),

            _buildTaskDependency(context),
            SizedBox(height: screenHeight * 0.015),
            _buildTaskTitle(context, 'Task Location'),
            SizedBox(height: screenHeight * 0.005),
            FutureBuilder<double>(
              future: getDistanceFromTask(taskModel),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Column(
                    children: [
                      ReusableMap(
                        mode: MapMode.viewer,
                        initialLocation: LatLng(
                          taskModel.latitude!,
                          taskModel.longitude!,
                        ),
                        radius: 100,
                        distanceInMeters: 0,
                      ),
                      SizedBox(height: screenHeight * 0.015),
                      _buildDistance(context, 0),
                    ],
                  );
                }

                double distance = snapshot.data!;
                return Column(
                  children: [
                    ReusableMap(
                      mode: MapMode.viewer,
                      initialLocation: LatLng(
                        taskModel.latitude!,
                        taskModel.longitude!,
                      ),
                      radius: 100,
                      distanceInMeters: distance,
                    ),
                    SizedBox(height: screenHeight * 0.015),
                    _buildDistance(context, distance),
                  ],
                );
              },
            ),

            SizedBox(height: screenHeight * 0.015),
            BlocBuilder<CreateTaskBloc, CreateTaskState>(
              builder: (context, state) {
                return SubmitButton(
                  text: 'Check in at Location',
                  isLoading: state.isSubmitting,
                  onPressed: () async {
                    double distance = await getDistanceFromTask(taskModel);

                    if (distance <= 100) {
                      String nextStatus = taskModel.status == "in_progress"
                          ? "completed"
                          : "in_progress";

                      context.read<CreateTaskBloc>().add(
                        UpdateTaskStatus(
                          task: taskModel,
                          newStatus: nextStatus,
                        ),
                      );
                      Navigator.pop(context);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('You must be within 100m to check in'),
                        ),
                      );
                    }
                  },
                  color: Colors.blue,
                );
              },
            ),

            SizedBox(height: screenHeight * 0.02),
          ],
        ),
      ),
    );
  }

  Widget _buildTaskTitle(BuildContext context, String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: Colors.black,
      ),
    );
  }

  Widget _buildStatusAndTime(BuildContext context, bool isSmallScreen) {
    return Row(
      children: [
        _buildPendingStatus(isSmallScreen),
        Spacer(),
        _buildDueTime(isSmallScreen),
      ],
    );
  }

  Widget _buildPendingStatus(bool isSmallScreen) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isSmallScreen ? 8 : 10,
        vertical: isSmallScreen ? 3 : 4,
      ),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.access_time, size: 12, color: Colors.orange),
          SizedBox(width: isSmallScreen ? 3 : 4),
          Text(
            'Pending',
            style: TextStyle(
              fontSize: 12,
              color: Colors.orange,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDueTime(bool isSmallScreen) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isSmallScreen ? 10 : 12,
        vertical: isSmallScreen ? 5 : 6,
      ),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red.shade100),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.schedule, size: 12, color: Colors.red.shade700),
          SizedBox(width: 4),
          Text(
            'Due: ${taskModel.dueHour}:${taskModel.dueMinute} ${DateFormat('dd/MM/yy').format(taskModel.dueDate!)}',
            style: TextStyle(
              fontSize: 12,
              color: Colors.red,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskDependency(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.link, size: 18, color: Colors.blue.shade700),
              SizedBox(width: 4),
              Text(
                'Task Dependency',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                ),
              ),
            ],
          ),
          Padding(
            padding: EdgeInsets.only(left: 24),
            child: Text(
              'You must complete "Equipment Installation" before starting this task.',
              style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDistance(BuildContext context, double distanceInMeters) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.place, size: 12, color: Colors.blue.shade700),
          SizedBox(width: 6),
          Expanded(
            child: Text(
              'Distance from location',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '${distanceInMeters.toStringAsFixed(0)} m',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.blue.shade700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
