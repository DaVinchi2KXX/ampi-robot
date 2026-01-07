import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:robot_ampi_desktop/core/constants/servo_limits.dart';
import 'package:robot_ampi_desktop/features/animation_editor/presentation/providers/animation_provider.dart';

/// Frame editor with head position and duration controls
class FrameEditor extends ConsumerWidget {
  const FrameEditor({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final animationNotifier = ref.watch(currentAnimationProvider.notifier);
    final currentFrame = animationNotifier.currentFrame;

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
                  Icons.tune,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Frame Settings',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const Spacer(),
                Text(
                  'Frame #${animationNotifier.currentFrameIndex + 1}',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Head position controls
            _buildSliderControl(
              context,
              ref,
              'Yaw (Left-Right)',
              Icons.swap_horiz,
              currentFrame.yaw,
              ServoLimits.yawMin,
              ServoLimits.yawMax,
              (value) => animationNotifier.updateHeadPosition(
                yaw: value.round(),
                pitch: currentFrame.pitch,
              ),
            ),
            const SizedBox(height: 12),
            _buildSliderControl(
              context,
              ref,
              'Pitch (Up-Down)',
              Icons.swap_vert,
              currentFrame.pitch,
              ServoLimits.pitchMin,
              ServoLimits.pitchMax,
              (value) => animationNotifier.updateHeadPosition(
                yaw: currentFrame.yaw,
                pitch: value.round(),
              ),
            ),
            const SizedBox(height: 16),

            // Duration control
            Row(
              children: [
                Icon(
                  Icons.timer,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Duration: ${currentFrame.duration}ms',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const Spacer(),
                _buildPresetButton(context, '50ms', () => animationNotifier.updateDuration(50)),
                _buildPresetButton(context, '100ms', () => animationNotifier.updateDuration(100)),
                _buildPresetButton(context, '200ms', () => animationNotifier.updateDuration(200)),
                _buildPresetButton(context, '500ms', () => animationNotifier.updateDuration(500)),
                const SizedBox(width: 8),
                SizedBox(
                  width: 120,
                  child: Slider(
                    value: currentFrame.duration.toDouble(),
                    min: 50,
                    max: 2000,
                    divisions: 39,
                    label: '${currentFrame.duration}ms',
                    onChanged: (value) {
                      animationNotifier.updateDuration(value.round());
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

  Widget _buildSliderControl(
    BuildContext context,
    WidgetRef ref,
    String label,
    IconData icon,
    int value,
    int min,
    int max,
    ValueChanged<double> onChanged,
  ) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: Theme.of(context).colorScheme.primary,
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: Theme.of(context).textTheme.labelMedium,
        ),
        const SizedBox(width: 8),
        Text(
          '$value°',
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        Expanded(
          child: Slider(
            value: value.toDouble(),
            min: min.toDouble(),
            max: max.toDouble(),
            divisions: max - min,
            label: '$value°',
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }

  Widget _buildPresetButton(BuildContext context, String label, VoidCallback onPressed) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        minimumSize: const Size(40, 32),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      child: Text(label),
    );
  }
}
