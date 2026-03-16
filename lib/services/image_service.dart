import 'dart:io';
import 'package:image_picker/image_picker.dart';

class ImageService {
  final ImagePicker _picker = ImagePicker();

  Future<File?> pickFromGallery({int maxWidth = 1024, int quality = 85}) async {
    final XFile? xFile = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: maxWidth.toDouble(),
      imageQuality: quality,
    );
    return xFile != null ? File(xFile.path) : null;
  }

  Future<File?> pickFromCamera({int maxWidth = 1024, int quality = 85}) async {
    final XFile? xFile = await _picker.pickImage(
      source: ImageSource.camera,
      maxWidth: maxWidth.toDouble(),
      imageQuality: quality,
    );
    return xFile != null ? File(xFile.path) : null;
  }

  Future<List<File>> pickMultipleFromGallery({int maxWidth = 1024, int quality = 85}) async {
    final List<XFile> xFiles = await _picker.pickMultiImage(
      maxWidth: maxWidth.toDouble(),
      imageQuality: quality,
    );
    return xFiles.map((xf) => File(xf.path)).toList();
  }
}
