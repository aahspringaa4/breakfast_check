import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '조식 체크 앱',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: BreakfastCheckPage(),
    );
  }
}

class BreakfastCheckPage extends StatefulWidget {
  @override
  _BreakfastCheckPageState createState() => _BreakfastCheckPageState();
}

class _BreakfastCheckPageState extends State<BreakfastCheckPage> {
  final List<String> users = ['유현명', '김민채', 'adbr'];
  Map<String, bool> userChecks = {};

  @override
  void initState() {
    super.initState();
    _loadChecks();
  }

  _loadChecks() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    users.forEach((user) {
      userChecks[user] = (prefs.getBool(user) ?? false);
    });
    setState(() {});
  }

  _saveCheck(String user, bool value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool(user, value);
  }

  void _toggleCheck(String user, bool? value) {
    if (value != null) {
      setState(() {
        userChecks[user] = value;
        _saveCheck(user, value);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('조식 체크 앱'),
      ),
      body: ListView.builder(
        itemCount: users.length,
        itemBuilder: (context, index) {
          return CheckboxListTile(
            title: Text(users[index]),
            value: userChecks[users[index]],
            onChanged: (value) => _toggleCheck(users[index], value),
          );
        },
      ),
    );
  }
}
