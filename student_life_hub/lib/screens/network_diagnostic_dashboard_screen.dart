import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:student_life_hub/providers/network_diagnostic_provider.dart';

class NetworkDiagnosticDashboardScreen extends StatefulWidget {
  const NetworkDiagnosticDashboardScreen({super.key});

  @override
  State<NetworkDiagnosticDashboardScreen> createState() =>
      _NetworkDiagnosticDashboardScreenState();
}

class _NetworkDiagnosticDashboardScreenState
    extends State<NetworkDiagnosticDashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<NetworkDiagnosticProvider>().startRegularDiagnostics();
      }
    });
  }

  @override
  void dispose() {
    context.read<NetworkDiagnosticProvider>().stopRegularDiagnostics();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<NetworkDiagnosticProvider>();
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Activity 3')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Network Diagnostic Dashboard',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Measure the connection in three ordered phases and adapt content to the result.',
                style: theme.textTheme.bodyLarge?.copyWith(height: 1.5),
              ),
              const SizedBox(height: 24),
              _HealthCard(provider: provider),
              const SizedBox(height: 16),
              _MetricsCard(provider: provider),
              const SizedBox(height: 16),
              _AdaptiveContentCard(health: provider.health),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: provider.isRunning ? null : provider.runDiagnostic,
                  icon: provider.isRunning
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.refresh),
                  label: Text(
                    provider.isRunning
                        ? 'Diagnostic in progress'
                        : 'Run Diagnostic',
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

class _HealthCard extends StatelessWidget {
  final NetworkDiagnosticProvider provider;

  const _HealthCard({required this.provider});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = _healthColor(provider.health, theme);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Icon(Icons.network_check, size: 36, color: color),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Current Network Health',
                    style: theme.textTheme.labelLarge,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _healthLabel(provider.health),
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: color,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MetricsCard extends StatelessWidget {
  final NetworkDiagnosticProvider provider;

  const _MetricsCard({required this.provider});

  @override
  Widget build(BuildContext context) {
    final metrics = [
      _MetricData('Idle Ping', provider.idlePing, 'ms'),
      _MetricData('Download Speed', provider.downloadSpeed, 'Mbps'),
      _MetricData('Download Ping', provider.downloadPing, 'ms'),
      _MetricData('Upload Speed', provider.uploadSpeed, 'Mbps'),
      _MetricData('Upload Ping', provider.uploadPing, 'ms'),
      _MetricData('Diagnostic Status', null, provider.status),
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: metrics
              .map((metric) => _MetricRow(metric: metric))
              .toList(),
        ),
      ),
    );
  }
}

class _MetricData {
  final String label;
  final double? value;
  final String suffix;

  const _MetricData(this.label, this.value, this.suffix);
}

class _MetricRow extends StatelessWidget {
  final _MetricData metric;

  const _MetricRow({required this.metric});

  @override
  Widget build(BuildContext context) {
    final displayValue = metric.value == null
        ? metric.suffix
        : '${metric.value!.toStringAsFixed(1)} ${metric.suffix}';
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(child: Text(metric.label)),
          Flexible(
            child: Text(
              displayValue,
              textAlign: TextAlign.end,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}

class _AdaptiveContentCard extends StatelessWidget {
  final NetworkHealth health;

  const _AdaptiveContentCard({required this.health});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isHighQuality = health == NetworkHealth.excellent;
    final isMinimal =
        health == NetworkHealth.poor || health == NetworkHealth.degraded;
    final title = isHighQuality
        ? 'High-resolution content enabled'
        : isMinimal
        ? 'Lightweight mode enabled'
        : 'Normal content enabled';
    final description = isHighQuality
        ? 'A high-resolution preview and richer multimedia controls are available.'
        : isMinimal
        ? 'A compact placeholder is shown to reduce data use and loading time.'
        : 'Standard images and balanced multimedia content are available.';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Icon(
              isMinimal ? Icons.image_not_supported_outlined : Icons.hd,
              size: 32,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(description, style: theme.textTheme.bodyMedium),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String _healthLabel(NetworkHealth health) {
  return health.name[0].toUpperCase() + health.name.substring(1);
}

Color _healthColor(NetworkHealth health, ThemeData theme) {
  switch (health) {
    case NetworkHealth.excellent:
      return Colors.green;
    case NetworkHealth.fair:
      return Colors.orange;
    case NetworkHealth.poor:
      return Colors.deepOrange;
    case NetworkHealth.degraded:
      return theme.colorScheme.error;
  }
}
