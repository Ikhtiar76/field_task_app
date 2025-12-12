// ignore_for_file: use_build_context_synchronously, deprecated_member_use

import 'package:field_task_app/core/models/task_model.dart';
import 'package:field_task_app/core/widgets/custom_button.dart';
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

  Future<void> _loadDistance() async {
    double distanceFromTask = await getDistanceFromTask(widget.taskModel);
    if (!mounted) return;
    setState(() {
      distance = distanceFromTask;
      mapLoads = true;
    });
  }

  Future<double> getDistanceFromTask(TaskModel task) async {
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    double distanceInMeters = Geolocator.distanceBetween(
      position.latitude,
      position.longitude,
      task.latitude!,
      task.longitude!,
    );

    return distance = distanceInMeters;
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Task Details',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      body: BlocConsumer<CreateTaskBloc, CreateTaskState>(
        listener: (context, state) {
          if (state is TasksLoaded) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                behavior: SnackBarBehavior.fixed,
                backgroundColor: Colors.green,
                content: Text('Successfully Task Updated!'),
                duration: Duration(seconds: 2),
              ),
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
                    onPressed: () {
                      if (distance <= 100) {
                        String nextStatus =
                            widget.taskModel.status.toLowerCase() ==
                                "in progress"
                            ? "Completed"
                            : "In Progress";
                        if (widget.taskModel.parentTaskId != null &&
                            widget.taskModelList
                                    .firstWhere(
                                      (element) =>
                                          element.id ==
                                          widget.taskModel.parentTaskId,
                                    )
                                    .status
                                    .toLowerCase() !=
                                'completed') {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                "You must complete Task '' before starting this task.",
                              ),
                              behavior: SnackBarBehavior.fixed,
                              backgroundColor: Colors.red,
                              duration: Duration(seconds: 2),
                            ),
                          );
                          return;
                        }

                        final task = TaskModel(
                          title: widget.taskModel.title,
                          id: widget.taskModel.id,
                          dueDate: widget.taskModel.dueDate,
                          dueTime: widget.taskModel.dueTime,
                          latitude: widget.taskModel.latitude,
                          longitude: widget.taskModel.longitude,
                          status: nextStatus,
                          parentTaskId: widget.taskModel.parentTaskId,
                        );
                        context.read<CreateTaskBloc>().add(
                          UpdateTaskEvent(task: task),
                        );
                      } else {
                        final status =
                            widget.taskModel.status.toLowerCase() ==
                                "in progress"
                            ? 'complete'
                            : 'check in';
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('You must be within 100m to $status'),
                            behavior: SnackBarBehavior.fixed,
                            backgroundColor: Colors.red,
                            duration: Duration(seconds: 2),
                          ),
                        );
                      }
                    },
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
        color: Colors.white,
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
              _buildPendingStatus(status),
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
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: Colors.black,
      ),
    );
  }

  Widget _buildPendingStatus(String status) {
    final color = status.toLowerCase() == "completed"
        ? Colors.green
        : status.toLowerCase() == "in progress"
        ? Colors.blue
        : Colors.orange;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.shade50,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.access_time, size: 10, color: color),
          SizedBox(width: 3),
          Text(
            status,
            style: TextStyle(
              fontSize: 10,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDueTime(String dueTime) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.schedule, size: 12, color: Colors.grey),
        SizedBox(width: 2),
        Text(
          'Duetime: $dueTime',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }

  Widget _buildTaskDependency(BuildContext context) {
    String parentTitle = widget.taskModelList
        .firstWhere((element) => element.id == widget.taskModel.parentTaskId)
        .title;
    bool parentCompleted =
        widget.taskModel.parentTaskId != null &&
        widget.taskModelList
                .firstWhere(
                  (element) => element.id == widget.taskModel.parentTaskId,
                )
                .status
                .toLowerCase() ==
            'completed';
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: (parentCompleted ? Colors.green : Colors.red).withOpacity(0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: parentCompleted ? Colors.green : Colors.red),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.link,
                size: 18,
                color: parentCompleted ? Colors.green : Colors.red,
              ),
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
              (widget.taskModel.parentTaskId != null &&
                      widget.taskModelList
                              .firstWhere(
                                (element) =>
                                    element.id == widget.taskModel.parentTaskId,
                              )
                              .status
                              .toLowerCase() ==
                          'completed')
                  ? '"$parentTitle" completed. You can check in now.'
                  : 'You must complete "$parentTitle" before starting this task.',
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
