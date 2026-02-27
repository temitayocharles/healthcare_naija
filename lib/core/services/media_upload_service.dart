import 'dart:typed_data';

import 'package:firebase_storage/firebase_storage.dart';

class MediaUploadException implements Exception {
  MediaUploadException(this.message);

  final String message;

  @override
  String toString() => message;
}

class MediaUploadResult {
  MediaUploadResult({
    required this.url,
    required this.path,
    required this.contentType,
    required this.bytes,
  });

  final String url;
  final String path;
  final String contentType;
  final int bytes;
}

class MediaUploadService {
  static const int maxBytes = 10 * 1024 * 1024;
  static const Set<String> allowedExtensions = {
    'jpg',
    'jpeg',
    'png',
    'pdf',
  };

  final FirebaseStorage _storage;

  MediaUploadService({FirebaseStorage? storage})
      : _storage = storage ?? FirebaseStorage.instance;

  MediaUploadResult _validate({
    required Uint8List bytes,
    required String fileName,
  }) {
    if (bytes.isEmpty) {
      throw MediaUploadException('File is empty.');
    }
    if (bytes.lengthInBytes > maxBytes) {
      throw MediaUploadException('File too large. Max allowed size is 10MB.');
    }

    final extension = fileName.split('.').last.toLowerCase();
    if (!allowedExtensions.contains(extension)) {
      throw MediaUploadException('Unsupported file type. Allowed: JPG, PNG, PDF.');
    }

    final contentType = switch (extension) {
      'jpg' || 'jpeg' => 'image/jpeg',
      'png' => 'image/png',
      'pdf' => 'application/pdf',
      _ => 'application/octet-stream',
    };

    return MediaUploadResult(
      url: '',
      path: '',
      contentType: contentType,
      bytes: bytes.lengthInBytes,
    );
  }

  Future<MediaUploadResult> uploadBytes({
    required Uint8List bytes,
    required String fileName,
    required String folder,
    required String ownerId,
  }) async {
    final validated = _validate(bytes: bytes, fileName: fileName);
    final ext = fileName.split('.').last.toLowerCase();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final sanitizedName = fileName.replaceAll(RegExp(r'[^a-zA-Z0-9._-]'), '_');
    final path = '$folder/$ownerId/${timestamp}_$sanitizedName';

    final ref = _storage.ref().child(path);
    final metadata = SettableMetadata(
      contentType: validated.contentType,
      customMetadata: {
        'ownerId': ownerId,
        'sourceName': fileName,
        'extension': ext,
      },
    );

    await ref.putData(bytes, metadata);
    final downloadUrl = await ref.getDownloadURL();

    return MediaUploadResult(
      url: downloadUrl,
      path: path,
      contentType: validated.contentType,
      bytes: validated.bytes,
    );
  }
}
