import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:robot_ampi_desktop/core/constants/commands.dart';
import 'package:robot_ampi_desktop/core/constants/emotions.dart';
import 'package:robot_ampi_desktop/core/constants/servo_limits.dart';
import 'package:robot_ampi_desktop/features/connection/presentation/providers/connection_provider.dart';

class ControlPanelPage extends ConsumerStatefulWidget {
  const ControlPanelPage({super.key});

  @override
  ConsumerState<ControlPanelPage> createState() => _ControlPanelPageState();
}

class _ControlPanelPageState extends ConsumerState<ControlPanelPage> {
  int _currentYaw = ServoLimits.yawMid;
  int _currentPitch = ServoLimits.pitchMid;

  Future<void> _moveHead(int yawDelta, int pitchDelta) async {
    final notifier = ref.read(connectionStateProvider.notifier);
    if (!notifier.isConnected) return;

    _currentYaw = ServoLimits.constrainYaw(_currentYaw + yawDelta);
    _currentPitch = ServoLimits.constrainPitch(_currentPitch + pitchDelta);

    await notifier.sendData(
      SerialCommands.buildMoveCommand(_currentYaw, _currentPitch),
    );
    setState(() {});
  }

  Future<void> _showEmotion(int emotionId) async {
    final notifier = ref.read(connectionStateProvider.notifier);
    if (!notifier.isConnected) return;

    await notifier.sendData(
      SerialCommands.buildEmotionCommand(emotionId),
    );
  }

  Future<void> _centerHead() async {
    final notifier = ref.read(connectionStateProvider.notifier);
    if (!notifier.isConnected) return;

    _currentYaw = ServoLimits.yawMid;
    _currentPitch = ServoLimits.pitchMid;

    await notifier.sendData(
      SerialCommands.buildMoveCommand(_currentYaw, _currentPitch),
    );
    setState(() {});
  }

  Future<void> _emergencyStop() async {
    final notifier = ref.read(connectionStateProvider.notifier);
    if (!notifier.isConnected) return;

    await notifier.sendData(SerialCommands.buildStopCommand());
  }

  @override
  Widget build(BuildContext context) {
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
                      Symbols.gamepad,
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
                          'Control Panel',
                          style: theme.textTheme.headlineMedium,
                        ),
                        Text(
                          isConnected ? 'Connected' : 'Not connected',
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

              // Status Display
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatusItem(
                        context,
                        'Yaw',
                        '$_currentYaw°',
                        Icons.swap_horiz,
                      ),
                      _buildStatusItem(
                        context,
                        'Pitch',
                        '$_currentPitch°',
                        Icons.swap_vert,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Direction Pad
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      Text(
                        'Head Movement',
                        style: theme.textTheme.titleMedium,
                      ),
                      const SizedBox(height: 16),
                      _buildDirectionPad(),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Emotions Grid
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Emotions',
                        style: theme.textTheme.titleMedium,
                      ),
                      const SizedBox(height: 16),
                      _buildEmotionsGrid(),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Quick Actions
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Quick Actions',
                        style: theme.textTheme.titleMedium,
                      ),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: [
                          FilledButton.icon(
                            onPressed: isConnected ? _centerHead : null,
                            icon: const Icon(Symbols.center_focus_strong),
                            label: const Text('Center'),
                          ),
                          FilledButton.tonalIcon(
                            onPressed: isConnected ? _emergencyStop : null,
                            icon: const Icon(Symbols.stop_circle),
                            label: const Text('Stop'),
                            style: FilledButton.styleFrom(
                              backgroundColor: theme.colorScheme.errorContainer,
                              foregroundColor:
                                  theme.colorScheme.onErrorContainer,
                            ),
                          ),
                        ],
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

  Widget _buildStatusItem(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Icon(icon, color: theme.colorScheme.primary),
        const SizedBox(height: 8),
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        Text(
          value,
          style: theme.textTheme.headlineSmall,
        ),
      ],
    );
  }

  Widget _buildDirectionPad() {
    return SizedBox(
      width: 200,
      height: 200,
      child: Stack(
        children: [
          // Up
          Positioned(
            top: 0,
            left: 70,
            child: _buildDirectionButton(
              Symbols.arrow_upward,
              () => _moveHead(0, ServoLimits.movementStep),
            ),
          ),
          // Down
          Positioned(
            bottom: 0,
            left: 70,
            child: _buildDirectionButton(
              Symbols.arrow_downward,
              () => _moveHead(0, -ServoLimits.movementStep),
            ),
          ),
          // Left
          Positioned(
            left: 0,
            top: 70,
            child: _buildDirectionButton(
              Symbols.arrow_back,
              () => _moveHead(-ServoLimits.movementStep, 0),
            ),
          ),
          // Right
          Positioned(
            right: 0,
            top: 70,
            child: _buildDirectionButton(
              Symbols.arrow_forward,
              () => _moveHead(ServoLimits.movementStep, 0),
            ),
          ),
          // Center indicator
          Center(
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Theme.of(context).colorScheme.primaryContainer,
              ),
              child: Icon(
                Symbols.face,
                color: Theme.of(context).colorScheme.onPrimaryContainer,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDirectionButton(IconData icon, VoidCallback onPressed) {
    final connectionState = ref.watch(connectionStateProvider);
    final isConnected = connectionState.isConnected;

    return SizedBox(
      width: 60,
      height: 60,
      child: IconButton.filled(
        onPressed: isConnected ? onPressed : null,
        icon: Icon(icon),
        style: IconButton.styleFrom(
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          foregroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
        ),
      ),
    );
  }

  Widget _buildEmotionsGrid() {
    final connectionState = ref.watch(connectionStateProvider);
    final isConnected = connectionState.isConnected;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.5,
      ),
      itemCount: Emotions.all.length,
      itemBuilder: (context, index) {
        final emotion = Emotions.all[index];
        return FilledButton.tonal(
          onPressed: isConnected ? () => _showEmotion(emotion.id) : null,
          style: FilledButton.styleFrom(
            padding: const EdgeInsets.all(12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                emotion.icon,
                style: const TextStyle(fontSize: 32),
              ),
              const SizedBox(height: 4),
              Text(
                emotion.name,
                style: Theme.of(context).textTheme.labelSmall,
              ),
            ],
          ),
        );
      },
    );
  }
}
