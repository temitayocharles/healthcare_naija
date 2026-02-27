import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers/providers.dart';
import '../../core/theme/app_theme.dart';
import '../../services/firestore_service.dart';
import '../../widgets/sync_status_action.dart';

final _messagesProvider = StreamProvider.family
    .autoDispose<List<Map<String, dynamic>>, ({String me, String other})>((ref, ids) {
  return FirestoreService.watchConversationMessages(
    currentUserId: ids.me,
    otherUserId: ids.other,
  );
});

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key, this.initialCaregiverId});

  final String? initialCaregiverId;

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final _messageController = TextEditingController();
  final _caregiverController = TextEditingController();
  bool _sending = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialCaregiverId != null && widget.initialCaregiverId!.isNotEmpty) {
      _caregiverController.text = widget.initialCaregiverId!;
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _caregiverController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage({PlatformFile? attachment}) async {
    final me = ref.read(currentUserProvider);
    final other = _caregiverController.text.trim();
    final text = _messageController.text.trim();

    if (me == null) {
      _showSnack('Sign in to use chat.');
      return;
    }
    if (other.isEmpty) {
      _showSnack('Enter caregiver ID before sending.');
      return;
    }
    if (text.isEmpty && attachment == null) {
      _showSnack('Message or attachment is required.');
      return;
    }

    setState(() => _sending = true);

    try {
      String? attachmentUrl;
      String? attachmentName;
      String? attachmentType;

      if (attachment != null) {
        final bytes = attachment.bytes;
        if (bytes == null) {
          throw Exception('Attachment bytes unavailable.');
        }
        final upload = await ref.read(mediaUploadServiceProvider).uploadBytes(
              bytes: bytes,
              fileName: attachment.name,
              folder: 'chat_attachments',
              ownerId: me.id,
            );
        attachmentUrl = upload.url;
        attachmentName = attachment.name;
        attachmentType = upload.contentType;
      }

      await FirestoreService.sendConversationMessage(
        senderId: me.id,
        receiverId: other,
        text: text.isEmpty ? null : text,
        attachmentUrl: attachmentUrl,
        attachmentName: attachmentName,
        attachmentType: attachmentType,
      );

      _messageController.clear();
    } catch (error) {
      _showSnack('Failed to send message: $error');
    } finally {
      if (mounted) {
        setState(() => _sending = false);
      }
    }
  }

  Future<void> _pickAndSendAttachment() async {
    final picked = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['jpg', 'jpeg', 'png', 'pdf'],
      withData: true,
    );
    if (picked == null || picked.files.isEmpty) {
      return;
    }
    await _sendMessage(attachment: picked.files.first);
  }

  void _showSnack(String message) {
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final me = ref.watch(currentUserProvider);
    final other = _caregiverController.text.trim();
    final messagesAsync = (me != null && other.isNotEmpty)
        ? ref.watch(_messagesProvider((me: me.id, other: other)))
        : const AsyncValue<List<Map<String, dynamic>>>.data(<Map<String, dynamic>>[]);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Patient-Caregiver Chat'),
        actions: const [SyncStatusAction()],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: _caregiverController,
              decoration: const InputDecoration(
                labelText: 'Caregiver ID',
                hintText: 'Enter caregiver user ID',
              ),
              onChanged: (_) => setState(() {}),
            ),
          ),
          Expanded(
            child: messagesAsync.when(
              data: (messages) {
                if (messages.isEmpty) {
                  return const Center(
                    child: Text('No messages yet. Start the conversation.'),
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final msg = messages[index];
                    final mine = msg['senderId'] == me?.id;
                    return Align(
                      alignment: mine ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: mine
                              ? AppTheme.primaryColor.withValues(alpha: 0.2)
                              : Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          crossAxisAlignment:
                              mine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                          children: [
                            if ((msg['text'] as String?)?.isNotEmpty ?? false)
                              Text(msg['text'] as String),
                            if ((msg['attachmentName'] as String?)?.isNotEmpty ?? false)
                              Padding(
                                padding: const EdgeInsets.only(top: 6),
                                child: Text(
                                  'Attachment: ${msg['attachmentName']}',
                                  style: const TextStyle(fontSize: 12),
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => Center(child: Text('Chat error: $error')),
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  IconButton(
                    onPressed: _sending ? null : _pickAndSendAttachment,
                    icon: const Icon(Icons.attach_file),
                  ),
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      minLines: 1,
                      maxLines: 4,
                      decoration: const InputDecoration(
                        hintText: 'Type a message...',
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: _sending ? null : () => _sendMessage(),
                    icon: _sending
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.send),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
