import 'package:breakfast_check/models/input_form.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';

class BreakfastCheckPage extends StatefulWidget {
  const BreakfastCheckPage({super.key});

  @override
  BreakfastCheckPageState createState() => BreakfastCheckPageState();
}

class BreakfastCheckPageState extends State<BreakfastCheckPage> {
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
      for (var user in users) {
        box.add(user);
      }
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

  void clickCheckBox(int index, bool? value) {
    if (value != null) {
      setState(() {});
      users[index].isCheck = value;
      _saveCheck(index, value);
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
          title: const Text(
            '조식 체크 앱',
            style: TextStyle(fontFamily: 'Jalnan2'),
          ),
          actions: <Widget>[
            IconButton(
              icon: const Icon(Icons.dark_mode),
              onPressed: () {
                setState(() {
                  isDarkMode = !isDarkMode;
                });
              },
            ),
            IconButton(
              icon: const Icon(Icons.language),
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
              title: Text(
                isEnglishMode ? users[index].enName : users[index].name,
                style: const TextStyle(fontFamily: 'Jalnan2'),
              ),
              leading: Checkbox(
                value: users[index].isCheck,
                onChanged: (value) => clickCheckBox(index, value),
              ),
              trailing: users[index].isCheck && users[index].checkedTime != null
                  ? Text(DateFormat(
                      isEnglishMode ? 'EEE dd MM\n yyyy h:mm:ss a' : 'yyyy년 MM월 dd일 (E)\n a HH시 mm분 ss초',
                      isEnglishMode ? 'en_US' : 'ko_KR').format(users[index].checkedTime!))
                  : null,
            );
          },
        ),
      ),
    );
  }
}