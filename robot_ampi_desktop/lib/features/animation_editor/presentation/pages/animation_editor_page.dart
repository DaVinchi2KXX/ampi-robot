import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:robot_ampi_desktop/features/connection/presentation/providers/connection_provider.dart';
import 'package:robot_ampi_desktop/features/animation_editor/presentation/widgets/animation_player.dart';
import 'package:robot_ampi_desktop/features/animation_editor/presentation/widgets/animation_save_load.dart';
import 'package:robot_ampi_desktop/features/animation_editor/presentation/widgets/animation_timeline.dart';
import 'package:robot_ampi_desktop/features/animation_editor/presentation/widgets/frame_editor.dart';
import 'package:robot_ampi_desktop/features/animation_editor/presentation/widgets/led_matrix_editor.dart';

class AnimationEditorPage extends ConsumerWidget {
  const AnimationEditorPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final connectionState = ref.watch(connectionStateProvider);
    final theme = Theme.of(context);
    final isConnected = connectionState.isConnected;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.movie,
                      color: theme.colorScheme.onPrimaryContainer,
                      size: 32,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Animation Editor',
                          style: theme.textTheme.headlineMedium,
                        ),
                        Text(
                          isConnected ? 'Connected to Robot-AmPI' : 'Not connected',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: isConnected
                                ? theme.colorScheme.primary
                                : theme.colorScheme.error,
                          ),
                        ),
                      ],
                    ),
                  ),
                  ],
              ),
              const SizedBox(height: 24),

              // LED Matrix Editors
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Expanded(child: LEDMatrixEditor(isLeftEye: true, label: 'Left Eye')),
                  SizedBox(width: 16),
                  Expanded(child: LEDMatrixEditor(isLeftEye: false, label: 'Right Eye')),
                ],
              ),
              const SizedBox(height: 16),

              // Frame Settings
              const FrameEditor(),
              const SizedBox(height: 16),

              // Timeline
              const AnimationTimeline(),
              const SizedBox(height: 16),

              // Playback Controls
              const AnimationPlayer(),
              const SizedBox(height: 16),

              // Save & Load
              const AnimationSaveLoadWidget(),

              const SizedBox(height: 16),

              // Info Card
              Card(
                color: theme.colorScheme.surfaceContainerHighest,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Icon(
                        Icons.lightbulb,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Tips',
                              style: theme.textTheme.labelMedium,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '• Click LEDs or row/column numbers to toggle • Drag frames to reorder • Export to C code for Arduino',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
