import 'package:robot_ampi_desktop/features/animation_editor/domain/entities/animation_sequence.dart';

/// Repository for managing animation sequences
abstract class AnimationRepository {
  /// Get all saved animations
  Future<List<AnimationSequence>> getAllAnimations();

  /// Get animation by ID
  Future<AnimationSequence?> getAnimation(String id);

  /// Save animation
  Future<void> saveAnimation(AnimationSequence animation);

  /// Delete animation
  Future<void> deleteAnimation(String id);

  /// Export animation to file
  Future<String> exportToFile(AnimationSequence animation, String filePath);

  /// Import animation from file
  Future<AnimationSequence> importFromFile(String filePath);

  /// Export to C code
  String exportToCCode(AnimationSequence animation, String variableName);

  /// Watch animation changes
  Stream<List<AnimationSequence>> watchAnimations();
}
