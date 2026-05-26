class SpeakingLesson {
  SpeakingLesson({
    required this.id,
    required this.title,
    required this.content,
    required this.level,
    required this.createdAt,
    this.source = 'manual',
  });

  final String id;
  final String title;
  final String content;
  final String level;
  final DateTime createdAt;
  final String source;

  String get preview {
    final normalized = content.replaceAll('\n', ' ').trim();
    if (normalized.length <= 110) {
      return normalized;
    }
    return '${normalized.substring(0, 110).trim()}...';
  }

  String get estimatedDuration {
    final wordCount =
        content
            .trim()
            .split(RegExp(r'\s+'))
            .where((word) => word.isNotEmpty)
            .length;
    final minutes = (wordCount / 110).ceil().clamp(1, 15);
    return '$minutes phút';
  }

  SpeakingLesson copyWith({
    String? id,
    String? title,
    String? content,
    String? level,
    DateTime? createdAt,
    String? source,
  }) {
    return SpeakingLesson(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      level: level ?? this.level,
      createdAt: createdAt ?? this.createdAt,
      source: source ?? this.source,
    );
  }
}
