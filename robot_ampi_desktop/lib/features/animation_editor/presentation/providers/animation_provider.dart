import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:robot_ampi_desktop/core/constants/commands.dart';
import 'package:robot_ampi_desktop/features/animation_editor/data/datasources/local_animation_datasource.dart';
import 'package:robot_ampi_desktop/features/animation_editor/data/repositories/animation_repository_impl.dart';
import 'package:robot_ampi_desktop/features/animation_editor/domain/entities/animation_frame.dart';
import 'package:robot_ampi_desktop/features/animation_editor/domain/entities/animation_sequence.dart';
import 'package:robot_ampi_desktop/features/animation_editor/domain/repositories/animation_repository.dart';
import 'package:robot_ampi_desktop/features/connection/presentation/providers/connection_provider.dart';

// Data source provider
final localAnimationDataSourceProvider = Provider<LocalAnimationDataSource>((ref) {
  return LocalAnimationDataSource();
});

// Repository provider
final animationRepositoryProvider = Provider<AnimationRepository>((ref) {
  final dataSource = ref.watch(localAnimationDataSourceProvider);
  return AnimationRepositoryImpl(dataSource: dataSource);
});

// Saved animations list provider
final savedAnimationsProvider = FutureProvider.autoDispose<List<AnimationSequence>>((ref) async {
  final repository = ref.watch(animationRepositoryProvider);
  return await repository.getAllAnimations();
});

// Current animation sequence provider
final currentAnimationProvider = StateNotifierProvider<CurrentAnimationNotifier, AnimationSequence>((ref) {
  return CurrentAnimationNotifier();
});

/// Notifier for managing current animation being edited
class CurrentAnimationNotifier extends StateNotifier<AnimationSequence> {
  CurrentAnimationNotifier() : super(AnimationSequence.empty());

  int _currentFrameIndex = 0;

  int get currentFrameIndex => _currentFrameIndex;
  AnimationFrame get currentFrame => state.frames.isNotEmpty ? state.frames[_currentFrameIndex] : AnimationFrame.blank();

  /// Load an existing animation
  void loadAnimation(AnimationSequence animation) {
    _currentFrameIndex = 0;
    state = animation;
  }

  /// Create new animation
  void newAnimation() {
    _currentFrameIndex = 0;
    state = AnimationSequence.empty();
  }

  /// Update current frame
  void updateCurrentFrame(AnimationFrame frame) {
    state = state.updateFrame(_currentFrameIndex, frame);
  }

  /// Set current frame index
  void setCurrentFrameIndex(int index) {
    if (index >= 0 && index < state.frames.length) {
      _currentFrameIndex = index;
    }
  }

  /// Add new frame
  void addFrame() {
    final prevFrame = currentFrame;
    final newFrame = AnimationFrame(
      id: AnimationFrame.generateId(),
      duration: prevFrame.duration,
      leftEye: prevFrame.leftEye.map((row) => List<LEDState>.from(row)).toList(),
      rightEye: prevFrame.rightEye.map((row) => List<LEDState>.from(row)).toList(),
      yaw: prevFrame.yaw,
      pitch: prevFrame.pitch,
      sound: prevFrame.sound,
    );
    state = state.addFrame(newFrame);
    _currentFrameIndex = state.frames.length - 1;
  }

  /// Delete current frame
  void deleteFrame() {
    if (state.frames.length > 1) {
      state = state.removeFrame(_currentFrameIndex);
      if (_currentFrameIndex >= state.frames.length) {
        _currentFrameIndex = state.frames.length - 1;
      }
    }
  }

  /// Duplicate current frame
  void duplicateFrame() {
    state = state.duplicateFrame(_currentFrameIndex);
    _currentFrameIndex++;
  }

  /// Move frame
  void moveFrame(int fromIndex, int toIndex) {
    state = state.moveFrame(fromIndex, toIndex);
    _currentFrameIndex = toIndex;
  }

  /// Update animation name
  void updateName(String name) {
    state = state.updateName(name);
  }

  /// Update description
  void updateDescription(String description) {
    state = state.updateDescription(description);
  }

  /// Set loop mode
  void setLoopMode(LoopMode mode) {
    state = state.setLoopMode(mode);
  }

  /// Edit LED on current frame
  void toggleLED({required bool isLeft, required int row, required int col}) {
    final updatedFrame = currentFrame.toggleLED(isLeft: isLeft, row: row, col: col);
    updateCurrentFrame(updatedFrame);
  }

  void setLED({required bool isLeft, required int row, required int col, required bool isOn}) {
    final updatedFrame = currentFrame.setLED(isLeft: isLeft, row: row, col: col, isOn: isOn);
    updateCurrentFrame(updatedFrame);
  }

  void clearEye({required bool isLeft}) {
    final updatedFrame = currentFrame.clear(isLeft: isLeft);
    updateCurrentFrame(updatedFrame);
  }

  void fillEye({required bool isLeft}) {
    final updatedFrame = currentFrame.fill(isLeft: isLeft);
    updateCurrentFrame(updatedFrame);
  }

  void invertEye({required bool isLeft}) {
    final updatedFrame = currentFrame.invert(isLeft: isLeft);
    updateCurrentFrame(updatedFrame);
  }

  void rotateEye({required bool isLeft}) {
    final updatedFrame = currentFrame.rotate(isLeft: isLeft);
    updateCurrentFrame(updatedFrame);
  }

  void shiftUp({required bool isLeft}) {
    final updatedFrame = currentFrame.shiftUp(isLeft: isLeft);
    updateCurrentFrame(updatedFrame);
  }

  void shiftDown({required bool isLeft}) {
    final updatedFrame = currentFrame.shiftDown(isLeft: isLeft);
    updateCurrentFrame(updatedFrame);
  }

  void shiftLeft({required bool isLeft}) {
    final updatedFrame = currentFrame.shiftLeft(isLeft: isLeft);
    updateCurrentFrame(updatedFrame);
  }

  void shiftRight({required bool isLeft}) {
    final updatedFrame = currentFrame.shiftRight(isLeft: isLeft);
    updateCurrentFrame(updatedFrame);
  }

  void setRow({required bool isLeft, required int row, required bool isOn}) {
    final updatedFrame = currentFrame.setRow(isLeft: isLeft, row: row, isOn: isOn);
    updateCurrentFrame(updatedFrame);
  }

  void setColumn({required bool isLeft, required int col, required bool isOn}) {
    final updatedFrame = currentFrame.setColumn(isLeft: isLeft, col: col, isOn: isOn);
    updateCurrentFrame(updatedFrame);
  }

  /// Update head position for current frame
  void updateHeadPosition({required int yaw, required int pitch}) {
    final updatedFrame = currentFrame.copyWith(yaw: yaw, pitch: pitch);
    updateCurrentFrame(updatedFrame);
  }

  /// Update frame duration
  void updateDuration(int duration) {
    final updatedFrame = currentFrame.copyWith(duration: duration);
    updateCurrentFrame(updatedFrame);
  }
}

// Animation playback provider
final animationPlaybackProvider = StateNotifierProvider<AnimationPlaybackNotifier, AnimationPlaybackState>((ref) {
  return AnimationPlaybackNotifier(ref.read(connectionStateProvider.notifier));
});

/// State for animation playback
class AnimationPlaybackState {
  final bool isPlaying;
  final int currentFrameIndex;
  final double playbackSpeed;
  final AnimationSequence? animation;

  const AnimationPlaybackState({
    this.isPlaying = false,
    this.currentFrameIndex = 0,
    this.playbackSpeed = 1.0,
    this.animation,
  });

  AnimationPlaybackState copyWith({
    bool? isPlaying,
    int? currentFrameIndex,
    double? playbackSpeed,
    AnimationSequence? animation,
  }) {
    return AnimationPlaybackState(
      isPlaying: isPlaying ?? this.isPlaying,
      currentFrameIndex: currentFrameIndex ?? this.currentFrameIndex,
      playbackSpeed: playbackSpeed ?? this.playbackSpeed,
      animation: animation ?? this.animation,
    );
  }
}

/// Notifier for managing animation playback
class AnimationPlaybackNotifier extends StateNotifier<AnimationPlaybackState> {
  final ConnectionNotifier _connectionNotifier;
  Timer? _playbackTimer;

  AnimationPlaybackNotifier(this._connectionNotifier)
      : super(const AnimationPlaybackState());

  /// Play animation
  void play(AnimationSequence animation) {
    _playbackTimer?.cancel();
    state = AnimationPlaybackState(
      isPlaying: true,
      currentFrameIndex: 0,
      playbackSpeed: state.playbackSpeed,
      animation: animation,
    );
    _startPlayback();
  }

  /// Pause playback
  void pause() {
    _playbackTimer?.cancel();
    state = state.copyWith(isPlaying: false);
  }

  /// Stop playback and reset
  void stop() {
    _playbackTimer?.cancel();
    state = const AnimationPlaybackState();
  }

  /// Set playback speed
  void setPlaybackSpeed(double speed) {
    state = state.copyWith(playbackSpeed: speed.clamp(0.1, 3.0));
    if (state.isPlaying) {
      // Restart with new speed
      final animation = state.animation;
      if (animation != null) {
        play(animation);
      }
    }
  }

  /// Go to specific frame
  void goToFrame(int index) {
    final animation = state.animation;
    if (animation == null || index < 0 || index >= animation.frames.length) return;

    state = state.copyWith(currentFrameIndex: index);
    _playFrame(animation.frames[index]);
  }

  void _startPlayback() {
    final animation = state.animation;
    if (animation == null || animation.frames.isEmpty) return;

    _playbackTimer = Timer.periodic(
      Duration(milliseconds: (animation.frames[state.currentFrameIndex].duration / state.playbackSpeed).round()),
      (timer) {
        final currentAnimation = state.animation;
        if (currentAnimation == null || !state.isPlaying) {
          timer.cancel();
          return;
        }

        final frameIndex = state.currentFrameIndex;
        final frame = currentAnimation.frames[frameIndex];
        _playFrame(frame);

        // Move to next frame
        int nextIndex = frameIndex + 1;

        // Handle loop modes
        if (nextIndex >= currentAnimation.frames.length) {
          switch (currentAnimation.loopMode) {
            case LoopMode.once:
              pause();
              return;
            case LoopMode.infinite:
              nextIndex = 0;
              break;
            case LoopMode.pingpong:
              // TODO: Implement ping-pong playback
              nextIndex = 0;
              break;
          }
        }

        state = state.copyWith(currentFrameIndex: nextIndex);
      },
    );
  }

  Future<void> _playFrame(AnimationFrame frame) async {
    if (!_connectionNotifier.isConnected) return;

    // Send head position
    await _connectionNotifier.sendData(
      SerialCommands.buildMoveCommand(frame.yaw, frame.pitch),
    );

    // Send eye icons (need to implement this in Arduino firmware)
    // For now, we'll use the existing emotion system
    // TODO: Add custom frame display command to Arduino
  }

  @override
  void dispose() {
    _playbackTimer?.cancel();
    super.dispose();
  }
}

// Export options provider
final exportOptionsProvider = Provider<ExportOptions>((ref) {
  return const ExportOptions();
});

class ExportOptions {
  final String defaultDirectory;
  final List<String> supportedFormats;

  const ExportOptions({
    this.defaultDirectory = '',
    this.supportedFormats = const ['.rampi', '.c', '.h', '.json'],
  });
}
