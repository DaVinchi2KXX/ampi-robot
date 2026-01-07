import 'dart:async';
import 'package:robot_ampi_desktop/features/animation_editor/data/datasources/local_animation_datasource.dart';
import 'package:robot_ampi_desktop/features/animation_editor/domain/entities/animation_sequence.dart';
import 'package:robot_ampi_desktop/features/animation_editor/domain/repositories/animation_repository.dart';

/// Implementation of animation repository using local storage
class AnimationRepositoryImpl implements AnimationRepository {
  final LocalAnimationDataSource _dataSource;

  AnimationRepositoryImpl({required LocalAnimationDataSource dataSource})
      : _dataSource = dataSource;

  final _controller = StreamController<List<AnimationSequence>>.broadcast();

  @override
  Future<List<AnimationSequence>> getAllAnimations() async {
    final files = await _dataSource.getAnimationFiles();
    final animations = <AnimationSequence>[];

    for (final file in files) {
      try {
        final animation = await _dataSource.loadAnimation(file);
        animations.add(animation);
      } catch (e) {
        // Skip corrupted files
        continue;
      }
    }

    // Sort by modified date
    animations.sort((a, b) => b.modifiedAt.compareTo(a.modifiedAt));
    _controller.add(animations);

    return animations;
  }

  @override
  Future<AnimationSequence?> getAnimation(String id) async {
    final animations = await getAllAnimations();
    try {
      return animations.firstWhere((anim) => anim.id == id);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> saveAnimation(AnimationSequence animation) async {
    await _dataSource.saveAnimation(animation);
    await _refresh();
  }

  @override
  Future<void> deleteAnimation(String id) async {
    await _dataSource.deleteAnimation(id);
    await _refresh();
  }

  @override
  Future<String> exportToFile(AnimationSequence animation, String filePath) async {
    final file = await _dataSource.exportAnimation(animation, filePath);
    return file.path;
  }

  @override
  Future<AnimationSequence> importFromFile(String filePath) async {
    return await _dataSource.importAnimation(filePath);
  }

  @override
  String exportToCCode(AnimationSequence animation, String variableName) {
    return animation.toCCode(variableName);
  }

  @override
  Stream<List<AnimationSequence>> watchAnimations() => _controller.stream;

  Future<void> _refresh() async {
    await getAllAnimations();
  }

  void dispose() {
    _controller.close();
  }
}
