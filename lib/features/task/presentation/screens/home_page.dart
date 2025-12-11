// ignore_for_file: deprecated_member_use

import 'package:field_task_app/features/task/presentation/screens/create_task_page.dart';
import 'package:flutter/material.dart';

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
                SizedBox(height: screenHeight * 0.03),
                _buildCompletedTasksSection(context),
              ],
            ),
          ),
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
        child: Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildActiveTasksSection(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(vertical: screenWidth * 0.02),
          child: Text(
            'ACTIVE TASKS',
            style: TextStyle(
              fontSize: isSmallScreen ? 12 : 14,
              fontWeight: FontWeight.w600,
              color: Colors.black,
              letterSpacing: 1.0,
            ),
          ),
        ),
        _buildTaskCard(
          context,
          title: 'Equipment Installation',
          time: '11:30 AM',
          address: '456 Industrial Blvd',
          dependency: null,
          status: 'In Progress',
          statusColor: Colors.blue,
        ),
        SizedBox(height: screenWidth * 0.03),
        _buildTaskCard(
          context,
          title: 'Client Meeting - TechCorp',
          time: '02:00 PM',
          address: '789 Business Center',
          dependency: null,
          status: 'Pending',
          statusColor: Colors.orange,
        ),
        SizedBox(height: screenWidth * 0.03),
        _buildTaskCard(
          context,
          title: 'Maintenance Check - Unit 5',
          time: '04:30 PM',
          address: '321 Harbor View',
          dependency: null,
          status: 'Pending',
          statusColor: Colors.orange,
        ),
        SizedBox(height: screenWidth * 0.03),
        _buildTaskCard(
          context,
          title: 'Final Report Submission',
          time: '06:00 PM',
          address: '500 Corporate Plaza',
          dependency: null,
          status: 'Pending',
          statusColor: Colors.orange,
        ),
      ],
    );
  }

  Widget _buildCompletedTasksSection(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(vertical: screenWidth * 0.02),
          child: Text(
            'COMPLETED',
            style: TextStyle(
              fontSize: isSmallScreen ? 12 : 14,
              fontWeight: FontWeight.w600,
              color: Colors.grey,
              letterSpacing: 1.0,
            ),
          ),
        ),
        _buildTaskCard(
          context,
          title: 'Site Inspection - Building A',
          time: '09:00 AM',
          address: '123 Main Street',
          dependency: null,
          status: 'Completed',
          statusColor: Colors.green,
          isCompleted: true,
        ),
      ],
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
