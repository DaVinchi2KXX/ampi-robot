import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:robot_ampi_desktop/features/animation_editor/presentation/providers/animation_provider.dart';

/// Timeline widget for managing animation frames
class AnimationTimeline extends ConsumerWidget {
  const AnimationTimeline({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final animationNotifier = ref.watch(currentAnimationProvider.notifier);
    final animation = ref.watch(currentAnimationProvider);
    final currentFrameIndex = animationNotifier.currentFrameIndex;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with controls
            Row(
              children: [
                Icon(
                  Icons.movie_filter,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Timeline (${animation.frames.length} frames)',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const Spacer(),
                IconButton.filled(
                  icon: const Icon(Icons.add),
                  tooltip: 'Add Frame',
                  onPressed: () => animationNotifier.addFrame(),
                ),
                const SizedBox(width: 8),
                IconButton.filledTonal(
                  icon: const Icon(Icons.delete),
                  tooltip: 'Delete Frame',
                  onPressed: animation.frames.length > 1
                      ? () => animationNotifier.deleteFrame()
                      : null,
                ),
                const SizedBox(width: 8),
                IconButton.filledTonal(
                  icon: const Icon(Icons.content_copy),
                  tooltip: 'Duplicate Frame',
                  onPressed: () => animationNotifier.duplicateFrame(),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Frames list
            if (animation.frames.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    children: [
                      Icon(
                        Icons.filter_none,
                        size: 48,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'No frames yet',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              Container(
                height: 120,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.all(8),
                  itemCount: animation.frames.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final frame = animation.frames[index];
                    final isSelected = index == currentFrameIndex;

                    return _buildFrameThumbnail(
                      context,
                      ref,
                      index,
                      frame,
                      isSelected,
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildFrameThumbnail(
    BuildContext context,
    WidgetRef ref,
    int index,
    dynamic frame,
    bool isSelected,
  ) {
    final animationNotifier = ref.read(currentAnimationProvider.notifier);

    return GestureDetector(
      onTap: () => animationNotifier.setCurrentFrameIndex(index),
      child: DragTarget<int>(
        onWillAcceptWithDetails: (details) => details.data != index,
        onAcceptWithDetails: (details) {
          animationNotifier.moveFrame(details.data, index);
        },
        builder: (context, candidateData, rejectedData) {
          return Draggable<int>(
            data: index,
            feedback: Material(
              elevation: 8,
              borderRadius: BorderRadius.circular(8),
              child: Container(
                width: 100,
                height: 100,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: candidateData.isNotEmpty
                      ? Colors.green.withAlpha(100)
                      : null,
                  border: Border.all(
                    color: isSelected
                        ? Theme.of(context).colorScheme.primary
                        : Colors.transparent,
                    width: isSelected ? 3 : 0,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Frame number
                    Text(
                      '#${index + 1}',
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                    const SizedBox(height: 4),
                    // Eye icons preview (simplified)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildEyePreview(context, frame.leftEye, Colors.red),
                        const SizedBox(width: 4),
                        _buildEyePreview(context, frame.rightEye, Colors.blue),
                      ],
                    ),
                    const SizedBox(height: 4),
                    // Duration
                    Text(
                      '${frame.duration}ms',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            child: Container(
              width: 100,
              height: 100,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: candidateData.isNotEmpty
                    ? Colors.green.withAlpha(100)
                    : isSelected
                        ? Theme.of(context).colorScheme.primaryContainer
                        : null,
                border: Border.all(
                  color: isSelected
                      ? Theme.of(context).colorScheme.primary
                      : Colors.grey.shade700,
                  width: isSelected ? 3 : 1,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Frame number
                  Text(
                    '#${index + 1}',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Eye icons preview
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildEyePreview(context, frame.leftEye, Colors.red),
                      const SizedBox(width: 4),
                      _buildEyePreview(context, frame.rightEye, Colors.blue),
                    ],
                  ),
                  const SizedBox(height: 4),
                  // Duration
                  Text(
                    '${frame.duration}ms',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEyePreview(BuildContext context, dynamic matrix, Color color) {
    // Simplified preview showing just the on/off pattern
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        color: Colors.grey.shade800,
        border: Border.all(color: color.withValues(alpha: 0.5), width: 1),
        borderRadius: BorderRadius.circular(2),
      ),
      child: CustomPaint(
        painter: _EyePreviewPainter(matrix, color),
      ),
    );
  }
}

class _EyePreviewPainter extends CustomPainter {
  final dynamic matrix;
  final Color color;

  _EyePreviewPainter(this.matrix, this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final cellWidth = size.width / 8;
    final cellHeight = size.height / 8;

    for (int row = 0; row < 8; row++) {
      for (int col = 0; col < 8; col++) {
        final led = matrix[row][col] as dynamic;
        if (led.isOn) {
          canvas.drawRect(
            Rect.fromLTWH(
              col * cellWidth,
              row * cellHeight,
              cellWidth,
              cellHeight,
            ),
            Paint()..color = color,
          );
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
