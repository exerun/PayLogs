import 'package:shared_preferences/shared_preferences.dart';

class SettingsService {
  static const String _dailyTargetKey = 'daily_target';
  static const String _monthlyTargetKey = 'monthly_target';

  // Default values
  static const double _defaultDailyTarget = 500.0;
  static const double _defaultMonthlyTarget = 15000.0;

  /// Get daily expense target
  static Future<double> getDailyTarget() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(_dailyTargetKey) ?? _defaultDailyTarget;
  }

  /// Set daily expense target
  static Future<void> setDailyTarget(double target) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_dailyTargetKey, target);
  }

  /// Get monthly expense target
  static Future<double> getMonthlyTarget() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(_monthlyTargetKey) ?? _defaultMonthlyTarget;
  }

  /// Set monthly expense target
  static Future<void> setMonthlyTarget(double target) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_monthlyTargetKey, target);
  }

  /// Get both targets at once
  static Future<Map<String, double>> getTargets() async {
    final daily = await getDailyTarget();
    final monthly = await getMonthlyTarget();
    return {
      'daily': daily,
      'monthly': monthly,
    };
  }
}
