import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:robot_ampi_desktop/features/animation_editor/domain/entities/animation_frame.dart';
import 'package:robot_ampi_desktop/features/animation_editor/presentation/providers/animation_provider.dart';

/// LED Matrix Editor widget for 8x8 eye matrices
class LEDMatrixEditor extends ConsumerWidget {
  final bool isLeftEye;
  final String label;

  const LEDMatrixEditor({
    super.key,
    required this.isLeftEye,
    required this.label,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final animationNotifier = ref.watch(currentAnimationProvider.notifier);
    final currentFrame = animationNotifier.currentFrame;
    final matrix = isLeftEye ? currentFrame.leftEye : currentFrame.rightEye;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Header with label and toolbar
            Row(
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const Spacer(),
                _buildToolButton(context, Icons.clear, 'Clear', () {
                  animationNotifier.clearEye(isLeft: isLeftEye);
                }),
                _buildToolButton(context, Icons.grid_on, 'Fill', () {
                  animationNotifier.fillEye(isLeft: isLeftEye);
                }),
                _buildToolButton(context, Icons.flip, 'Invert', () {
                  animationNotifier.invertEye(isLeft: isLeftEye);
                }),
                _buildToolButton(context, Icons.rotate_right, 'Rotate', () {
                  animationNotifier.rotateEye(isLeft: isLeftEye);
                }),
              ],
            ),
            const SizedBox(height: 16),

            // Shift controls
            Wrap(
              spacing: 8,
              children: [
                _buildSmallToolButton(context, Icons.arrow_upward, 'Up', () {
                  animationNotifier.shiftUp(isLeft: isLeftEye);
                }),
                _buildSmallToolButton(context, Icons.arrow_downward, 'Down', () {
                  animationNotifier.shiftDown(isLeft: isLeftEye);
                }),
                _buildSmallToolButton(context, Icons.arrow_back, 'Left', () {
                  animationNotifier.shiftLeft(isLeft: isLeftEye);
                }),
                _buildSmallToolButton(context, Icons.arrow_forward, 'Right', () {
                  animationNotifier.shiftRight(isLeft: isLeftEye);
                }),
              ],
            ),
            const SizedBox(height: 16),

            // LED Grid
            _buildLEDGrid(context, ref, matrix),
          ],
        ),
      ),
    );
  }

  Widget _buildLEDGrid(BuildContext context, WidgetRef ref, List<List<LEDState>> matrix) {
    return Column(
      children: [
        // Column indicators
        Row(
          children: [
            const SizedBox(width: 32),
            ...List.generate(8, (col) {
              return _buildColumnHeader(context, ref, col);
            }),
          ],
        ),
        // Grid rows
        ...List.generate(8, (row) {
          return Row(
            children: [
              // Row indicator
              _buildRowHeader(context, ref, row),
              // LED cells
              ...List.generate(8, (col) {
                return _buildLEDCell(context, ref, row, col, matrix[row][col]);
              }),
            ],
          );
        }),
      ],
    );
  }

  Widget _buildLEDCell(BuildContext context, WidgetRef ref, int row, int col, LEDState led) {
    final animationNotifier = ref.read(currentAnimationProvider.notifier);

    return GestureDetector(
      onTap: () {
        animationNotifier.toggleLED(isLeft: isLeftEye, row: row, col: col);
        HapticFeedback.lightImpact();
      },
      child: Container(
        width: 32,
        height: 32,
        margin: const EdgeInsets.all(1),
        decoration: BoxDecoration(
          color: led.isOn
              ? (isLeftEye ? Colors.red : Colors.blue).withOpacity(led.brightness / 255)
              : Colors.grey.shade800,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
            color: Colors.grey.shade600,
            width: 1,
          ),
        ),
      ),
    );
  }

  Widget _buildRowHeader(BuildContext context, WidgetRef ref, int row) {
    final animationNotifier = ref.read(currentAnimationProvider.notifier);
    final currentFrame = animationNotifier.currentFrame;
    final matrix = isLeftEye ? currentFrame.leftEye : currentFrame.rightEye;
    final rowOn = matrix[row].every((led) => led.isOn);
    final rowOff = matrix[row].every((led) => !led.isOn);

    Color getRowColor() {
      if (rowOn) return Colors.green;
      if (rowOff) return Colors.grey;
      return Colors.orange;
    }

    return GestureDetector(
      onTap: () {
        // Toggle entire row
        final newState = rowOn || rowOff;
        animationNotifier.setRow(isLeft: isLeftEye, row: row, isOn: !newState);
      },
      child: Container(
        width: 24,
        height: 32,
        margin: const EdgeInsets.all(1),
        decoration: BoxDecoration(
          color: getRowColor().withOpacity(0.3),
          borderRadius: BorderRadius.circular(4),
        ),
        alignment: Alignment.center,
        child: Text(
          '$row',
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: getRowColor(),
          ),
        ),
      ),
    );
  }

  Widget _buildColumnHeader(BuildContext context, WidgetRef ref, int col) {
    final animationNotifier = ref.read(currentAnimationProvider.notifier);
    final currentFrame = animationNotifier.currentFrame;
    final matrix = isLeftEye ? currentFrame.leftEye : currentFrame.rightEye;
    final colOn = matrix.every((row) => row[col].isOn);
    final colOff = matrix.every((row) => !row[col].isOn);

    Color getColColor() {
      if (colOn) return Colors.green;
      if (colOff) return Colors.grey;
      return Colors.orange;
    }

    return GestureDetector(
      onTap: () {
        // Toggle entire column
        final newState = colOn || colOff;
        animationNotifier.setColumn(isLeft: isLeftEye, col: col, isOn: !newState);
      },
      child: Container(
        width: 32,
        height: 24,
        margin: const EdgeInsets.all(1),
        decoration: BoxDecoration(
          color: getColColor().withOpacity(0.3),
          borderRadius: BorderRadius.circular(4),
        ),
        alignment: Alignment.center,
        child: Text(
          '$col',
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: getColColor(),
          ),
        ),
      ),
    );
  }

  Widget _buildToolButton(
    BuildContext context,
    IconData icon,
    String tooltip,
    VoidCallback onPressed,
  ) {
    return IconButton(
      icon: Icon(icon),
      tooltip: tooltip,
      onPressed: onPressed,
      iconSize: 20,
      padding: const EdgeInsets.all(8),
    );
  }

  Widget _buildSmallToolButton(
    BuildContext context,
    IconData icon,
    String tooltip,
    VoidCallback onPressed,
  ) {
    return IconButton(
      icon: Icon(icon),
      tooltip: tooltip,
      onPressed: onPressed,
      iconSize: 16,
      constraints: const BoxConstraints(
        minWidth: 32,
        minHeight: 32,
      ),
      padding: const EdgeInsets.all(4),
    );
  }
}
