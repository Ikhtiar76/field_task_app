// ignore_for_file: use_build_context_synchronously, deprecated_member_use

import 'package:collection/collection.dart';
import 'package:field_task_app/core/constants/colors.dart';
import 'package:field_task_app/core/models/task_model.dart';
import 'package:field_task_app/core/utills/location_utils.dart';
import 'package:field_task_app/core/utills/ui_helper.dart';
import 'package:field_task_app/core/widgets/custom_button.dart';
import 'package:field_task_app/core/widgets/status_badge.dart';
import 'package:field_task_app/features/task/presentation/blocs/create_task_bloc/create_task_bloc.dart';
import 'package:field_task_app/features/task/presentation/widgets/map_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';

class TaskDetailsScreen extends StatefulWidget {
  final TaskModel taskModel;
  final List<TaskModel> taskModelList;
  const TaskDetailsScreen({
    super.key,
    required this.taskModel,
    required this.taskModelList,
  });

  @override
  State<TaskDetailsScreen> createState() => _TaskDetailsScreenState();
}

class _TaskDetailsScreenState extends State<TaskDetailsScreen> {
  double distance = 0;
  bool mapLoads = false;

  @override
  void initState() {
    super.initState();
    _loadDistance();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Task Details',
          style: TextStyle(fontWeight: FontWeight.w600, color: black),
        ),
      ),
      body: BlocConsumer<CreateTaskBloc, CreateTaskState>(
        listener: (context, state) {
          if (state is TasksLoaded) {
            UIHelper.showSnackBar(
              context,
              'Successfully Task Updated!',
              color: Colors.green,
            );
            Navigator.pop(context);
          }
        },
        builder: (context, state) {
          return SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: screenWidth * 0.05,
              vertical: screenHeight * 0.02,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTitleCard(
                  context,
                  widget.taskModel.title,
                  '${widget.taskModel.dueTime}, ${DateFormat.yMMMd().format(DateTime.parse(widget.taskModel.dueDate ?? ''))}',
                  widget.taskModel.status,
                ),
                SizedBox(height: screenHeight * 0.015),

                if (widget.taskModel.parentTaskId != null) ...[
                  _buildTaskDependency(context),
                  SizedBox(height: screenHeight * 0.015),
                ],
                _buildTaskTitle(context, 'Task Location'),
                SizedBox(height: screenHeight * 0.005),
                ReusableMap(
                  mode: MapMode.viewer,
                  initialLocation: LatLng(
                    widget.taskModel.latitude!,
                    widget.taskModel.longitude!,
                  ),
                  radius: 100,
                  distanceInMeters: distance,
                ),
                SizedBox(height: screenHeight * 0.015),
                _buildDistance(context, distance),
                SizedBox(height: screenHeight * 0.015),
                if (widget.taskModel.status.toLowerCase() == 'completed')
                  Center(
                    child: Text(
                      '‣ Task Completed',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.green,
                      ),
                    ),
                  )
                else if (mapLoads)
                  CustomButton(
                    text: state is TasksLoading
                        ? null
                        : (widget.taskModel.status.toLowerCase() ==
                                  "in progress"
                              ? 'Complete at Location'
                              : 'Check in at Location'),
                    isLoading: state is TasksLoading,
                    color: Colors.blue,
                    onPressed: () =>
                        _handleTaskButtonPress(context.read<CreateTaskBloc>()),
                  ),

                SizedBox(height: screenHeight * 0.02),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildTitleCard(
    BuildContext context,
    String title,
    String dueTime,
    String status,
  ) {
    return Container(
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: white,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(child: _buildTaskTitle(context, title)),
              StatusBadge(status: status),
            ],
          ),
          SizedBox(height: 8),
          _buildDueTime(dueTime),
        ],
      ),
    );
  }

  Widget _buildTaskTitle(BuildContext context, String title) {
    return Text(
      title,
      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: black),
    );
  }

  Widget _buildDueTime(String dueTime) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.schedule, size: 12, color: grey),
        SizedBox(width: 2),
        Text(
          'Duetime: $dueTime',
          style: TextStyle(
            fontSize: 12,
            color: grey,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }

  Widget _buildTaskDependency(BuildContext context) {
    final parentTask = getParentTask();
    final parentTitle = parentTask?.title ?? '';
    final parentCompleted = parentTask?.status.toLowerCase() == 'completed';
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: (parentCompleted ? Colors.green : red).withOpacity(0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: parentCompleted ? Colors.green : red),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.link,
                size: 18,
                color: parentCompleted ? Colors.green : red,
              ),
              SizedBox(width: 4),
              Text(
                'Task Dependency',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: black,
                ),
              ),
            ],
          ),
          Padding(
            padding: EdgeInsets.only(left: 24),
            child: Text(
              parentCompleted
                  ? '"$parentTitle" completed. You can check in now.'
                  : 'You must complete "$parentTitle" before starting this task.',
              style: TextStyle(fontSize: 10, color: grey.withOpacity(0.6)),
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
        color: white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: grey.withOpacity(0.2)),
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
                color: black,
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

  Future<void> _loadDistance() async {
    double distanceFromTask = await LocationUtils.getDistance(
      widget.taskModel.latitude!,
      widget.taskModel.longitude!,
    );
    if (!mounted) return;
    setState(() {
      distance = distanceFromTask;
      mapLoads = true;
    });
  }

  TaskModel? getParentTask() {
    return widget.taskModelList.firstWhereOrNull(
      (e) => e.id == widget.taskModel.parentTaskId,
    );
  }

  void _handleTaskButtonPress(CreateTaskBloc bloc) {
    if (distance > 100) {
      final status = widget.taskModel.status.toLowerCase() == "in progress"
          ? 'complete'
          : 'check in';
      UIHelper.showSnackBar(
        context,
        'You must be within 100m to $status',
        color: red,
      );
      return;
    }

    final parentTask = getParentTask();
    if (parentTask != null && parentTask.status.toLowerCase() != 'completed') {
      UIHelper.showSnackBar(
        context,
        'You must complete "${parentTask.title}" before starting this task.',
        color: red,
      );
      return;
    }

    final nextStatus = widget.taskModel.status.toLowerCase() == "in progress"
        ? "Completed"
        : "In Progress";
    final task = widget.taskModel.copyWith(
      status: nextStatus,
    ); // use copyWith in model
    bloc.add(UpdateTaskEvent(task: task));
  }
}
