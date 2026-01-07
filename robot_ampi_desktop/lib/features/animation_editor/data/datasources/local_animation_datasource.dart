import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:robot_ampi_desktop/features/animation_editor/domain/entities/animation_sequence.dart';

/// Local data source for storing animations on disk
class LocalAnimationDataSource {
  static const String _animationsDir = 'animations';
  static const String _fileExtension = '.rampi';

  Future<Directory> get _animationsDirectory async {
    final appDocDir = await getApplicationDocumentsDirectory();
    final animationsPath = Directory('${appDocDir.path}/$_animationsDir');

    if (!await animationsPath.exists()) {
      await animationsPath.create(recursive: true);
    }

    return animationsPath;
  }

  /// Get all animation files
  Future<List<File>> getAnimationFiles() async {
    final dir = await _animationsDirectory;
    final entities = dir.listSync();

    return entities
        .whereType<File>()
        .where((file) => file.path.endsWith(_fileExtension))
        .toList();
  }

  /// Load animation from file
  Future<AnimationSequence> loadAnimation(File file) async {
    final jsonContent = await file.readAsString();
    final json = jsonDecode(jsonContent) as Map<String, dynamic>;
    return AnimationSequence.fromJson(json);
  }

  /// Save animation to file
  Future<File> saveAnimation(AnimationSequence animation) async {
    final dir = await _animationsDirectory;
    final fileName = '${_sanitizeFileName(animation.name)}_${animation.id}$_fileExtension';
    final file = File('${dir.path}/$fileName');

    final jsonContent = jsonEncode(animation.toJson());
    await file.writeAsString(jsonContent);

    return file;
  }

  /// Delete animation file
  Future<void> deleteAnimation(String id) async {
    final files = await getAnimationFiles();
    for (final file in files) {
      if (file.path.contains(id)) {
        await file.delete();
      }
    }
  }

  /// Export animation to custom file path
  Future<File> exportAnimation(AnimationSequence animation, String filePath) async {
    final file = File(filePath);
    final jsonContent = jsonEncode(animation.toJson());
    await file.writeAsString(jsonContent);
    return file;
  }

  /// Import animation from file path
  Future<AnimationSequence> importAnimation(String filePath) async {
    final file = File(filePath);
    final jsonContent = await file.readAsString();
    final json = jsonDecode(jsonContent) as Map<String, dynamic>;
    return AnimationSequence.fromJson(json);
  }

  /// Export to C code file
  Future<File> exportToCCode(AnimationSequence animation, String filePath) async {
    final file = File(filePath);
    final cCode = animation.toCCode(_sanitizeFileName(animation.name).toUpperCase());
    await file.writeAsString(cCode);
    return file;
  }

  String _sanitizeFileName(String name) {
    return name
        .toLowerCase()
        .replaceAll(RegExp(r'[^\w\-]'), '_')
        .replaceAll(RegExp(r'_+'), '_')
        .replaceAll(RegExp(r'^_|_$'), '');
  }
}
