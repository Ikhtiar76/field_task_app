import 'package:field_task_app/features/task/data/repositories/task_hive_repository.dart';
import 'package:field_task_app/features/task/presentation/blocs/create_task_bloc/create_task_bloc.dart';
import 'package:field_task_app/features/task/presentation/screens/home_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider(
      create: (context) => TaskHiveRepository(),
      child: BlocProvider(
        create: (context) => CreateTaskBloc(
          taskHiveRepository: RepositoryProvider.of<TaskHiveRepository>(
            context,
          ),
        )..add(InitTaskBox()),
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            primarySwatch: Colors.blue,
            scaffoldBackgroundColor: const Color(0xFFf5f5f5),
            useMaterial3: true,
            appBarTheme: AppBarTheme(
              backgroundColor: Colors.white,
              elevation: 0,
              shape: Border(bottom: BorderSide(color: Colors.grey.shade300)),
              centerTitle: true,
            ),
          ),
          title: 'Field Task App',
          home: const HomePage(),
        ),
      ),
    );
  }
}
