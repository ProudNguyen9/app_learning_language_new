import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class StreakCheckInResult {
  const StreakCheckInResult({
    required this.isNewDay,
    required this.streakDays,
    required this.checkedInAt,
  });

  final bool isNewDay;
  final int streakDays;
  final DateTime checkedInAt;
}

class StreakProvider extends ChangeNotifier {
  static const String _tableName = 'user_streaks';
  static const String _currentStreakKey = 'current_streak';
  static const String _lastStudyDateKey = 'last_study_date';
  static const String _totalStudyDaysKey = 'total_study_days';
  static const String _studyHistoryKey = 'study_history';

  final SupabaseClient _supabase = Supabase.instance.client;
  int _currentStreak = 0;
  int _totalStudyDays = 0;
  DateTime? _lastStudyDate;
  Set<String> _studyHistory = <String>{};
  bool _isInitialized = false;
  String? _loadedSupabaseUserId;

  int get currentStreak => _currentStreak;
  int get totalStudyDays => _totalStudyDays;
  DateTime? get lastStudyDate => _lastStudyDate;
  bool get isInitialized => _isInitialized;

  List<bool> get weeklyActivity {
    final now = _normalizeDate(DateTime.now());
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));

    return List<bool>.generate(7, (index) {
      final day = startOfWeek.add(Duration(days: index));
      return _studyHistory.contains(_dateKey(day));
    });
  }

  Future<void> initialize() async {
    if (_isInitialized) {
      await refreshFromSupabase();
      return;
    }

    final user = _supabase.auth.currentUser;
    if (user != null) {
      await _loadFromSupabase(user.id);
    } else {
      _resetState();
    }

    _isInitialized = true;
    notifyListeners();
  }

  Future<void> refreshFromSupabase({bool force = false}) async {
    final user = _supabase.auth.currentUser;
    if (user == null) {
      _loadedSupabaseUserId = null;
      return;
    }

    if (!force && _loadedSupabaseUserId == user.id) {
      return;
    }

    await _loadFromSupabase(user.id);
    notifyListeners();
  }

  Future<void> _loadFromSupabase(String userId) async {
    try {
      final row =
          await _supabase
              .from(_tableName)
              .select()
              .eq('user_id', userId)
              .maybeSingle();

      if (row == null) {
        _resetState();
        _loadedSupabaseUserId = userId;
        return;
      }

      _currentStreak = (row[_currentStreakKey] as int?) ?? 0;
      _totalStudyDays = (row[_totalStudyDaysKey] as int?) ?? 0;

      final rawLastStudyDate = row[_lastStudyDateKey];
      if (rawLastStudyDate is String && rawLastStudyDate.isNotEmpty) {
        _lastStudyDate = DateTime.tryParse(rawLastStudyDate);
      }

      final rawStudyHistory = row[_studyHistoryKey];
      if (rawStudyHistory is List) {
        _studyHistory = rawStudyHistory.map((item) => item.toString()).toSet();
      }

      _loadedSupabaseUserId = userId;
    } catch (error) {
      debugPrint('Không thể tải streak từ Supabase: $error');
    }
  }

  Future<StreakCheckInResult> recordStudySession() async {
    await initialize();
    await refreshFromSupabase();

    final today = _normalizeDate(DateTime.now());
    final previousDate =
        _lastStudyDate == null ? null : _normalizeDate(_lastStudyDate!);

    var isNewDay = false;

    if (previousDate == null) {
      _currentStreak = 1;
      _totalStudyDays = 1;
      isNewDay = true;
    } else {
      final difference = today.difference(previousDate).inDays;
      if (difference > 0) {
        _currentStreak = difference == 1 ? _currentStreak + 1 : 1;
        _totalStudyDays += 1;
        isNewDay = true;
      }
    }

    _lastStudyDate = today;
    _studyHistory.add(_dateKey(today));

    final user = _supabase.auth.currentUser;
    if (user != null) {
      await _syncToSupabase(user.id);
    }

    notifyListeners();

    return StreakCheckInResult(
      isNewDay: isNewDay,
      streakDays: _currentStreak,
      checkedInAt: today,
    );
  }

  Future<void> _syncToSupabase(String userId) async {
    try {
      await _supabase.from(_tableName).upsert({
        'user_id': userId,
        _currentStreakKey: _currentStreak,
        _totalStudyDaysKey: _totalStudyDays,
        _lastStudyDateKey:
            _lastStudyDate == null ? null : _dateKey(_lastStudyDate!),
        _studyHistoryKey: _studyHistory.toList()..sort(),
        'updated_at': DateTime.now().toIso8601String(),
      });
    } catch (error) {
      debugPrint('Không thể đồng bộ streak lên Supabase: $error');
    }
  }

  void _resetState() {
    _currentStreak = 0;
    _totalStudyDays = 0;
    _lastStudyDate = null;
    _studyHistory = <String>{};
  }

  DateTime _normalizeDate(DateTime value) {
    return DateTime(value.year, value.month, value.day);
  }

  String _dateKey(DateTime value) {
    final normalized = _normalizeDate(value);
    final month = normalized.month.toString().padLeft(2, '0');
    final day = normalized.day.toString().padLeft(2, '0');
    return '${normalized.year}-$month-$day';
  }
}
