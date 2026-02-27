import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/providers/providers.dart';

class SyncStatusAction extends ConsumerWidget {
  const SyncStatusAction({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pending = ref.watch(pendingSyncOperationsProvider).asData?.value ?? 0;

    return IconButton(
      tooltip: pending > 0 ? '$pending pending sync operation(s)' : 'All changes synced',
      onPressed: () async {
        await ref.read(syncQueueServiceProvider).flushQueue();
        if (!context.mounted) {
          return;
        }
        final currentPending = ref.read(pendingSyncOperationsProvider).asData?.value ?? 0;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              currentPending > 0
                  ? '$currentPending operation(s) still pending'
                  : 'Sync complete',
            ),
          ),
        );
      },
      icon: Stack(
        clipBehavior: Clip.none,
        children: [
          Icon(
            pending > 0 ? Icons.cloud_upload_outlined : Icons.cloud_done_outlined,
          ),
          if (pending > 0)
            Positioned(
              right: -6,
              top: -6,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(10),
                ),
                constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                child: Text(
                  pending > 99 ? '99+' : '$pending',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
