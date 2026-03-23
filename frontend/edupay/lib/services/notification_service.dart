// lib/services/notification_service.dart
// Service for real-time WebSocket notifications and REST notification API

import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:stomp_dart_client/stomp_dart_client.dart';
import 'package:edupay_app/constants/api_constants.dart';
import 'package:edupay_app/models/notification_message.dart';
import 'package:edupay_app/utils/token_manager.dart';

class NotificationWsService {
  StompClient? _stompClient;
  final _notificationController =
      StreamController<NotificationMessage>.broadcast();

  /// Stream of incoming WebSocket notifications
  Stream<NotificationMessage> get notificationStream =>
      _notificationController.stream;

  bool _isConnected = false;
  bool get isConnected => _isConnected;

  /// Connect to the WebSocket and subscribe to the user's notification topic
  Future<void> connect() async {
    final token = await TokenManager.getToken();
    final userId = await TokenManager.getUserId();
    if (token == null || userId == null) return;

    // Build WebSocket URL from base URL
    final baseUrl = ApiConstants.BASE_URL.replaceFirst('/api', '');
    final wsUrl = '$baseUrl/ws';

    _stompClient = StompClient(
      config: StompConfig.sockJS(
        url: wsUrl,
        stompConnectHeaders: {
          'Authorization': 'Bearer $token',
        },
        webSocketConnectHeaders: {
          'Authorization': 'Bearer $token',
        },
        onConnect: (StompFrame frame) {
          _isConnected = true;

          // Subscribe to user-specific notification topic
          _stompClient?.subscribe(
            destination: '/topic/notifications/$userId',
            callback: (StompFrame frame) {
              if (frame.body != null) {
                try {
                  final data =
                      jsonDecode(frame.body!) as Map<String, dynamic>;
                  final notification = NotificationMessage.fromJson(data);
                  _notificationController.add(notification);
                } catch (e) {
                  // Ignore malformed messages
                }
              }
            },
          );
        },
        onDisconnect: (StompFrame frame) {
          _isConnected = false;
        },
        onWebSocketError: (dynamic error) {
          _isConnected = false;
        },
        // Heartbeat to keep connection alive
        heartbeatIncoming: const Duration(seconds: 10),
        heartbeatOutgoing: const Duration(seconds: 10),
      ),
    );

    _stompClient?.activate();
  }

  /// Disconnect from WebSocket
  void disconnect() {
    _stompClient?.deactivate();
    _isConnected = false;
  }

  /// Dispose resources
  void dispose() {
    disconnect();
    _notificationController.close();
  }

  // ===== REST API Methods =====

  /// Fetch all notifications for the current user
  Future<List<NotificationMessage>> getNotifications() async {
    final token = await TokenManager.getToken();
    if (token == null) throw Exception('Not authenticated');

    final url = Uri.parse('${ApiConstants.BASE_URL}/notifications');
    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final list = jsonDecode(response.body) as List;
      return list
          .map((json) =>
              NotificationMessage.fromJson(json as Map<String, dynamic>))
          .toList();
    }
    throw Exception('Failed to fetch notifications');
  }

  /// Get unread notification count
  Future<int> getUnreadCount() async {
    final token = await TokenManager.getToken();
    if (token == null) return 0;

    final url = Uri.parse('${ApiConstants.BASE_URL}/notifications/unread');
    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return data['count'] as int? ?? 0;
    }
    return 0;
  }

  /// Mark a notification as read
  Future<void> markAsRead(int notificationId) async {
    final token = await TokenManager.getToken();
    if (token == null) return;

    final url =
        Uri.parse('${ApiConstants.BASE_URL}/notifications/$notificationId/read');
    await http.put(
      url,
      headers: {'Authorization': 'Bearer $token'},
    );
  }
}
