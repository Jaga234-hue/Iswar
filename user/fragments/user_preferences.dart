import 'package:shared_preferences/shared_preferences.dart';

class UserPreferences {
  static const String userNameKey = 'user_name';
  static const String threadIdKey = 'thread_id';

  static Future<void> setUserName(String userName) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(userNameKey, userName);
  }

  static Future<String?> getUserName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(userNameKey);
  }

  static Future<void> setThreadId(String threadId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(threadIdKey, threadId);
  }

  static Future<String?> getThreadId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(threadIdKey);
  }

  static Future<void> clearUserData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(userNameKey);
    await prefs.remove(threadIdKey);
  }

  static Future<bool> isUserEnrolled() async {
    final userName = await getUserName();
    return userName != null && userName.isNotEmpty;
  }
}