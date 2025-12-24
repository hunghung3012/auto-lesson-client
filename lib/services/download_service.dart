import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';
import 'package:permission_handler/permission_handler.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';

class DownloadService {
  static final DownloadService _instance = DownloadService._internal();
  factory DownloadService() => _instance;
  DownloadService._internal();

  final ApiService _apiService = ApiService();
  final StorageService _storageService = StorageService();

  // Request Storage Permission
  Future<bool> requestStoragePermission() async {
    if (Platform.isAndroid) {
      final status = await Permission.storage.request();
      return status.isGranted;
    }
    return true; // iOS doesn't need this
  }

  // Get Download Directory
  Future<Directory> getDownloadDirectory() async {
    if (Platform.isAndroid) {
      return Directory('/storage/emulated/0/Download/EduMate');
    } else {
      final dir = await getApplicationDocumentsDirectory();
      return Directory('${dir.path}/Downloads');
    }
  }

  // Download File
  Future<String?> downloadFile({
    required String type,
    required String filename,
    required String contentId,
    Function(int, int)? onProgress,
  }) async {
    try {
      // Request permission
      final hasPermission = await requestStoragePermission();
      if (!hasPermission) {
        throw Exception('Storage permission denied');
      }

      // Get download directory
      final downloadDir = await getDownloadDirectory();
      if (!await downloadDir.exists()) {
        await downloadDir.create(recursive: true);
      }

      // Create file path
      final filePath = '${downloadDir.path}/$filename';

      // Download
      final result = await _apiService.downloadFile(
        type,
        filename,
        filePath,
        onProgress: onProgress,
      );

      if (result != null) {
        // Update local path in storage
        await _storageService.updateLocalPath(contentId, filePath);
        return filePath;
      }

      return null;
    } catch (e) {
      print('❌ Download error: $e');
      return null;
    }
  }

  // Open File
  Future<bool> openFile(String filePath) async {
    try {
      final result = await OpenFilex.open(filePath);
      return result.type == ResultType.done;
    } catch (e) {
      print('❌ Open file error: $e');
      return false;
    }
  }

  // Check if file exists locally
  Future<bool> fileExistsLocally(String? localPath) async {
    if (localPath == null) return false;
    return await File(localPath).exists();
  }

  // Get file size
  Future<int> getFileSize(String filePath) async {
    final file = File(filePath);
    if (await file.exists()) {
      return await file.length();
    }
    return 0;
  }

  // Delete local file
  Future<bool> deleteLocalFile(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        await file.delete();
        return true;
      }
      return false;
    } catch (e) {
      print('❌ Delete file error: $e');
      return false;
    }
  }

  // Format file size
  String formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}