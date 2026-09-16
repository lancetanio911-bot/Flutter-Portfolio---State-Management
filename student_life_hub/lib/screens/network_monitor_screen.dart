import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';

enum RequestState { ready, processing, queued, retrying, completed }

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
  RequestState _requestState = RequestState.ready;
  int _requestId = 0;

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

  void _handleConnectionChange(List<ConnectivityResult> connection) {
    final wasOnline = _isOnline;
    setState(() {
      _connection = connection;
    });

    if (!_isOnline && _requestState == RequestState.processing) {
      _requestTimer?.cancel();
      setState(() {
        _requestState = RequestState.queued;
      });
    } else if (_isOnline && !wasOnline &&
        _requestState == RequestState.queued) {
      _resumeQueuedRequest();
    }
  }

  void _startRequest() {
    _requestTimer?.cancel();
    _retryTimer?.cancel();
    _requestId++;

    if (!_isOnline) {
      setState(() {
        _requestState = RequestState.queued;
      });
      return;
    }

    _beginProcessing(_requestId);
  }

  void _beginProcessing(int requestId) {
    setState(() {
      _requestState = RequestState.processing;
    });
    _requestTimer = Timer(const Duration(seconds: 8), () {
      if (!mounted || requestId != _requestId || !_isOnline) {
        return;
      }
      setState(() {
        _requestState = RequestState.completed;
      });
    });
  }

  void _resumeQueuedRequest() {
    final requestId = _requestId;
    setState(() {
      _requestState = RequestState.retrying;
    });
    _retryTimer = Timer(const Duration(seconds: 1), () {
      if (mounted && requestId == _requestId && _isOnline) {
        _beginProcessing(requestId);
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
                        _isOnline ? Icons.wifi : Icons.wifi_off,
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
                              _requestState.name[0].toUpperCase() +
                                  _requestState.name.substring(1),
                              style: TextStyle(
                                color: theme.colorScheme.onPrimaryContainer,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          FilledButton.icon(
                            onPressed: _requestState == RequestState.processing ||
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
