import 'package:breakfast_check/models/inputform.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';

class BreakfastCheckPage extends StatefulWidget {
  @override
  _BreakfastCheckPageState createState() => _BreakfastCheckPageState();
}

class _BreakfastCheckPageState extends State<BreakfastCheckPage> {
  late final Box<InputForm> box;
  final List<InputForm> users = [
    InputForm(name: '유현명', enName: 'Hyun', isCheck: false),
    InputForm(name: '김민채', enName: 'David', isCheck: false),
    InputForm(name: 'adbr', enName: 'bora', isCheck: false),
  ];

  bool isEnglishMode = false;
  bool isDarkMode = false;

  @override
  void initState() {
    super.initState();
    _openBox();
  }

  _openBox() async {
    box = await Hive.openBox<InputForm>('checks');
    _loadChecks();
  }

  _loadChecks() {
    if (box.isNotEmpty) {
      users.clear();
      users.addAll(box.values);
    } else {
      users.forEach((user) {
        box.add(user);
      });
    }
    setState(() {});
  }

  _saveCheck(int index, bool value) {
    var user = box.getAt(index);
    if (user != null) {
      user.isCheck = value;
      if (value) {
        user.checkedTime = DateTime.now();
      } else {
        user.checkedTime = null;
      }
      box.putAt(index, user);
    }
  }

  void _toggleCheck(int index, bool? value) {
    if (value != null) {
      setState(() {
        users[index].isCheck = value;
        _saveCheck(index, value);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '조식 체크 앱',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      darkTheme: ThemeData.dark(),
      themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
      home: Scaffold(
        appBar: AppBar(
          title: Text('조식 체크 앱'),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.dark_mode),
              onPressed: () {
                setState(() {
                  isDarkMode = !isDarkMode;
                });
              },
            ),
            IconButton(
              icon: Icon(Icons.language),
              onPressed: () {
                setState(() {
                  isEnglishMode = !isEnglishMode;
                });
              },
            ),
          ],
        ),
        body: ListView.builder(
          itemCount: users.length,
          itemBuilder: (context, index) {
            return ListTile(
              title: Text(isEnglishMode ? users[index].enName : users[index].name),
              trailing: users[index].isCheck && users[index].checkedTime != null
                  ? Text(DateFormat(
                      isEnglishMode ? 'yyyy-MM-dd (E) a hh:mm:ss' : 'yy년 MM월 dd일 (E) a HH시 mm분 ss초',
                      isEnglishMode ? 'en_US' : 'ko_KR').format(users[index].checkedTime!))
                  : null,
              leading: Checkbox(
                value: users[index].isCheck,
                onChanged: (value) => _toggleCheck(index, value),
              ),
            );
          },
        ),
      ),
    );
  }
}