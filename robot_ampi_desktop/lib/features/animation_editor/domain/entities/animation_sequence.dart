import 'package:equatable/equatable.dart';
import 'animation_frame.dart';

/// Loop mode for animation playback
enum LoopMode {
  once,
  infinite,
  pingpong,
}

/// Represents a complete animation sequence with multiple frames
class AnimationSequence extends Equatable {
  final String id;
  final String name;
  final String description;
  final List<AnimationFrame> frames;
  final LoopMode loopMode;
  final DateTime createdAt;
  final DateTime modifiedAt;

  const AnimationSequence({
    required this.id,
    required this.name,
    this.description = '',
    this.frames = const [],
    this.loopMode = LoopMode.infinite,
    required this.createdAt,
    required this.modifiedAt,
  });

  /// Create a new empty animation sequence
  factory AnimationSequence.empty({String? id}) {
    final now = DateTime.now();
    return AnimationSequence(
      id: id ?? _generateId(),
      name: 'New Animation',
      description: '',
      frames: [AnimationFrame.blank(id: AnimationFrame.generateId())],
      loopMode: LoopMode.infinite,
      createdAt: now,
      modifiedAt: now,
    );
  }

  /// Get total duration of animation
  int get totalDuration => frames.fold(0, (sum, frame) => sum + frame.duration);

  /// Get frame count
  int get frameCount => frames.length;

  /// Check if animation is empty
  bool get isEmpty => frames.isEmpty;

  /// Add a new frame
  AnimationSequence addFrame(AnimationFrame frame) {
    return AnimationSequence(
      id: id,
      name: name,
      description: description,
      frames: [...frames, frame],
      loopMode: loopMode,
      createdAt: createdAt,
      modifiedAt: DateTime.now(),
    );
  }

  /// Remove frame at index
  AnimationSequence removeFrame(int index) {
    if (index < 0 || index >= frames.length) return this;
    final newFrames = List<AnimationFrame>.from(frames)..removeAt(index);
    return AnimationSequence(
      id: id,
      name: name,
      description: description,
      frames: newFrames.isEmpty ? [AnimationFrame.blank()] : newFrames,
      loopMode: loopMode,
      createdAt: createdAt,
      modifiedAt: DateTime.now(),
    );
  }

  /// Update frame at index
  AnimationSequence updateFrame(int index, AnimationFrame frame) {
    if (index < 0 || index >= frames.length) return this;
    final newFrames = List<AnimationFrame>.from(frames);
    newFrames[index] = frame;
    return AnimationSequence(
      id: id,
      name: name,
      description: description,
      frames: newFrames,
      loopMode: loopMode,
      createdAt: createdAt,
      modifiedAt: DateTime.now(),
    );
  }

  /// Duplicate frame at index
  AnimationSequence duplicateFrame(int index) {
    if (index < 0 || index >= frames.length) return this;
    final frame = frames[index];
    final duplicatedFrame = AnimationFrame(
      id: AnimationFrame.generateId(),
      duration: frame.duration,
      leftEye: frame.leftEye.map((row) => List<LEDState>.from(row)).toList(),
      rightEye: frame.rightEye.map((row) => List<LEDState>.from(row)).toList(),
      yaw: frame.yaw,
      pitch: frame.pitch,
      sound: frame.sound,
    );
    final newFrames = List<AnimationFrame>.from(frames)..insert(index + 1, duplicatedFrame);
    return AnimationSequence(
      id: id,
      name: name,
      description: description,
      frames: newFrames,
      loopMode: loopMode,
      createdAt: createdAt,
      modifiedAt: DateTime.now(),
    );
  }

  /// Move frame from one index to another
  AnimationSequence moveFrame(int fromIndex, int toIndex) {
    if (fromIndex < 0 || fromIndex >= frames.length) return this;
    if (toIndex < 0 || toIndex >= frames.length) return this;
    if (fromIndex == toIndex) return this;

    final newFrames = List<AnimationFrame>.from(frames);
    final frame = newFrames.removeAt(fromIndex);
    newFrames.insert(toIndex, frame);

    return AnimationSequence(
      id: id,
      name: name,
      description: description,
      frames: newFrames,
      loopMode: loopMode,
      createdAt: createdAt,
      modifiedAt: DateTime.now(),
    );
  }

  /// Set loop mode
  AnimationSequence setLoopMode(LoopMode mode) {
    return AnimationSequence(
      id: id,
      name: name,
      description: description,
      frames: frames,
      loopMode: mode,
      createdAt: createdAt,
      modifiedAt: DateTime.now(),
    );
  }

  /// Update name
  AnimationSequence updateName(String newName) {
    return AnimationSequence(
      id: id,
      name: newName,
      description: description,
      frames: frames,
      loopMode: loopMode,
      createdAt: createdAt,
      modifiedAt: DateTime.now(),
    );
  }

  /// Update description
  AnimationSequence updateDescription(String newDescription) {
    return AnimationSequence(
      id: id,
      name: name,
      description: newDescription,
      frames: frames,
      loopMode: loopMode,
      createdAt: createdAt,
      modifiedAt: DateTime.now(),
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'frames': frames.map((f) => f.toJson()).toList(),
      'loopMode': loopMode.index,
      'createdAt': createdAt.toIso8601String(),
      'modifiedAt': modifiedAt.toIso8601String(),
    };
  }

  /// Create from JSON
  factory AnimationSequence.fromJson(Map<String, dynamic> json) {
    return AnimationSequence(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String? ?? '',
      frames: (json['frames'] as List<dynamic>)
          .map((f) => AnimationFrame.fromJson(f as Map<String, dynamic>))
          .toList(),
      loopMode: LoopMode.values[json['loopMode'] as int? ?? 0],
      createdAt: DateTime.parse(json['createdAt'] as String),
      modifiedAt: DateTime.parse(json['modifiedAt'] as String),
    );
  }

  /// Export to C code for Arduino
  String toCCode(String variableName) {
    final buffer = StringBuffer();

    // Header
    buffer.writeln('// Animation: $name');
    buffer.writeln('// Generated by Robot-AmPI Desktop Controller');
    buffer.writeln('// Description: $description');
    buffer.writeln('// Frames: ${frames.length}, Total Duration: ${totalDuration}ms');
    buffer.writeln();

    // Left eye frames
    buffer.writeln('// Left eye frames');
    buffer.writeln('const uint8_t ANIM_${variableName}_LEFT[][${frames.length * 8}] = {');
    for (final frame in frames) {
      final bytes = frame.leftEyeToBytes();
      buffer.write('  ');
      for (final byte in bytes) {
        buffer.write('0x${byte.toRadixString(16).padLeft(2, '0')}, ');
      }
      buffer.writeln('// Frame duration: ${frame.duration}ms, Yaw: ${frame.yaw}, Pitch: ${frame.pitch}');
    }
    buffer.writeln('};');
    buffer.writeln();

    // Right eye frames
    buffer.writeln('// Right eye frames');
    buffer.writeln('const uint8_t ANIM_${variableName}_RIGHT[][${frames.length * 8}] = {');
    for (final frame in frames) {
      final bytes = frame.rightEyeToBytes();
      buffer.write('  ');
      for (final byte in bytes) {
        buffer.write('0x${byte.toRadixString(16).padLeft(2, '0')}, ');
      }
      buffer.writeln('// Frame duration: ${frame.duration}ms, Yaw: ${frame.yaw}, Pitch: ${frame.pitch}');
    }
    buffer.writeln('};');
    buffer.writeln();

    // Frame durations
    buffer.writeln('// Frame durations (milliseconds)');
    buffer.writeln('const uint16_t ANIM_${variableName}_DURATIONS[] = {');
    buffer.write('  ');
    for (final frame in frames) {
      buffer.write('${frame.duration}, ');
    }
    buffer.writeln('};');
    buffer.writeln();

    // Head positions
    buffer.writeln('// Head positions');
    buffer.writeln('const uint8_t ANIM_${variableName}_YAW[] = {');
    buffer.write('  ');
    for (final frame in frames) {
      buffer.write('${frame.yaw}, ');
    }
    buffer.writeln('};');
    buffer.writeln();

    buffer.writeln('const uint8_t ANIM_${variableName}_PITCH[] = {');
    buffer.write('  ');
    for (final frame in frames) {
      buffer.write('${frame.pitch}, ');
    }
    buffer.writeln('};');
    buffer.writeln();

    // Metadata
    buffer.writeln('// Animation metadata');
    buffer.writeln('const struct {');
    buffer.writeln('  uint8_t frameCount;');
    buffer.writeln('  uint16_t totalDuration;');
    buffer.writeln('  uint8_t loopMode;  // 0=once, 1=infinite, 2=pingpong');
    buffer.writeln('} ANIM_${variableName}_META = {');
    buffer.writeln('  ${frames.length},');
    buffer.writeln('  $totalDuration,');
    buffer.writeln('  ${loopMode.index}');
    buffer.writeln('};');

    return buffer.toString();
  }

  static String _generateId() {
    return 'anim_${DateTime.now().millisecondsSinceEpoch}';
  }

  @override
  List<Object?> get props => [id, name, description, frames, loopMode, createdAt, modifiedAt];
}
