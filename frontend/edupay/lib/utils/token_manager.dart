// lib/utils/token_manager.dart

import 'package:shared_preferences/shared_preferences.dart';

class TokenManager {
  static const String _tokenKey = 'jwt_token';
  static const String _roleKey = 'user_role';
  static const String _userIdKey = 'user_id';
  static const String _usernameKey = 'username';

  /// Stores the JWT token, role, user ID, and username locally using SharedPreferences.
  static Future<void> saveAuthData({
    required String token,
    required String role,
    required int userId,
    required String username,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
    await prefs.setString(_roleKey, role);
    await prefs.setInt(_userIdKey, userId);
    await prefs.setString(_usernameKey, username);

    // Explicitly confirm what was just saved
    final savedToken = prefs.getString(_tokenKey);
    print('DEBUG: TokenManager: Auth data saved. Token: $token, Role: $role');
    print('DEBUG: TokenManager: Confirmed saved token: $savedToken'); // ADDED THIS LINE
  }

  /// Retrieves the JWT token from local storage.
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_tokenKey);
    print('DEBUG: TokenManager: Token retrieved: $token');
    return token;
  }

  /// Retrieves the user's role from local storage.
  static Future<String?> getRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_roleKey);
  }

  /// Retrieves the user's ID from local storage.
  static Future<int?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_userIdKey);
  }

  /// Retrieves the username from local storage.
  static Future<String?> getUsername() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_usernameKey);
  }

  /// Clears all stored authentication data from local storage on logout.
  static Future<void> clearAuthData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_roleKey);
    await prefs.remove(_userIdKey);
    await prefs.remove(_usernameKey);
    print('DEBUG: TokenManager: Auth data cleared.');
  }
}
