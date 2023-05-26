// ignore_for_file: prefer_const_constructors

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool test = true;
  bool _wrongPasswword = false;
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _dbBox = Hive.box('dbBox');
  getToken({required String username, required String password}) async {
    var url = Uri.parse('https://Todo.sheikhumaid.repl.co/login/');
    setState(() {
      test = !test;
    });
    var response = await http.post(url, body: {
      "username": username,
      "password": password,
    });
    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      var tokenId = data['token'];
      await _dbBox.delete('token');
      if (tokenId == null) {
        setState(() {
          _wrongPasswword = true;
          test = !test;
        });
      } else {
        setState(() {
          test = !test;
        });
        await _dbBox.put('token', tokenId);
        Navigator.popAndPushNamed(context, 'main/');
        debugPrint(tokenId);
      }
    } else {
      debugPrint('${response.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.red[200],
        appBar: AppBar(
          title: const Text(
            'To Do',
            style: TextStyle(color: Colors.black),
          ),
          centerTitle: true,
          elevation: 0,
        ),
        body: Column(
          // mainAxisAlignment: MainAxisAlignment.center,
          // crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              height: 50,
            ),
            Container(
              alignment: Alignment.center,
              height: 120,
              width: 120,
              child: Image.asset('assets/images/login.png'),
            ),
            SizedBox(
              height: 25,
            ),
            Container(
              padding: EdgeInsets.all(12),
              child: TextField(
                controller: _usernameController,
                decoration: InputDecoration(
                    label: Text('Username'), border: OutlineInputBorder()),
              ),
            ),
            Container(
              padding: EdgeInsets.all(12),
              child: TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                    label: Text('Password'), border: OutlineInputBorder()),
              ),
            ),
            Container(
              padding: EdgeInsets.only(left: 15),
              alignment: Alignment.centerLeft,
              child: Text(
                'Oops! Wrong username or password',
                style: TextStyle(
                  color: _wrongPasswword ? Colors.red : Colors.red[200],
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.all(15),
              child: MaterialButton(
                height: 45,
                minWidth: double.infinity,
                color: Colors.red,
                onPressed: () => getToken(
                    username: _usernameController.text,
                    password: _passwordController.text),
                child: !test
                    ? CircularProgressIndicator(
                        color: Colors.black,
                      )
                    : Text('Login'),
              ),
            ),
            Container(
              padding: EdgeInsets.only(left: 15),
              alignment: Alignment.centerLeft,
              child: InkWell(
                onTap: () {
                  Navigator.pushNamed(context, "register/");
                },
                child: Text(
                  'New user? Signup here!',
                  style: TextStyle(color: Colors.blue),
                ),
              ),
            )
          ],
        ));
  }
}
