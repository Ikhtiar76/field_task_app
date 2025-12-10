import 'package:field_task_app/presentation/screens/task_list_page.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: const Color(0xFFf5f5f5),
        useMaterial3: true,
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.white, // Custom AppBar color
          elevation: 0,
          shape: Border(bottom: BorderSide(color: Colors.grey.shade300)),
          centerTitle: true,
        ),
      ),
      title: 'Field Task App',
      home: const TasksListPage(),
    );
  }
}
