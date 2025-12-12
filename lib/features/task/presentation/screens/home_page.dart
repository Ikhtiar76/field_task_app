// ignore_for_file: deprecated_member_use, unnecessary_to_list_in_spreads, use_build_context_synchronously

import 'package:field_task_app/core/constants/colors.dart';
import 'package:field_task_app/core/models/task_model.dart';
import 'package:field_task_app/core/widgets/status_badge.dart';
import 'package:field_task_app/features/task/presentation/blocs/create_task_bloc/create_task_bloc.dart';
import 'package:field_task_app/features/task/presentation/screens/create_task_page.dart';
import 'package:field_task_app/features/task/presentation/screens/task_details_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  static const id = "home_page";

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Field Tasks',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        elevation: 0,
        backgroundColor: white,
        foregroundColor: black,
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: screenWidth * 0.05,
          vertical: screenHeight * 0.02,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'ALL TASKS',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            SizedBox(height: screenHeight * .01),
            _buildActiveTasksSection(context),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blueGrey,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => CreateTaskPage()),
          );
        },
        child: Icon(Icons.add, color: white),
      ),
    );
  }

  Widget _buildActiveTasksSection(BuildContext context) {
    return BlocBuilder<CreateTaskBloc, CreateTaskState>(
      builder: (context, state) {
        if (state is TasksLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is TasksLoaded) {
          if (state.taskList.isEmpty) {
            return Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.newspaper,
                      color: grey.withOpacity(0.5),
                      size: 100,
                    ),
                    Text("No Task Available"),
                  ],
                ),
              ),
            );
          } else {
            return Expanded(
              child: ListView.builder(
                itemCount: state.taskList.length,
                itemBuilder: (context, index) {
                  final task = state.taskList[index];
                  return _buildTaskCard(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => TaskDetailsScreen(
                            taskModel: task,
                            taskModelList: state.taskList,
                          ),
                        ),
                      );
                    },
                    context,
                    title: task.title,
                    time:
                        '${task.dueTime}, ${DateFormat.yMMMd().format(DateTime.parse(task.dueDate ?? ''))}',
                    address:
                        "${task.latitude?.toStringAsFixed(4)}, ${task.longitude?.toStringAsFixed(4)}",
                    dependency: state.taskList
                        .firstWhere(
                          (element) => element.id == task.parentTaskId,
                          orElse: () => TaskModel(id: '', title: ''),
                        )
                        .title,
                    status: task.status,
                    statusColor: task.status.toLowerCase() == "completed"
                        ? Colors.green
                        : task.status.toLowerCase() == "in progress"
                        ? Colors.blue
                        : Colors.orange,
                  );
                },
              ),
            );
          }
        } else if (state is TasksError) {
          return Center(child: Text(state.error));
        }
        return Container();
      },
    );
  }

  Widget _buildTaskCard(
    BuildContext context, {
    required void Function() onTap,
    required String title,
    required String time,
    required String address,
    required String? dependency,
    required String status,
    required Color statusColor,

    bool isCompleted = false,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: white,
          borderRadius: BorderRadius.circular(6),
        ),
        margin: EdgeInsets.only(bottom: screenHeight * .01),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.all(screenWidth * 0.04),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: isCompleted ? grey : black,
                            decoration: isCompleted
                                ? TextDecoration.lineThrough
                                : TextDecoration.none,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: screenHeight * 0.01),

                        _buildDetailRow(context, Icons.access_time, time),
                        SizedBox(height: screenHeight * 0.005),
                        _buildDetailRow(context, Icons.location_on, address),

                        if (dependency != null && dependency != '') ...[
                          SizedBox(height: screenHeight * 0.008),
                          _buildDetailRow(
                            context,
                            Icons.link,
                            dependency,
                            isItalic: true,
                          ),
                        ],
                      ],
                    ),
                  ),

                  StatusBadge(status: status),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(
    BuildContext context,
    IconData icon,
    String text, {
    bool isItalic = false,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: isSmallScreen ? 14 : 16, color: grey.withOpacity(0.6)),
        SizedBox(width: screenWidth * 0.015),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: isSmallScreen ? 12 : 14,
              color: grey.withOpacity(0.6),
              fontStyle: isItalic ? FontStyle.italic : FontStyle.normal,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
