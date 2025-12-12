// ignore_for_file: deprecated_member_use, unnecessary_to_list_in_spreads, use_build_context_synchronously

import 'package:field_task_app/features/task/data/repositories/task_hive_repository.dart';
import 'package:field_task_app/features/task/presentation/blocs/create_task_bloc/create_task_bloc.dart';
import 'package:field_task_app/features/task/presentation/blocs/home_cubit/home_cubit.dart';
import 'package:field_task_app/features/task/presentation/screens/create_task_page.dart';
import 'package:field_task_app/features/task/presentation/screens/task_details_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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
    final isSmallScreen = screenWidth < 360;
    final isMediumScreen = screenWidth < 400;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Field Tasks',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
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
              'ACTIVE TASKS',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            SizedBox(height: screenHeight * .01),
            _buildActiveTasksSection(context),
            // SizedBox(height: screenHeight * .02),
            // _buildActiveTasksSection(context),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blueGrey,
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => CreateTaskPage()),
          );
          // context.read<HomeCubit>().loadTasks();
        },
        child: Icon(Icons.add, color: Colors.white),
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
            return Expanded(child: const Center(child: Text("No Task")));
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
                          builder: (context) =>
                              TaskDetailsScreen(taskModel: task),
                        ),
                      );
                    },
                    context,
                    title: task.title,
                    time: "time",
                    address: "${task.latitude}, ${task.longitude}",
                    dependency: task.parentTaskId,
                    status: task.status,
                    statusColor: task.status == "completed"
                        ? Colors.green
                        : task.status == "in_progress"
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

  // Widget _buildCompletedTasksSection(BuildContext context) {
  //   return Column(
  //     crossAxisAlignment: CrossAxisAlignment.start,
  //     children: [
  //       const Text('COMPLETED', style: TextStyle(fontWeight: FontWeight.w600)),
  //       const SizedBox(height: 10),

  //       // ...completedTasks.map((task) {
  //       //   return _buildTaskCard(
  //       //     onTap: () {},
  //       //     context,
  //       //     title: task.title,
  //       //     time:
  //       //         "time",
  //       //     address: "${task.latitude}, ${task.longitude}",
  //       //     dependency: task.parentTaskId,
  //       //     status: "Completed",
  //       //     statusColor: Colors.green,
  //       //     isCompleted: true,
  //       //   );
  //       // }).toList(),
  //     ],
  //   );
  // }

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
    final isSmallScreen = screenWidth < 360;
    final isMediumScreen = screenWidth < 400;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
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
                            fontSize: isSmallScreen ? 14 : 16,
                            fontWeight: FontWeight.w600,
                            color: isCompleted ? Colors.grey : Colors.black,
                            decoration: isCompleted
                                ? TextDecoration.lineThrough
                                : TextDecoration.none,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: screenHeight * 0.008),

                        _buildDetailRow(context, Icons.access_time, time),

                        _buildDetailRow(context, Icons.location_on, address),

                        if (dependency != null) ...[
                          SizedBox(height: screenHeight * 0.004),
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

                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: isSmallScreen ? 8 : 12,
                      vertical: isSmallScreen ? 4 : 6,
                    ),
                    constraints: BoxConstraints(minWidth: screenWidth * 0.15),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Center(
                      child: Text(
                        status,
                        style: TextStyle(
                          fontSize: isSmallScreen ? 10 : 12,
                          fontWeight: FontWeight.w600,
                          color: statusColor,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
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
        Icon(icon, size: isSmallScreen ? 14 : 16, color: Colors.grey[600]),
        SizedBox(width: screenWidth * 0.015),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: isSmallScreen ? 12 : 14,
              color: Colors.grey[600],
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
