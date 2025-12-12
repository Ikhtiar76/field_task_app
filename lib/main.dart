import 'package:field_task_app/core/constants/colors.dart';
import 'package:field_task_app/features/task/data/repositories/task_repository_impl.dart';
import 'package:field_task_app/features/task/presentation/blocs/create_task_bloc/create_task_bloc.dart';
import 'package:field_task_app/features/task/presentation/screens/home_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await Hive.initFlutter();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider(
      create: (context) => TaskRepositoryImpl(),
      child: BlocProvider(
        create: (context) => CreateTaskBloc(
          taskHiveRepository: RepositoryProvider.of<TaskRepositoryImpl>(
            context,
          ),
        )..add(InitTaskBox()),
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            scaffoldBackgroundColor: const Color(0xFFf5f5f5),
            useMaterial3: false,
            appBarTheme: AppBarTheme(
              backgroundColor: white,
              elevation: 0,
              shape: Border(bottom: BorderSide(color: grey.withOpacity(0.3))),
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
