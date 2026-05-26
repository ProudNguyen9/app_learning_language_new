import 'package:apphoctienganh/features/ai/domain/ai_chat_message.dart';
import 'package:hive/hive.dart';

class AiChatLocalDataSource {
  static const String boxName = 'ai_chat_messages';

  Box<AiChatMessage> get _box => Hive.box<AiChatMessage>(boxName);

  Future<void> saveMessage(AiChatMessage message) async {
    await _box.put(message.id, message);
  }

  Future<void> saveMessages(List<AiChatMessage> messages) async {
    for (final message in messages) {
      await _box.put(message.id, message);
    }
  }

  List<AiChatMessage> getMessagesByConversation(String conversationId) {
    final messages =
        _box.values
            .where((message) => message.conversationId == conversationId)
            .toList();

    messages.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    return messages;
  }

  List<AiChatMessage> getMessagesByPersona(String personaId) {
    final messages =
        _box.values.where((message) => message.personaId == personaId).toList();

    messages.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    return messages;
  }

  Future<void> deleteMessage(String messageId) async {
    await _box.delete(messageId);
  }

  Future<void> deleteConversation(String conversationId) async {
    final keysToDelete = <dynamic>[];

    for (final entry in _box.toMap().entries) {
      final message = entry.value;
      if (message.conversationId == conversationId) {
        keysToDelete.add(entry.key);
      }
    }

    await _box.deleteAll(keysToDelete);
  }

  Future<void> clearAllMessages() async {
    await _box.clear();
  }
}
