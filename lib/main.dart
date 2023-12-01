import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';

void main() async {
  await Hive.initFlutter();
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
    InputForm(name: '유현명', isCheck: false),
    InputForm(name: '김민채', isCheck: false),
    InputForm(name: 'adbr', isCheck: false),
  ];

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
    return Scaffold(
      appBar: AppBar(
        title: Text('조식 체크 앱'),
      ),
      body: ListView.builder(
        itemCount: users.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(users[index].name),
            trailing: users[index].isCheck && users[index].checkedTime != null
                ? Text(DateFormat('yy년 MM월 dd일 HH시 mm분 ss초').format(users[index].checkedTime!))
                : null,
            leading: Checkbox(
              value: users[index].isCheck,
              onChanged: (value) => _toggleCheck(index, value),
            ),
          );
        },
      ),
    );
  }
}

class InputForm {
  InputForm({
    required this.name,
    required this.isCheck,
    this.checkedTime,
  });

  @HiveField(0)
  String name;

  @HiveField(1)
  bool isCheck;

  @HiveField(2)
  DateTime? checkedTime;
}

class InputFormAdapter extends TypeAdapter<InputForm> {
  @override
  final typeId = 0;

  @override
  InputForm read(BinaryReader reader) {
    return InputForm(
      name: reader.read(),
      isCheck: reader.read(),
      checkedTime: reader.read(),
    );
  }

  @override
  void write(BinaryWriter writer, InputForm obj) {
    writer.write(obj.name);
    writer.write(obj.isCheck);
    writer.write(obj.checkedTime);
  }
}
