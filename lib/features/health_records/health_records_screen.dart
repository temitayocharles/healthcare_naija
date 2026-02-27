import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../core/providers/providers.dart';
import '../../core/result/app_result.dart';
import '../../core/theme/app_theme.dart';
import '../../models/health_record.dart';
import '../../services/firestore_service.dart';
import '../../widgets/sync_status_action.dart';

final _healthRecordsForCurrentUserProvider =
    FutureProvider.autoDispose<List<HealthRecord>>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) {
    return <HealthRecord>[];
  }
  final result = await ref.read(healthRecordRepositoryProvider).getForUser(user.id);
  if (result is AppSuccess<List<HealthRecord>>) {
    return result.data;
  }
  return <HealthRecord>[];
});

class HealthRecordsScreen extends ConsumerStatefulWidget {
  const HealthRecordsScreen({super.key});

  @override
  ConsumerState<HealthRecordsScreen> createState() => _HealthRecordsScreenState();
}

class _HealthRecordsScreenState extends ConsumerState<HealthRecordsScreen> {
  bool _isUploading = false;

  Future<void> _uploadRecord() async {
    final user = ref.read(currentUserProvider);
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sign in required to upload records.')),
      );
      return;
    }

    final picked = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['jpg', 'jpeg', 'png', 'pdf'],
      withData: true,
    );

    if (picked == null || picked.files.isEmpty) {
      return;
    }
    if (!mounted) {
      return;
    }

    final file = picked.files.first;
    final bytes = file.bytes;
    if (bytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to read selected file bytes.')),
      );
      return;
    }

    final titleController = TextEditingController(text: file.name);
    final typeController = TextEditingController(text: 'other');
    final caregiverController = TextEditingController();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Upload Health Record'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: 'Record Title'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: typeController,
              decoration: const InputDecoration(
                labelText: 'Type (lab_result/prescription/scan/vaccination/other)',
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: caregiverController,
              decoration: const InputDecoration(
                labelText: 'Share with Caregiver ID (Optional)',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Upload'),
          ),
        ],
      ),
    );

    if (confirmed != true) {
      return;
    }

    setState(() => _isUploading = true);

    try {
      final upload = await ref.read(mediaUploadServiceProvider).uploadBytes(
            bytes: bytes,
            fileName: file.name,
            folder: 'health_records',
            ownerId: user.id,
          );

      final recordId = const Uuid().v4();
      final record = HealthRecord(
        id: recordId,
        userId: user.id,
        title: titleController.text.trim().isEmpty ? file.name : titleController.text.trim(),
        type: typeController.text.trim().isEmpty ? 'other' : typeController.text.trim(),
        description: 'Uploaded via mobile app',
        fileUrl: upload.url,
        date: DateTime.now(),
        providerName: null,
        tags: <String>[upload.contentType],
        isShared: caregiverController.text.trim().isNotEmpty,
        createdAt: DateTime.now(),
      );

      final createResult = await ref.read(healthRecordRepositoryProvider).create(record);
      if (createResult is AppFailure<HealthRecord>) {
        throw Exception(createResult.message);
      }

      if (caregiverController.text.trim().isNotEmpty) {
        await FirestoreService.shareHealthRecordWithCaregiver(
          recordId: recordId,
          patientId: user.id,
          caregiverId: caregiverController.text.trim(),
          fileUrl: upload.url,
          title: record.title,
        );
      }

      if (!mounted) {
        return;
      }
      ref.invalidate(_healthRecordsForCurrentUserProvider);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Health record uploaded successfully.')),
      );
    } catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Upload failed: $error')),
      );
    } finally {
      if (mounted) {
        setState(() => _isUploading = false);
      }
      titleController.dispose();
      typeController.dispose();
      caregiverController.dispose();
    }
  }

  @override
  Widget build(BuildContext context) {
    final recordsAsync = ref.watch(_healthRecordsForCurrentUserProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Health Records'),
        actions: [
          const SyncStatusAction(),
          IconButton(
            icon: _isUploading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.add),
            onPressed: _isUploading ? null : _uploadRecord,
          ),
        ],
      ),
      body: recordsAsync.when(
        data: (records) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.purple, Colors.purple.withValues(alpha: 0.7)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.folder_shared, color: Colors.white, size: 40),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Your Health Records',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          Text(
                            '${records.length} record(s) synced',
                            style: const TextStyle(color: Colors.white70, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _isUploading ? null : _uploadRecord,
                icon: const Icon(Icons.upload_file),
                label: const Text('Upload New Record'),
                style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryColor),
              ),
              const SizedBox(height: 16),
              if (records.isEmpty)
                Center(
                  child: Column(
                    children: [
                      Icon(Icons.folder_open, size: 64, color: Colors.grey[300]),
                      const SizedBox(height: 12),
                      Text(
                        'No health records yet',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: Colors.grey[600],
                            ),
                      ),
                    ],
                  ),
                )
              else
                ...records.map(
                  (record) => Card(
                    child: ListTile(
                      leading: const Icon(Icons.description),
                      title: Text(record.title),
                      subtitle: Text(
                        '${record.type} • ${record.date.toLocal()}${record.isShared ? ' • Shared with caregiver' : ''}',
                      ),
                      trailing: Icon(
                        record.isShared ? Icons.share : Icons.lock_outline,
                        color: record.isShared ? AppTheme.primaryColor : Colors.grey,
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Failed to load records: $error')),
      ),
    );
  }
}
