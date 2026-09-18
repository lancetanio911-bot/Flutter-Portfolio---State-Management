import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:wifi_iot/wifi_iot.dart';

enum RequestState { ready, processing, queued, retrying, completed }

class _NetworkRequest {
  final int id;
  RequestState state;

  _NetworkRequest(this.id, this.state);
}

class NetworkMonitorScreen extends StatefulWidget {
  const NetworkMonitorScreen({super.key});

  @override
  State<NetworkMonitorScreen> createState() => _NetworkMonitorScreenState();
}

class _NetworkMonitorScreenState extends State<NetworkMonitorScreen> {
  final Connectivity _connectivity = Connectivity();
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  Timer? _requestTimer;
  Timer? _retryTimer;
  List<ConnectivityResult> _connection = const [ConnectivityResult.none];
  bool _wifiEnabled = true;
  bool _wifiUpdating = false;
  final List<_NetworkRequest> _pendingRequests = [];
  _NetworkRequest? _activeRequest;
  _NetworkRequest? _displayedRequest;
  int _nextRequestId = 1;

  bool get _isOnline => _connection.any(
    (result) =>
        result == ConnectivityResult.wifi ||
        result == ConnectivityResult.mobile,
  );

  String get _networkName {
    if (_connection.contains(ConnectivityResult.wifi)) {
      return 'Wi-Fi';
    }
    if (_connection.contains(ConnectivityResult.mobile)) {
      return 'Cellular';
    }
    return 'Offline';
  }

  ConnectivityResult? get _networkType {
    if (_connection.contains(ConnectivityResult.wifi)) {
      return ConnectivityResult.wifi;
    }
    if (_connection.contains(ConnectivityResult.mobile)) {
      return ConnectivityResult.mobile;
    }
    return null;
  }

  RequestState get _requestState =>
      _displayedRequest?.state ?? RequestState.ready;

  @override
  void initState() {
    super.initState();
    _readConnection();
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen(
      _handleConnectionChange,
    );
  }

  Future<void> _readConnection() async {
    final connection = await _connectivity.checkConnectivity();
    if (mounted) {
      _handleConnectionChange(connection);
    }
  }

  Future<void> _toggleWifi(bool enabled) async {
    setState(() {
      _wifiUpdating = true;
    });

    try {
      await WiFiForIoTPlugin.setEnabled(enabled);
      if (!mounted) {
        return;
      }
      setState(() {
        _wifiEnabled = enabled;
        _wifiUpdating = false;
      });
      await _readConnection();
    } catch (_) {
      if (mounted) {
        setState(() {
          _wifiUpdating = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Unable to change Wi-Fi state.')),
        );
      }
    }
  }

  void _handleConnectionChange(List<ConnectivityResult> connection) {
    final effectiveConnection = _wifiEnabled
        ? connection
        : connection
              .where((result) => result != ConnectivityResult.wifi)
              .toList();
    final previousNetwork = _networkType;
    final nextNetwork = effectiveConnection.contains(ConnectivityResult.wifi)
        ? ConnectivityResult.wifi
        : effectiveConnection.contains(ConnectivityResult.mobile)
        ? ConnectivityResult.mobile
        : null;
    final handoverStarted =
        previousNetwork != null &&
        nextNetwork != null &&
        previousNetwork != nextNetwork;

    setState(() {
      _connection = effectiveConnection;
    });

    if (_activeRequest != null && (!_isOnline || handoverStarted)) {
      _queueActiveRequest();
    }

    if (_retryTimer != null && (!_isOnline || handoverStarted)) {
      _retryTimer?.cancel();
      _retryTimer = null;
      final request = _pendingRequests.isNotEmpty
          ? _pendingRequests.first
          : null;
      if (request != null) {
        request.state = RequestState.queued;
        setState(() {});
      }
    }

    if (_isOnline && _activeRequest == null && _pendingRequests.isNotEmpty) {
      _scheduleRetry();
    }
  }

  void _startRequest() {
    final request = _NetworkRequest(_nextRequestId++, RequestState.queued);
    _displayedRequest = request;

    if (!_isOnline) {
      _pendingRequests.add(request);
      setState(() {
        request.state = RequestState.queued;
      });
      return;
    }

    _beginProcessing(request);
  }

  void _beginProcessing(_NetworkRequest request) {
    if (!_isOnline) {
      if (!_pendingRequests.contains(request)) {
        _pendingRequests.add(request);
      }
      request.state = RequestState.queued;
      setState(() {});
      return;
    }

    _retryTimer?.cancel();
    _retryTimer = null;
    _activeRequest = request;
    setState(() {
      request.state = RequestState.processing;
    });
    _requestTimer = Timer(const Duration(seconds: 8), () {
      if (!mounted || _activeRequest != request || !_isOnline) {
        return;
      }
      _pendingRequests.remove(request);
      _activeRequest = null;
      setState(() {
        request.state = RequestState.completed;
      });
      _scheduleRetry();
    });
  }

  void _queueActiveRequest() {
    final request = _activeRequest;
    if (request == null) {
      return;
    }

    _requestTimer?.cancel();
    _requestTimer = null;
    _activeRequest = null;
    if (!_pendingRequests.contains(request)) {
      _pendingRequests.add(request);
    }
    request.state = RequestState.queued;
    setState(() {});
  }

  void _scheduleRetry() {
    if (_retryTimer != null || !_isOnline || _pendingRequests.isEmpty) {
      return;
    }

    final request = _pendingRequests.first;
    _displayedRequest = request;
    setState(() {
      request.state = RequestState.retrying;
    });
    _retryTimer = Timer(const Duration(seconds: 1), () {
      _retryTimer = null;
      if (mounted && _isOnline && _pendingRequests.contains(request)) {
        _beginProcessing(request);
      }
    });
  }

  @override
  void dispose() {
    _connectivitySubscription?.cancel();
    _requestTimer?.cancel();
    _retryTimer?.cancel();
    super.dispose();
  }

  String get _requestStateLabel {
    final state = _requestState;
    return state.name[0].toUpperCase() + state.name.substring(1);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Activity 2')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Active Network Monitor',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Watch connection handovers and recover a request when the network returns.',
                style: theme.textTheme.bodyLarge?.copyWith(height: 1.5),
              ),
              const SizedBox(height: 24),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      Icon(
                        _networkType == ConnectivityResult.mobile
                            ? Icons.signal_cellular_alt
                            : _isOnline
                            ? Icons.wifi
                            : Icons.wifi_off,
                        size: 34,
                        color: _isOnline
                            ? theme.colorScheme.primary
                            : theme.colorScheme.error,
                      ),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Current network',
                            style: theme.textTheme.labelLarge,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _networkName,
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('Wi-Fi'),
                          Switch(
                            value: _wifiEnabled,
                            onChanged: _wifiUpdating ? null : _toggleWifi,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Long-running request',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'The request takes a few seconds to complete. Losing the connection queues it for automatic recovery.',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Text(
                            'Pending requests',
                            style: theme.textTheme.labelLarge,
                          ),
                          const Spacer(),
                          Text(
                            '${_pendingRequests.length}',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Wrap(
                        alignment: WrapAlignment.spaceBetween,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 12,
                        runSpacing: 12,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primaryContainer,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              _requestStateLabel,
                              style: TextStyle(
                                color: theme.colorScheme.onPrimaryContainer,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          FilledButton.icon(
                            onPressed:
                                _activeRequest != null ||
                                    _requestState == RequestState.retrying
                                ? null
                                : _startRequest,
                            icon: const Icon(Icons.play_arrow),
                            label: const Text('Start Request'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
