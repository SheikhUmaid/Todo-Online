import 'package:flutter/material.dart';
import 'package:todo_online/pages/home.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:todo_online/pages/login.dart';
import 'package:todo_online/pages/register.dart';

void main() async {
  await Hive.initFlutter();
  var box = await Hive.openBox('dbBox');
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});
  final _dbBox = Hive.box('dbBox');
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.red,
      ),
      routes: {
        "/": _dbBox.get('token') == null
            ? (context) => const LoginPage()
            : (context) => const MyHomePage(),
        "main/": (context) => const MyHomePage(),
        "register/": (context) => const RegisterPage(),
      },
    );
  }
}
