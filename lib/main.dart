import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() async {
  await Hive.initFlutter();
  await initializeDateFormatting('ko_KR', null);
  Hive.registerAdapter(InputFormAdapter());
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
      darkTheme: ThemeData.dark(),
      themeMode: ThemeMode.system,
      home: BreakfastCheckPage(),
    );
  }
}

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
  bool isDarkMode = false; // Added dark mode state

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

class InputForm {
  InputForm({
    required this.name,
    required this.enName,
    required this.isCheck,
    this.checkedTime,
  });

  @HiveField(0)
  String name;

  @HiveField(1)
  String enName;

  @HiveField(2)
  bool isCheck;

  @HiveField(3)
  DateTime? checkedTime;
}

class InputFormAdapter extends TypeAdapter<InputForm> {
  @override
  final typeId = 0;

  @override
  InputForm read(BinaryReader reader) {
    return InputForm(
      name: reader.read(),
      enName: reader.read(),
      isCheck: reader.read(),
      checkedTime: reader.read(),
    );
  }

  @override
  void write(BinaryWriter writer, InputForm obj) {
    writer.write(obj.name);
    writer.write(obj.enName);
    writer.write(obj.isCheck);
    writer.write(obj.checkedTime);
  }
}
