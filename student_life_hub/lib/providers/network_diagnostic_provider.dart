import 'dart:async';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';

enum NetworkHealth { excellent, fair, poor, degraded }

class NetworkDiagnosticProvider extends ChangeNotifier {
  static const Duration _diagnosticInterval = Duration(minutes: 2);
  static const Duration _timeout = Duration(seconds: 12);
  static const int _uploadBytes = 1000000;
  static const String _pingUrl = 'https://speed.cloudflare.com/__down?bytes=1';
  static final Uri _downloadUri = Uri.parse(
    'https://speed.cloudflare.com/__down?bytes=2000000',
  );
  static final Uri _uploadUri = Uri.parse('https://speed.cloudflare.com/__up');

  final Connectivity _connectivity = Connectivity();
  Timer? _regularDiagnosticTimer;
  bool _isRunning = false;
  int _runId = 0;
  int _failedPings = 0;

  NetworkHealth _health = NetworkHealth.degraded;
  double? _idlePing;
  double? _downloadSpeed;
  double? _downloadPing;
  double? _uploadSpeed;
  double? _uploadPing;
  String _status = 'Ready to test';

  NetworkHealth get health => _health;
  double? get idlePing => _idlePing;
  double? get downloadSpeed => _downloadSpeed;
  double? get downloadPing => _downloadPing;
  double? get uploadSpeed => _uploadSpeed;
  double? get uploadPing => _uploadPing;
  String get status => _status;
  bool get isRunning => _isRunning;

  void startRegularDiagnostics() {
    if (_regularDiagnosticTimer != null) {
      return;
    }

    runDiagnostic();
    _regularDiagnosticTimer = Timer.periodic(
      _diagnosticInterval,
      (_) => runDiagnostic(),
    );
  }

  void stopRegularDiagnostics() {
    _regularDiagnosticTimer?.cancel();
    _regularDiagnosticTimer = null;
  }

  Future<void> runDiagnostic() async {
    if (_isRunning) {
      return;
    }

    final currentRunId = ++_runId;
    _isRunning = true;
    _failedPings = 0;
    _status = 'Step 1 of 3: Measuring idle ping';
    notifyListeners();

    try {
      await _ensureConnected();
      _idlePing = await _measurePing();

      _setStatus('Step 2 of 3: Measuring download and ping');
      notifyListeners();
      await _ensureCurrentRun(currentRunId);
      final downloadResults = await Future.wait<double?>([
        _measureDownload(),
        _measurePing(),
      ]);
      _downloadSpeed = downloadResults[0];
      _downloadPing = downloadResults[1];

      _setStatus('Step 3 of 3: Measuring upload and ping');
      notifyListeners();
      await _ensureCurrentRun(currentRunId);
      final uploadResults = await Future.wait<double?>([
        _measureUpload(),
        _measurePing(),
      ]);
      _uploadSpeed = uploadResults[0];
      _uploadPing = uploadResults[1];

      await _ensureCurrentRun(currentRunId);
      _health = _classifyHealth();
      _setStatus('Diagnostic complete');
    } on TimeoutException {
      _failDiagnostic('Diagnostic timed out');
    } on SocketException {
      _failDiagnostic('No internet connection');
    } on HttpException {
      _failDiagnostic('Diagnostic server unavailable');
    } catch (_) {
      _failDiagnostic('Diagnostic failed');
    } finally {
      if (currentRunId == _runId) {
        _isRunning = false;
        notifyListeners();
      }
    }
  }

  Future<void> _ensureConnected() async {
    final results = await _connectivity.checkConnectivity();
    if (results.every((result) => result == ConnectivityResult.none)) {
      throw const SocketException('No network connection');
    }
  }

  Future<void> _ensureCurrentRun(int currentRunId) async {
    if (currentRunId != _runId) {
      throw const SocketException('Diagnostic superseded');
    }
    await _ensureConnected();
  }

  Future<double?> _measurePing() async {
    final client = HttpClient()..connectionTimeout = _timeout;
    final stopwatch = Stopwatch()..start();
    try {
      final request = await client
          .getUrl(Uri.parse(_pingUrl))
          .timeout(_timeout);
      final response = await request.close().timeout(_timeout);
      await response.drain<void>().timeout(_timeout);
      stopwatch.stop();
      return stopwatch.elapsedMicroseconds / 1000;
    } on TimeoutException {
      _failedPings++;
      rethrow;
    } on SocketException {
      _failedPings++;
      rethrow;
    } finally {
      client.close(force: true);
    }
  }

  Future<double> _measureDownload() async {
    final client = HttpClient()..connectionTimeout = _timeout;
    final stopwatch = Stopwatch()..start();
    var bytes = 0;
    try {
      final request = await client.getUrl(_downloadUri).timeout(_timeout);
      final response = await request.close().timeout(_timeout);
      await for (final chunk in response.timeout(_timeout)) {
        bytes += chunk.length;
      }
      stopwatch.stop();
      return _megabitsPerSecond(bytes, stopwatch.elapsedMicroseconds);
    } finally {
      client.close(force: true);
    }
  }

  Future<double> _measureUpload() async {
    final client = HttpClient()..connectionTimeout = _timeout;
    final payload = List<int>.filled(_uploadBytes, 0);
    final stopwatch = Stopwatch()..start();
    try {
      final request = await client.postUrl(_uploadUri).timeout(_timeout);
      request.headers.contentType = ContentType.binary;
      request.contentLength = payload.length;
      request.add(payload);
      final response = await request.close().timeout(_timeout);
      await response.drain<void>().timeout(_timeout);
      stopwatch.stop();
      return _megabitsPerSecond(payload.length, stopwatch.elapsedMicroseconds);
    } finally {
      client.close(force: true);
    }
  }

  double _megabitsPerSecond(int bytes, int elapsedMicroseconds) {
    if (elapsedMicroseconds <= 0) {
      return 0;
    }
    return bytes * 8 / elapsedMicroseconds;
  }

  void _setStatus(String status) {
    _status = status;
  }

  void _failDiagnostic(String status) {
    _health = NetworkHealth.degraded;
    _setStatus(status);
  }

  NetworkHealth _classifyHealth() {
    final latency = [
      _idlePing,
      _downloadPing,
      _uploadPing,
    ].whereType<double>().toList();
    final speeds = [_downloadSpeed, _uploadSpeed].whereType<double>().toList();

    if (_failedPings > 0 || latency.length < 3 || speeds.length < 2) {
      return NetworkHealth.degraded;
    }
    if (latency.any((value) => value >= 500)) {
      return NetworkHealth.degraded;
    }

    final averageSpeed = speeds.reduce((first, second) => first + second) / 2;
    if (averageSpeed > 10) {
      return NetworkHealth.excellent;
    }
    if (averageSpeed >= 2) {
      return NetworkHealth.fair;
    }
    return NetworkHealth.poor;
  }

  @override
  void dispose() {
    stopRegularDiagnostics();
    super.dispose();
  }
}
