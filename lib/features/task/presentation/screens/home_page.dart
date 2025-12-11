// ignore_for_file: deprecated_member_use, unnecessary_to_list_in_spreads

import 'package:field_task_app/features/task/presentation/blocs/create_task_bloc/create_task_bloc.dart';
import 'package:field_task_app/features/task/presentation/blocs/home_cubit/home_cubit.dart';
import 'package:field_task_app/features/task/presentation/screens/create_task_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});
  static const id = "home_page";

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
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: screenWidth * 0.04,
              vertical: screenHeight * 0.02,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildActiveTasksSection(context),
                SizedBox(height: screenHeight * .02),
                _buildCompletedTasksSection(context),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blueGrey,
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => BlocProvider(
                create: (context) => CreateTaskBloc(),
                child: CreateTaskPage(),
              ),
            ),
          );
          context.read<HomeCubit>().loadTasks();
        },
        child: Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildActiveTasksSection(BuildContext context) {
    return BlocBuilder<HomeCubit, HomeState>(
      builder: (context, state) {
        final activeTasks = state.tasks
            .where((t) => t.isCompleted == false)
            .toList();

        if (activeTasks.isEmpty) {
          return const Text("No Active Tasks");
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'ACTIVE TASKS',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 10),

            ...activeTasks.map((task) {
              return _buildTaskCard(
                context,
                title: task.title,
                time:
                    "${task.dueHour}:${task.dueMinute.toString().padLeft(2, '0')}",
                address: "${task.latitude}, ${task.longitude}",
                dependency: task.parentTaskId,
                status: "Pending",
                statusColor: Colors.orange,
              );
            }).toList(),
          ],
        );
      },
    );
  }

  Widget _buildCompletedTasksSection(BuildContext context) {
    return BlocBuilder<HomeCubit, HomeState>(
      builder: (context, state) {
        final completedTasks = state.tasks.where((t) => t.isCompleted).toList();

        if (completedTasks.isEmpty) {
          return const Text("No Completed Tasks");
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'COMPLETED',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 10),

            ...completedTasks.map((task) {
              return _buildTaskCard(
                context,
                title: task.title,
                time:
                    "${task.dueHour}:${task.dueMinute.toString().padLeft(2, '0')}",
                address: "${task.latitude}, ${task.longitude}",
                dependency: task.parentTaskId,
                status: "Completed",
                statusColor: Colors.green,
                isCompleted: true,
              );
            }).toList(),
          ],
        );
      },
    );
  }

  Widget _buildTaskCard(
    BuildContext context, {
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

    return Container(
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
