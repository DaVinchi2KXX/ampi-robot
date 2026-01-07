import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:robot_ampi_desktop/features/animation_editor/presentation/providers/animation_provider.dart';
import 'package:robot_ampi_desktop/features/connection/presentation/providers/connection_provider.dart';

/// Animation player widget for preview and playback
class AnimationPlayer extends ConsumerWidget {
  const AnimationPlayer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playbackState = ref.watch(animationPlaybackProvider);
    final playbackNotifier = ref.read(animationPlaybackProvider.notifier);
    final animation = ref.watch(currentAnimationProvider);
    final connectionState = ref.watch(connectionStateProvider);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Icon(
                  Icons.play_circle,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Preview & Playback',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const Spacer(),
                // Connection status indicator
                if (connectionState.isConnected)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: Colors.green),
                    ),
                    child: Text(
                      'Connected',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                else
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: Colors.orange),
                    ),
                    child: Text(
                      'Not Connected',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.orange,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),

            // Progress bar
            if (playbackState.animation != null && playbackState.animation!.frames.isNotEmpty)
              Column(
                children: [
                  Row(
                    children: [
                      Text(
                        'Frame ${playbackState.currentFrameIndex + 1} / ${playbackState.animation!.frames.length}',
                        style: Theme.of(context).textTheme.labelMedium,
                      ),
                      const Spacer(),
                      Text(
                        'Speed: ${(playbackState.playbackSpeed * 100).toStringAsFixed(0)}%',
                        style: Theme.of(context).textTheme.labelMedium,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Slider(
                    value: playbackState.currentFrameIndex.toDouble(),
                    min: 0,
                    max: (playbackState.animation!.frames.length - 1).toDouble(),
                    divisions: playbackState.animation!.frames.length - 1,
                    onChanged: (value) {
                      playbackNotifier.goToFrame(value.round());
                    },
                  ),
                ],
              ),

            const SizedBox(height: 16),

            // Playback controls
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Previous frame
                IconButton.filled(
                  icon: const Icon(Icons.skip_previous),
                  tooltip: 'Previous Frame',
                  onPressed: playbackState.animation != null && playbackState.currentFrameIndex > 0
                      ? () => playbackNotifier.goToFrame(playbackState.currentFrameIndex - 1)
                      : null,
                ),
                const SizedBox(width: 16),

                // Play/Pause
                IconButton.filled(
                  iconSize: 48,
                  icon: Icon(
                    playbackState.isPlaying ? Icons.pause : Icons.play_arrow,
                  ),
                  tooltip: playbackState.isPlaying ? 'Pause' : 'Play',
                  onPressed: connectionState.isConnected && animation.frames.isNotEmpty
                      ? () {
                          if (playbackState.isPlaying) {
                            playbackNotifier.pause();
                          } else {
                            playbackNotifier.play(animation);
                          }
                        }
                      : null,
                ),
                const SizedBox(width: 16),

                // Stop
                IconButton.filled(
                  icon: const Icon(Icons.stop),
                  tooltip: 'Stop',
                  onPressed: playbackState.isPlaying
                      ? () => playbackNotifier.stop()
                      : null,
                ),
                const SizedBox(width: 16),

                // Next frame
                IconButton.filled(
                  icon: const Icon(Icons.skip_next),
                  tooltip: 'Next Frame',
                  onPressed: playbackState.animation != null &&
                          playbackState.currentFrameIndex < playbackState.animation!.frames.length - 1
                      ? () => playbackNotifier.goToFrame(playbackState.currentFrameIndex + 1)
                      : null,
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Speed control
            Row(
              children: [
                Icon(
                  Icons.speed,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Playback Speed',
                  style: Theme.of(context).textTheme.labelMedium,
                ),
                const Spacer(),
                _buildSpeedButton(context, '0.5x', 0.5, playbackState.playbackSpeed, (speed) {
                  playbackNotifier.setPlaybackSpeed(speed);
                }),
                _buildSpeedButton(context, '1x', 1.0, playbackState.playbackSpeed, (speed) {
                  playbackNotifier.setPlaybackSpeed(speed);
                }),
                _buildSpeedButton(context, '2x', 2.0, playbackState.playbackSpeed, (speed) {
                  playbackNotifier.setPlaybackSpeed(speed);
                }),
                SizedBox(
                  width: 120,
                  child: Slider(
                    value: playbackState.playbackSpeed,
                    min: 0.1,
                    max: 3.0,
                    divisions: 29,
                    onChanged: (value) {
                      playbackNotifier.setPlaybackSpeed(value);
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSpeedButton(
    BuildContext context,
    String label,
    double speed,
    double currentSpeed,
    ValueChanged<double> onPressed,
  ) {
    final isSelected = currentSpeed == speed;

    return FilledButton.tonal(
      onPressed: () => onPressed(speed),
      style: FilledButton.styleFrom(
        backgroundColor: isSelected
            ? Theme.of(context).colorScheme.primaryContainer
            : null,
        foregroundColor: isSelected
            ? Theme.of(context).colorScheme.onPrimaryContainer
            : null,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        minimumSize: const Size(40, 32),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      child: Text(label),
    );
  }
}
