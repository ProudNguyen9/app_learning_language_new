class ReadingLesson {
  ReadingLesson({
    required this.id,
    required this.title,
    required this.content,
    required this.level,
    required this.createdAt,
    this.source = 'manual',
    this.translationMode = 'full_passage',
  });

  final String id;
  final String title;
  final String content;
  final String level;
  final DateTime createdAt;
  final String source;
  final String translationMode;

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
    final minutes = (wordCount / 120).ceil().clamp(1, 15);
    return '$minutes phút';
  }

  ReadingLesson copyWith({
    String? id,
    String? title,
    String? content,
    String? level,
    DateTime? createdAt,
    String? source,
    String? translationMode,
  }) {
    return ReadingLesson(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      level: level ?? this.level,
      createdAt: createdAt ?? this.createdAt,
      source: source ?? this.source,
      translationMode: translationMode ?? this.translationMode,
    );
  }
}
