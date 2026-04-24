import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:signalr_netcore/signalr_client.dart';

import '../constants/api_constants.dart';
import '../constants/storage_constants.dart';
import '../network/dio_client.dart';

typedef RoleChangedCallback = void Function(String roleName);

class RoleChangeHubService {
  RoleChangeHubService({
    required DioClient dioClient,
    required SharedPreferences sharedPreferences,
  })  : _dioClient = dioClient,
        _sharedPreferences = sharedPreferences;

  final DioClient _dioClient;
  final SharedPreferences _sharedPreferences;
  HubConnection? _connection;
  RoleChangedCallback? _onCurrentUserRoleChanged;
  bool _isStarting = false;

  Future<void> start({
    required RoleChangedCallback onCurrentUserRoleChanged,
  }) async {
    _onCurrentUserRoleChanged = onCurrentUserRoleChanged;

    final token = _sharedPreferences.getString(StorageConstants.accessToken);
    if (token == null || token.isEmpty || _isStarting) return;
    if (_connection?.state == HubConnectionState.Connected) return;

    _isStarting = true;
    try {
      _connection ??= _buildConnection();
      await _connection!.start();
      debugPrint('RoleChangeHub connected: ${ApiConstants.roleChangeHubUrl}');
    } catch (e) {
      debugPrint('RoleChangeHub connection error: $e');
    } finally {
      _isStarting = false;
    }
  }

  Future<void> stop() async {
    _onCurrentUserRoleChanged = null;
    final connection = _connection;
    _connection = null;
    if (connection == null) return;

    try {
      await connection.stop();
    } catch (e) {
      debugPrint('RoleChangeHub stop error: $e');
    }
  }

  HubConnection _buildConnection() {
    final options = HttpConnectionOptions(
      accessTokenFactory: () async =>
          _sharedPreferences.getString(StorageConstants.accessToken) ?? '',
      transport: HttpTransportType.WebSockets,
      requestTimeout: 10000,
    );

    final connection = HubConnectionBuilder()
        .withUrl(ApiConstants.roleChangeHubUrl, options: options)
        .withAutomaticReconnect(
            retryDelays: [2000, 5000, 10000, 20000]).build();

    for (final eventName in _roleChangeEventNames) {
      connection.on(eventName, (arguments) {
        _handleRoleChange(arguments, eventName);
      });
    }

    connection.onclose(({error}) {
      debugPrint('RoleChangeHub closed: $error');
    });

    return connection;
  }

  Future<void> _handleRoleChange(
    List<Object?>? arguments,
    String eventName,
  ) async {
    debugPrint('RoleChangeHub event $eventName: $arguments');

    final currentUserId = _currentUserId;
    final eventUserId = _extractUserId(arguments);
    if (eventUserId != null &&
        currentUserId != null &&
        eventUserId != currentUserId) {
      return;
    }

    final roleFromEvent = _extractRoleName(arguments);
    final roleName =
        roleFromEvent ?? await _fetchCurrentUserRole(currentUserId);
    if (roleName == null || roleName.isEmpty) return;

    await _sharedPreferences.setString(StorageConstants.userRole, roleName);
    _onCurrentUserRoleChanged?.call(roleName);
  }

  Future<String?> _fetchCurrentUserRole(int? currentUserId) async {
    if (currentUserId == null) return null;

    try {
      final token = _sharedPreferences.getString(StorageConstants.accessToken);
      final response = await _dioClient.dio.get(
        ApiConstants.userById(currentUserId),
        options: Options(
          headers: {if (token != null) 'Authorization': 'Bearer $token'},
        ),
      );
      final data = response.data;
      if (data is Map<String, dynamic>) {
        return data['roleName'] as String? ?? data['role'] as String?;
      }
      if (data is Map) {
        final map = Map<String, dynamic>.from(data);
        return map['roleName'] as String? ?? map['role'] as String?;
      }
    } catch (e) {
      debugPrint('Current user role fetch error: $e');
    }
    return null;
  }

  int? get _currentUserId {
    final storedUserId = _sharedPreferences.getString(StorageConstants.userId);
    final parsedStoredUserId = int.tryParse(storedUserId ?? '');
    if (parsedStoredUserId != null) return parsedStoredUserId;

    final token = _sharedPreferences.getString(StorageConstants.accessToken);
    if (token == null || token.isEmpty) return null;

    final payload = _decodeJwtPayload(token);
    final rawId = payload?[
            'http://schemas.xmlsoap.org/ws/2005/05/identity/claims/nameidentifier'] ??
        payload?['nameid'] ??
        payload?['sub'] ??
        payload?['id'];
    final userId = int.tryParse(rawId?.toString() ?? '');
    if (userId != null) {
      _sharedPreferences.setString(StorageConstants.userId, userId.toString());
    }
    return userId;
  }

  Map<String, dynamic>? _decodeJwtPayload(String token) {
    final parts = token.split('.');
    if (parts.length != 3) return null;

    try {
      final normalized = base64Url.normalize(parts[1]);
      final decoded = utf8.decode(base64Url.decode(normalized));
      return jsonDecode(decoded) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  int? _extractUserId(List<Object?>? arguments) {
    final map = _firstMap(arguments);
    final rawId = map?['userId'] ??
        map?['id'] ??
        map?['targetUserId'] ??
        map?['changedUserId'];
    return int.tryParse(rawId?.toString() ?? '');
  }

  String? _extractRoleName(List<Object?>? arguments) {
    final map = _firstMap(arguments);
    final rawRole = map?['roleName'] ??
        map?['newRoleName'] ??
        map?['role'] ??
        map?['newRole'];
    if (rawRole is String && rawRole.trim().isNotEmpty) {
      return rawRole.trim();
    }

    for (final argument in arguments ?? const <Object?>[]) {
      if (argument is String && argument.trim().isNotEmpty) {
        return argument.trim();
      }
    }
    return null;
  }

  Map<String, dynamic>? _firstMap(List<Object?>? arguments) {
    for (final argument in arguments ?? const <Object?>[]) {
      if (argument is Map<String, dynamic>) return argument;
      if (argument is Map) return Map<String, dynamic>.from(argument);
    }
    return null;
  }

  static const List<String> _roleChangeEventNames = [
    'RoleChanged',
    'RoleChange',
    'RoleUpdated',
    'UserRoleChanged',
    'ReceiveRoleChanged',
    'ReceiveRoleChange',
    'ReceiveRoleChangeNotification',
    'RoleChangedNotification',
    'NotifyRoleChanged',
  ];
}
