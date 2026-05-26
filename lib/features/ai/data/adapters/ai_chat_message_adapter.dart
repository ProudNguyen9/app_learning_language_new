import 'package:apphoctienganh/features/ai/domain/ai_chat_message.dart';
import 'package:hive/hive.dart';

class AiChatMessageAdapter extends TypeAdapter<AiChatMessage> {
  @override
  final int typeId = 1;

  @override
  AiChatMessage read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };

    return AiChatMessage(
      id: fields[0] as String,
      conversationId: fields[1] as String,
      personaId: fields[2] as String,
      role: fields[3] as String,
      content: fields[4] as String,
      createdAt: fields[5] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, AiChatMessage obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.conversationId)
      ..writeByte(2)
      ..write(obj.personaId)
      ..writeByte(3)
      ..write(obj.role)
      ..writeByte(4)
      ..write(obj.content)
      ..writeByte(5)
      ..write(obj.createdAt);
  }
}
