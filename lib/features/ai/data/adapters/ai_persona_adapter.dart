import 'package:apphoctienganh/features/ai/domain/ai_persona.dart';
import 'package:hive/hive.dart';

class AiPersonaAdapter extends TypeAdapter<AiPersonal> {
  @override
  final int typeId = 0;

  @override
  AiPersonal read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };

    return AiPersonal(
      id: fields[0] as String,
      title: fields[1] as String,
      modeTitle: fields[2] as String,
      description: fields[3] as String,
      systemPrompt: fields[4] as String,
      iconKey: fields[5] as String,
      colorValue: fields[6] as int,
    );
  }

  @override
  void write(BinaryWriter writer, AiPersonal obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.modeTitle)
      ..writeByte(3)
      ..write(obj.description)
      ..writeByte(4)
      ..write(obj.systemPrompt)
      ..writeByte(5)
      ..write(obj.iconKey)
      ..writeByte(6)
      ..write(obj.colorValue);
  }
}
