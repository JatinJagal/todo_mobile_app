import 'dart:async';
import 'dart:convert';

import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class SocketService {
  // Singleton pattern
  static final SocketService _instance = SocketService._internal();
  factory SocketService() => _instance;
  SocketService._internal();

  WebSocketChannel? _channel;
  String? _currentToken;
  Timer? _reconnectTimer;
  bool _isConnecting = false;
  bool _isConnectedState = false;
  StreamSubscription? _streamSubscription;
  final StreamController<Map<String, dynamic>> _messageController =
      StreamController<Map<String, dynamic>>.broadcast();

  Stream<Map<String, dynamic>> get messageStream => _messageController.stream;

  // WebSocket URL
  static const String wsUrl = 'ws://192.168.75.96:3000/ws';

  void connect(String? token) {
    if (token == null || token.isEmpty) {
      print('WebSocket: No token provided');
      return;
    }

    // If already connected with same token, don't reconnect
    if (_channel != null && _isConnectedState && _currentToken == token) {
      print('WebSocket: Already connected');
      return;
    }

    // If already connecting, don't start another connection
    if (_isConnecting) {
      print('WebSocket: Already connecting...');
      return;
    }

    // Disconnect existing connection if token changed
    if (_channel != null && _currentToken != token) {
      _disconnect();
    }

    _currentToken = token;
    _isConnecting = true;

    try {
      print('WebSocket: Attempting to connect to $wsUrl');

      // Create WebSocket connection with authorization header
      final uri = Uri.parse(wsUrl);

      // Use IOWebSocketChannel for custom headers with timeout
      // Wrap in try-catch to handle connection errors gracefully
      try {
        _channel = IOWebSocketChannel.connect(
          uri,
          headers: {'Authorization': 'Bearer $token'},
        );
      } catch (e, stackTrace) {
        print('WebSocket: ❌ Failed to create WebSocket channel: $e');
        print('WebSocket: Stack trace: $stackTrace');
        _isConnecting = false;
        _isConnectedState = false;
        _scheduleReconnect(token);
        return;
      }
      
      // Listen to incoming messages with proper error handling
      // Wrap in try-catch to prevent unhandled exceptions
      try {
        _streamSubscription = _channel!.stream.listen(
          (message) {
            try {
              // Mark as connected when we receive first message
              if (!_isConnectedState) {
                _isConnectedState = true;
                _isConnecting = false;
                print('WebSocket: ✅ Connection confirmed (received first message)');
                _reconnectTimer?.cancel();
                _reconnectTimer = null;
                _reconnectAttempts = 0; // Reset on successful connection
              }
              _handleMessage(message);
            } catch (e, stackTrace) {
              print('WebSocket: ❌ Error handling message: $e');
              print('WebSocket: Stack trace: $stackTrace');
            }
          },
          onError: (error) {
            try {
              print('WebSocket: ⚠️ Stream error: $error');
              print('WebSocket: Error type: ${error.runtimeType}');
              
              // Check if it's a connection timeout or network error
              final errorString = error.toString().toLowerCase();
              if (errorString.contains('timeout') || 
                  errorString.contains('connection timed out') ||
                  errorString.contains('failed host lookup') ||
                  errorString.contains('network is unreachable')) {
                print('WebSocket: ❌ Network/Connection error detected');
                print('WebSocket: Please check:');
                print('WebSocket:   1. WebSocket server is running at $wsUrl');
                print('WebSocket:   2. IP address is correct: 192.168.75.96');
                print('WebSocket:   3. Port is correct: 3000');
                print('WebSocket:   4. Device and server are on same network');
                print('WebSocket:   5. Firewall is not blocking the connection');
              }
              
              _isConnecting = false;
              _isConnectedState = false;
              
              // Only schedule reconnect if we haven't failed too many times
              if (_currentToken == token) {
                _scheduleReconnect(token);
              }
            } catch (e, stackTrace) {
              print('WebSocket: ❌ Error in onError handler: $e');
              print('WebSocket: Stack trace: $stackTrace');
              _isConnecting = false;
              _isConnectedState = false;
            }
          },
          onDone: () {
            try {
              print('WebSocket: ❌ Connection closed (onDone)');
              _isConnecting = false;
              _isConnectedState = false;
              // Only reconnect if not manually disconnected
              if (_currentToken == token) {
                _scheduleReconnect(token);
              }
            } catch (e, stackTrace) {
              print('WebSocket: ❌ Error in onDone handler: $e');
              print('WebSocket: Stack trace: $stackTrace');
            }
          },
          cancelOnError: false,
        );
      } catch (e, stackTrace) {
        print('WebSocket: ❌ Error setting up stream listener: $e');
        print('WebSocket: Stack trace: $stackTrace');
        _isConnecting = false;
        _isConnectedState = false;
        _scheduleReconnect(token);
      }

      // Don't mark as connected optimistically - wait for actual connection
      // The connection will be confirmed when first message arrives or connection succeeds
      // This prevents false "connected" state when connection actually fails

      // Send authentication token as initial message if server requires it
      // Some servers expect token in first message instead of headers
      Future.delayed(Duration(milliseconds: 200), () {
        if (_channel != null && isConnected) {
          try {
            emit('auth', {'token': token});
            print('WebSocket: Sent auth message');
          } catch (e) {
            print('WebSocket: Could not send auth message: $e');
          }
        }
      });
    } catch (e, stackTrace) {
      // Catch all exceptions to prevent unhandled exceptions
      print('WebSocket: ❌ Connection error: $e');
      print('WebSocket: Error type: ${e.runtimeType}');
      print('WebSocket: Stack trace: $stackTrace');
      
      // Provide helpful error messages
      final errorString = e.toString().toLowerCase();
      if (errorString.contains('timeout') || errorString.contains('connection timed out')) {
        print('WebSocket: ⚠️ Connection timeout - Server may be unreachable');
        print('WebSocket: Verify server is running at $wsUrl');
      } else if (errorString.contains('failed host lookup') || errorString.contains('network')) {
        print('WebSocket: ⚠️ Network error - Check your internet connection');
      }
      
      _isConnecting = false;
      _isConnectedState = false;
      
      // Only schedule reconnect if token matches
      if (_currentToken == token) {
        _scheduleReconnect(token);
      }
    }
  }

  void _handleMessage(dynamic message) {
    try {
      Map<String, dynamic> data;

      if (message is String) {
        // Parse JSON string
        try {
          final decoded = json.decode(message);
          if (decoded is Map) {
            data = Map<String, dynamic>.from(decoded);
          } else {
            print('WebSocket: ⚠️ Decoded JSON is not a Map: ${decoded.runtimeType}');
            print('WebSocket: Decoded value: $decoded');
            return;
          }
        } catch (e) {
          print('WebSocket: ⚠️ Failed to parse JSON string: $e');
          print('WebSocket: Raw message: $message');
          return;
        }
      } else if (message is Map) {
        data = Map<String, dynamic>.from(message);
      } else {
        print('WebSocket: ⚠️ Unexpected message format: ${message.runtimeType}');
        print('WebSocket: Message: $message');
        return;
      }

      print('WebSocket: 📨 Received message (keys: ${data.keys.toList()}): $data');

      // Handle different event types based on the API documentation
      // Check multiple possible fields for event type
      final eventType = data['type'] ?? 
                       data['event'] ?? 
                       data['eventType'] ??
                       data['event_type'];

      if (eventType != null) {
        print('WebSocket: ✅ Event type detected: $eventType');

        // Handle different WebSocket events
        switch (eventType) {
          case 'chat_request_received':
          case 'chat_request_accepted':
          case 'chat_request_removed':
          case 'receive_message':
          case 'conversation_updated':
          case 'messages_read':
            // Add event type to the data for listeners to identify
            data['event_type'] = eventType;
            print('WebSocket: Broadcasting event: $eventType to ${_messageController.hasListener ? "listeners" : "NO LISTENERS"}');
            _messageController.add(data);
            break;
          default:
            // For any other events, just pass through
            print('WebSocket: ⚠️ Unknown event type: $eventType, passing through');
            data['event_type'] = eventType;
            _messageController.add(data);
        }
      } else {
        // If no event type, check if it looks like a message and pass through
        print('WebSocket: ⚠️ No event type found, but passing through data');
        print('WebSocket: Data structure: ${data.keys.toList()}');
        _messageController.add(data);
      }
    } catch (e, stackTrace) {
      print('WebSocket: ❌ Error parsing message: $e');
      print('WebSocket: Stack trace: $stackTrace');
      print('WebSocket: Message: $message');
    }
  }

  int _reconnectAttempts = 0;
  static const int _maxReconnectAttempts = 5;

  void _scheduleReconnect(String? token) {
    if (_reconnectTimer != null) {
      print('WebSocket: Reconnection already scheduled');
      return;
    }

    // Limit reconnection attempts to prevent infinite loops
    if (_reconnectAttempts >= _maxReconnectAttempts) {
      print('WebSocket: ⚠️ Max reconnection attempts ($_maxReconnectAttempts) reached');
      print('WebSocket: Stopping auto-reconnect. Please check server connection manually.');
      print('WebSocket: To retry, call connect() again or restart the app.');
      _reconnectAttempts = 0; // Reset after showing message
      return;
    }

    _reconnectAttempts++;
    print('WebSocket: 🔄 Scheduling reconnection in 5 seconds... (Attempt $_reconnectAttempts/$_maxReconnectAttempts)');
    print('WebSocket: Make sure WebSocket server is running at $wsUrl');
    
    _reconnectTimer = Timer(Duration(seconds: 5), () {
      try {
        if (!isConnected && _currentToken == token) {
          print('WebSocket: 🔄 Attempting to reconnect...');
          _reconnectTimer = null;
          connect(token);
        } else {
          print('WebSocket: Skipping reconnect - already connected or token changed');
          _reconnectTimer = null;
          _reconnectAttempts = 0; // Reset on successful connection
        }
      } catch (e, stackTrace) {
        print('WebSocket: ❌ Error during reconnection: $e');
        print('WebSocket: Stack trace: $stackTrace');
        _reconnectTimer = null;
      }
    });
  }

  void _disconnect() {
    try {
      _streamSubscription?.cancel();
      _streamSubscription = null;
      _channel?.sink.close();
    } catch (e) {
      print('WebSocket: Error closing connection: $e');
    }
    _channel = null;
    _isConnectedState = false;
  }

  void disconnect() {
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
    _disconnect();
    _currentToken = null;
    _isConnecting = false;
    print('WebSocket: Disconnected and cleaned up');
  }

  void emit(String event, Map<String, dynamic> data) {
    if (!isConnected) {
      print('WebSocket: ⚠️ Cannot emit - socket not connected');
      return;
    }

    try {
      // Create message with event type
      final message = {'type': event, ...data};

      _channel?.sink.add(json.encode(message));
      print('WebSocket: Emitted event: $event with data: $data');
    } catch (e) {
      print('WebSocket: ❌ Error emitting event: $e');
    }
  }

  bool get isConnected => _isConnectedState && _channel != null;

  // Don't dispose the singleton - it should stay alive for the app lifetime
  // Only call this when app is closing
  void dispose() {
    disconnect();
    if (!_messageController.isClosed) {
      _messageController.close();
    }
  }
}
