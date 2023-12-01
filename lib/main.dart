import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

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
  final List<InputForm> users = [
    InputForm(name: '유현명', isCheck: false),
    InputForm(name: '김민채', isCheck: false),
    InputForm(name: 'adbr', isCheck: false),
  ];

  @override
  void initState() {
    super.initState();
    _loadChecks();
  }

  _loadChecks() async {
    var box = await Hive.openBox<InputForm>('checks');
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

  _saveCheck(int index, bool value) async {
    var box = await Hive.openBox<InputForm>('checks');
    var user = box.getAt(index);
    if (user != null) {
      user.isCheck = value;
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
          return CheckboxListTile(
            title: Text(users[index].name),
            value: users[index].isCheck,
            onChanged: (value) => _toggleCheck(index, value),
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
  });

  @HiveField(0)
  String name;

  @HiveField(1)
  bool isCheck;
}

class InputFormAdapter extends TypeAdapter<InputForm> {
  @override
  final typeId = 0;

  @override
  InputForm read(BinaryReader reader) {
    return InputForm(
      name: reader.read(),
      isCheck: reader.read(),
    );
  }

  @override
  void write(BinaryWriter writer, InputForm obj) {
    writer.write(obj.name);
    writer.write(obj.isCheck);
  }
}
