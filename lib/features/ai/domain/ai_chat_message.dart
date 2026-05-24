class AiChatMessage {
  final String id;
  final String conversationId;
  final String personaId;
  final String role;
  final String content;
  final DateTime createdAt;

  const AiChatMessage({
    required this.id,
    required this.conversationId,
    required this.personaId,
    required this.role,
    required this.content,
    required this.createdAt,
  });
}
