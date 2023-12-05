import 'package:breakfast_check/models/inputForm.dart';
import 'package:hive_flutter/hive_flutter.dart';

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