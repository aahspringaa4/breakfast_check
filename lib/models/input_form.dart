import 'package:hive_flutter/hive_flutter.dart';

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