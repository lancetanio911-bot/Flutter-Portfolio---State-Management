import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nearby_connections/nearby_connections.dart';
import 'package:student_life_hub/services/nearby_chat_permission_service.dart';

enum _ChatConnectionState {
  disconnected,
  discovering,
  deviceFound,
  connecting,
  connected,
}

class _ChatMessage {
  final String text;
  final bool isMine;

  const _ChatMessage({required this.text, required this.isMine});
}

class LocalMeshChatScreen extends StatefulWidget {
  const LocalMeshChatScreen({super.key});

  @override
  State<LocalMeshChatScreen> createState() => _LocalMeshChatScreenState();
}

class _LocalMeshChatScreenState extends State<LocalMeshChatScreen> {
  static const _serviceId = 'com.example.student_life_hub';

  final Nearby _nearby = Nearby();
  final NearbyChatPermissionService _permissionService =
      NearbyChatPermissionService();
  final Map<String, String> _nearbyDevices = {};
  final List<_ChatMessage> _messages = [];
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _messageScrollController = ScrollController();

  _ChatConnectionState _connectionState = _ChatConnectionState.disconnected;
  String _localDeviceName = NearbyChatPermissionService.fallbackDeviceName;
  String? _endpointId;
  String? _connectedDeviceName;
  String? _errorMessage;
  bool _isDiscovering = false;
  bool _isStarting = false;

  bool get _isSupported =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

  String get _statusLabel => switch (_connectionState) {
    _ChatConnectionState.disconnected => 'Disconnected',
    _ChatConnectionState.discovering => 'Discovering',
    _ChatConnectionState.deviceFound => 'Device Found',
    _ChatConnectionState.connecting => 'Connecting',
    _ChatConnectionState.connected => 'Connected',
  };

  @override
  void initState() {
    super.initState();
    if (_isSupported) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        unawaited(_startNearby());
      });
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _messageScrollController.dispose();
    if (_isSupported) {
      unawaited(_stopNearbySafely());
    }
    super.dispose();
  }

  Future<void> _startNearby() async {
    if (!_isSupported || _isStarting || _isDiscovering) return;

    setState(() {
      _isStarting = true;
      _errorMessage = null;
    });

    var isAdvertising = false;
    try {
      _localDeviceName = await _permissionService.requestAndGetDeviceName();

      isAdvertising = await _nearby.startAdvertising(
        _localDeviceName,
        Strategy.P2P_CLUSTER,
        onConnectionInitiated: _onConnectionInitiated,
        onConnectionResult: _onConnectionResult,
        onDisconnected: _onDisconnected,
        serviceId: _serviceId,
      );
      if (!isAdvertising) {
        throw StateError('Could not start advertising this device.');
      }

      final isDiscovering = await _nearby.startDiscovery(
        _localDeviceName,
        Strategy.P2P_CLUSTER,
        onEndpointFound: _onEndpointFound,
        onEndpointLost: _onEndpointLost,
        serviceId: _serviceId,
      );
      if (!isDiscovering) {
        throw StateError('Could not discover nearby devices.');
      }

      if (!mounted) return;
      setState(() {
        _isDiscovering = true;
        _connectionState = _nearbyDevices.isEmpty
            ? _ChatConnectionState.discovering
            : _ChatConnectionState.deviceFound;
      });
    } catch (error) {
      if (isAdvertising) await _stopAdvertisingSafely();
      if (!mounted) return;
      setState(() {
        _errorMessage = _nearbyErrorMessage(error);
        _connectionState = _ChatConnectionState.disconnected;
      });
    } finally {
      if (mounted) {
        setState(() => _isStarting = false);
      }
    }
  }

  Future<void> _stopNearby() async {
    await _stopNearbySafely();
    if (!mounted) return;
    setState(() {
      _isDiscovering = false;
      _nearbyDevices.clear();
      _connectionState = _ChatConnectionState.disconnected;
    });
  }

  Future<void> _stopNearbySafely() async {
    try {
      await _nearby.stopAllEndpoints();
    } catch (_) {}
    await _stopAdvertisingSafely();
    await _stopDiscoverySafely();
  }

  Future<void> _stopDiscoverySafely() async {
    try {
      await _nearby.stopDiscovery();
    } catch (_) {}
  }

  Future<void> _stopAdvertisingSafely() async {
    try {
      await _nearby.stopAdvertising();
    } catch (_) {}
  }

  Future<void> _rejectConnectionSafely(String id) async {
    try {
      await _nearby.rejectConnection(id);
    } catch (_) {}
  }

  String _nearbyErrorMessage(Object error) {
    if (error is PlatformException &&
        error.message?.contains('MISSING_PERMISSION') == true) {
      return 'Android is missing a permission required for nearby discovery. '
          'Check Nearby devices and Bluetooth access in Settings, then try again.';
    }
    return error.toString().replaceFirst('Bad state: ', '');
  }

  void _onEndpointFound(String id, String name, String serviceId) {
    if (!mounted || id == _endpointId) return;
    setState(() {
      _nearbyDevices[id] = name;
      if (_connectionState == _ChatConnectionState.discovering ||
          _connectionState == _ChatConnectionState.disconnected) {
        _connectionState = _ChatConnectionState.deviceFound;
      }
    });
  }

  void _onEndpointLost(String? id) {
    if (!mounted || id == null) return;
    setState(() {
      _nearbyDevices.remove(id);
      _refreshDiscoveryStatus();
    });
  }

  Future<void> _requestConnection(String id, String name) async {
    setState(() {
      _endpointId = id;
      _connectedDeviceName = name;
      _connectionState = _ChatConnectionState.connecting;
      _errorMessage = null;
    });
    try {
      await _nearby.requestConnection(
        _localDeviceName,
        id,
        onConnectionInitiated: _onConnectionInitiated,
        onConnectionResult: _onConnectionResult,
        onDisconnected: _onDisconnected,
      );
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _errorMessage = error.toString();
        _endpointId = null;
        _connectedDeviceName = null;
        _refreshDiscoveryStatus();
      });
    }
  }

  void _onConnectionInitiated(String id, ConnectionInfo info) {
    unawaited(_handleConnectionInitiated(id, info));
  }

  Future<void> _handleConnectionInitiated(
    String id,
    ConnectionInfo info,
  ) async {
    if (!mounted) {
      await _rejectConnectionSafely(id);
      return;
    }
    setState(() {
      _endpointId = id;
      _connectedDeviceName = info.endpointName;
      _connectionState = _ChatConnectionState.connecting;
    });

    final shouldAccept = info.isIncomingConnection
        ? await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Connection request'),
                  content: Text('${info.endpointName} wants to connect.'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Reject'),
                    ),
                    FilledButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('Accept'),
                    ),
                  ],
                ),
              ) ??
              false
        : true;

    if (!mounted) return;
    if (!shouldAccept) {
      await _rejectConnectionSafely(id);
      setState(() {
        _endpointId = null;
        _connectedDeviceName = null;
        _refreshDiscoveryStatus();
      });
      return;
    }

    bool accepted;
    try {
      accepted = await _nearby.acceptConnection(
        id,
        onPayLoadRecieved: _onPayloadReceived,
      );
    } catch (error) {
      if (!mounted) return;
      setState(() => _errorMessage = _nearbyErrorMessage(error));
      return;
    }
    if (!accepted && mounted) {
      setState(() {
        _errorMessage = 'The connection could not be accepted.';
        _endpointId = null;
        _connectedDeviceName = null;
        _refreshDiscoveryStatus();
      });
    }
  }

  void _onConnectionResult(String id, Status status) {
    if (!mounted) return;
    if (status == Status.CONNECTED) {
      setState(() {
        _endpointId = id;
        _connectedDeviceName ??= _nearbyDevices[id];
        _connectionState = _ChatConnectionState.connected;
        _isDiscovering = false;
        _nearbyDevices.clear();
      });
      unawaited(_stopDiscoverySafely());
      unawaited(_stopAdvertisingSafely());
      return;
    }

    setState(() {
      _errorMessage = status == Status.REJECTED
          ? 'The connection request was rejected.'
          : 'The connection could not be established.';
      _endpointId = null;
      _connectedDeviceName = null;
      _refreshDiscoveryStatus();
    });
  }

  void _onDisconnected(String id) {
    if (!mounted) return;
    setState(() {
      _endpointId = null;
      _connectedDeviceName = null;
      _isDiscovering = false;
      _connectionState = _ChatConnectionState.disconnected;
    });
  }

  void _onPayloadReceived(String id, Payload payload) {
    final bytes = payload.bytes;
    if (!mounted || payload.type != PayloadType.BYTES || bytes == null) return;
    final message = utf8.decode(bytes, allowMalformed: true);
    setState(() => _messages.add(_ChatMessage(text: message, isMine: false)));
    _scrollToLatestMessage();
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    final endpointId = _endpointId;
    if (text.isEmpty || endpointId == null) return;

    _messageController.clear();
    try {
      await _nearby.sendBytesPayload(
        endpointId,
        Uint8List.fromList(utf8.encode(text)),
      );
      if (!mounted) return;
      setState(() => _messages.add(_ChatMessage(text: text, isMine: true)));
      _scrollToLatestMessage();
    } catch (error) {
      if (!mounted) return;
      _messageController.text = text;
      setState(() => _errorMessage = 'Message could not be sent: $error');
    }
  }

  Future<void> _disconnect() async {
    final endpointId = _endpointId;
    if (endpointId != null) {
      await _nearby.disconnectFromEndpoint(endpointId);
    }
  }

  void _refreshDiscoveryStatus() {
    if (_connectionState == _ChatConnectionState.connected ||
        _connectionState == _ChatConnectionState.connecting) {
      return;
    }
    _connectionState = _nearbyDevices.isNotEmpty
        ? _ChatConnectionState.deviceFound
        : _isDiscovering
        ? _ChatConnectionState.discovering
        : _ChatConnectionState.disconnected;
  }

  void _scrollToLatestMessage() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_messageScrollController.hasClients) {
        unawaited(
          _messageScrollController.animateTo(
            _messageScrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOut,
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isConnected = _connectionState == _ChatConnectionState.connected;

    return Scaffold(
      appBar: AppBar(title: const Text('Activity 4')),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(theme, isConnected),
            Expanded(child: _buildChatBody(theme, isConnected)),
            _buildMessageComposer(isConnected),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme, bool isConnected) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Local Mesh Chat',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          _buildStatusCard(theme, isConnected),
          if (!_isSupported) ...[
            const SizedBox(height: 8),
            Text(
              'Nearby Connections is supported on Android only.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.error,
              ),
            ),
          ],
          if (_errorMessage != null) ...[
            const SizedBox(height: 8),
            Text(
              _errorMessage!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.error,
              ),
            ),
          ],
          if (_nearbyDevices.isNotEmpty) ...[
            const SizedBox(height: 12),
            _buildNearbyDevices(theme, isConnected),
          ],
        ],
      ),
    );
  }

  Widget _buildStatusCard(ThemeData theme, bool isConnected) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Icon(
              isConnected ? Icons.link : Icons.bluetooth_searching,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _connectedDeviceName ?? _statusLabel,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(_statusLabel),
                ],
              ),
            ),
            if (isConnected)
              IconButton(
                tooltip: 'Disconnect',
                onPressed: _disconnect,
                icon: const Icon(Icons.link_off),
              )
            else
              FilledButton.tonalIcon(
                onPressed: !_isSupported || _isStarting
                    ? null
                    : _isDiscovering
                    ? _stopNearby
                    : _startNearby,
                icon: _isStarting
                    ? const SizedBox.square(
                        dimension: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Icon(_isDiscovering ? Icons.stop : Icons.radar),
                label: Text(_isDiscovering ? 'Stop' : 'Find devices'),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildNearbyDevices(ThemeData theme, bool isConnected) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Nearby devices',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 4),
        SizedBox(
          height: 112,
          child: ListView.separated(
            itemCount: _nearbyDevices.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final entry = _nearbyDevices.entries.elementAt(index);
              final canConnect =
                  _connectionState != _ChatConnectionState.connecting &&
                  !isConnected;
              return ListTile(
                dense: true,
                leading: const Icon(Icons.smartphone),
                title: Text(entry.value),
                trailing: IconButton(
                  tooltip: 'Connect to ${entry.value}',
                  onPressed: canConnect
                      ? () => _requestConnection(entry.key, entry.value)
                      : null,
                  icon: const Icon(Icons.link),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildChatBody(ThemeData theme, bool isConnected) {
    if (isConnected) return _buildMessages(theme);

    final message = _connectionState == _ChatConnectionState.connecting
        ? 'Waiting for connection approval...'
        : 'Connect to a nearby device to start chatting.';
    return Center(
      child: Text(
        message,
        style: theme.textTheme.bodyMedium,
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildMessageComposer(bool isConnected) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              enabled: isConnected,
              textInputAction: TextInputAction.send,
              onSubmitted: isConnected ? (_) => _sendMessage() : null,
              decoration: const InputDecoration(
                hintText: 'Message',
                border: OutlineInputBorder(),
                isDense: true,
              ),
            ),
          ),
          const SizedBox(width: 8),
          IconButton.filled(
            tooltip: 'Send message',
            onPressed: isConnected ? _sendMessage : null,
            icon: const Icon(Icons.send),
          ),
        ],
      ),
    );
  }

  Widget _buildMessages(ThemeData theme) {
    if (_messages.isEmpty) {
      return Center(
        child: Text('No messages yet.', style: theme.textTheme.bodyMedium),
      );
    }
    return ListView.builder(
      controller: _messageScrollController,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: _messages.length,
      itemBuilder: (context, index) {
        final message = _messages[index];
        return Align(
          alignment: message.isMine
              ? Alignment.centerRight
              : Alignment.centerLeft,
          child: Container(
            constraints: const BoxConstraints(maxWidth: 300),
            margin: const EdgeInsets.symmetric(vertical: 4),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: message.isMine
                  ? theme.colorScheme.primary
                  : theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              message.text,
              style: TextStyle(
                color: message.isMine
                    ? theme.colorScheme.onPrimary
                    : theme.colorScheme.onSurface,
              ),
            ),
          ),
        );
      },
    );
  }
}
