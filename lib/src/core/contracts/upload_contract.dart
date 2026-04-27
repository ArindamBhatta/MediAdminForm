/// Result of a successful upload operation.
class UploadResult {
  final String downloadUrl;
  final String storagePath;
  final String fileName;
  final int fileSizeBytes;
  final String contentType;
  final DateTime uploadedAt;
  final String? uploadedByUserId;
  final String moduleId;

  const UploadResult({
    required this.downloadUrl,
    required this.storagePath,
    required this.fileName,
    required this.fileSizeBytes,
    required this.contentType,
    required this.uploadedAt,
    required this.moduleId,
    this.uploadedByUserId,
  });
}

/// Configuration for an upload operation.
class UploadConfig {
  final String moduleId;
  final String entityId;
  final String folder; // e.g. 'profile', 'documents', 'images'
  final Set<String> allowedExtensions; // e.g. {'jpg', 'png', 'pdf'}
  final int maxFileSizeBytes;

  const UploadConfig({
    required this.moduleId,
    required this.entityId,
    required this.folder,
    this.allowedExtensions = const {'jpg', 'jpeg', 'png', 'webp'},
    this.maxFileSizeBytes = 5 * 1024 * 1024, // 5 MB default
  });
}

/// Abstract contract for upload capability.
/// The Firebase adapter implements this; core never imports storage directly.
abstract class UploadCapability {
  /// Pick a file, validate it, upload it and return the result.
  Future<UploadResult> upload(UploadConfig config);

  /// Delete a previously uploaded file by its storage path.
  Future<void> delete(String storagePath);

  /// Replace an existing upload (delete old, upload new).
  Future<UploadResult> replace(String oldStoragePath, UploadConfig config);
}
