import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers/providers.dart';
import '../../widgets/app_illustration.dart';

class SyncDiagnosticsScreen extends ConsumerWidget {
  const SyncDiagnosticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pending = ref.watch(pendingSyncOperationsProvider);
    final failed = ref.watch(failedSyncOperationsProvider);
    final lastSync = ref.watch(lastSuccessfulSyncProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sync Diagnostics'),
        actions: [
          IconButton(
            onPressed: () async {
              await ref.read(syncQueueServiceProvider).flushQueue();
              if (!context.mounted) {
                return;
              }
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Manual sync started')),
              );
            },
            icon: const Icon(Icons.sync),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const AppIllustration(
            asset: 'assets/illustrations/offline_sync.svg',
            height: 110,
          ),
          const SizedBox(height: 12),
          _MetricTile(
            title: 'Pending operations',
            value: pending.when(
              data: (value) => '$value',
              loading: () => '...',
              error: (error, stackTrace) => 'error',
            ),
          ),
          _MetricTile(
            title: 'Failed operations',
            value: failed.when(
              data: (value) => '$value',
              loading: () => '...',
              error: (error, stackTrace) => 'error',
            ),
          ),
          _MetricTile(
            title: 'Last successful sync',
            value: lastSync.when(
              data: (value) => value?.toIso8601String() ?? 'never',
              loading: () => '...',
              error: (error, stackTrace) => 'error',
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricTile extends StatelessWidget {
  const _MetricTile({required this.title, required this.value});

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(title),
        trailing: Text(value, style: Theme.of(context).textTheme.titleMedium),
      ),
    );
  }
}
