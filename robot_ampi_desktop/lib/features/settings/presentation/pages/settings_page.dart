import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:robot_ampi_desktop/core/constants/servo_limits.dart';
import 'package:robot_ampi_desktop/features/connection/presentation/providers/connection_provider.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

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
                      Symbols.settings,
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
                          'Settings',
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

              // Connection Settings
              _buildSection(
                context,
                'Connection',
                Icons.cable,
                [
                  ListTile(
                    leading: const Icon(Symbols.speed),
                    title: const Text('Baud Rate'),
                    subtitle: const Text('115200'),
                    trailing: const Icon(Symbols.chevron_right),
                    onTap: null,
                  ),
                  ListTile(
                    leading: const Icon(Symbols.autorenew),
                    title: const Text('Auto-reconnect'),
                    subtitle: const Text('Automatically reconnect on disconnect'),
                    trailing: Switch(
                      value: false,
                      onChanged: null,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Servo Limits
              _buildSection(
                context,
                'Servo Limits',
                Icons.tune,
                [
                  ListTile(
                    leading: const Icon(Symbols.swap_horiz),
                    title: const Text('Yaw Range'),
                    subtitle: Text(
                        '${ServoLimits.yawMin}° - ${ServoLimits.yawMax}° (Mid: ${ServoLimits.yawMid}°)'),
                  ),
                  ListTile(
                    leading: const Icon(Symbols.swap_vert),
                    title: const Text('Pitch Range'),
                    subtitle: Text(
                        '${ServoLimits.pitchMin}° - ${ServoLimits.pitchMax}° (Mid: ${ServoLimits.pitchMid}°)'),
                  ),
                  ListTile(
                    leading: const Icon(Symbols.settings_motion_mode),
                    title: const Text('Movement Step'),
                    subtitle: Text('${ServoLimits.movementStep}° per button press'),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Robot Info
              _buildSection(
                context,
                'Robot Information',
                Icons.info,
                [
                  ListTile(
                    leading: const Icon(Symbols.memory),
                    title: const Text('Microcontroller'),
                    subtitle: const Text('Arduino Nano (ATmega328P)'),
                  ),
                  ListTile(
                    leading: const Icon(Symbols.sensors),
                    title: const Text('Servos'),
                    subtitle: const Text('2x SG90 (Yaw & Pitch)'),
                  ),
                  ListTile(
                    leading: const Icon(Symbols.visibility),
                    title: const Text('Eyes'),
                    subtitle: const Text('2x 8x8 LED Matrix (I²C)'),
                  ),
                  ListTile(
                    leading: const Icon(Symbols.volume_up),
                    title: const Text('Audio'),
                    subtitle: const Text('Piezo Buzzer'),
                  ),
                  ListTile(
                    leading: const Icon(Icons.settings_remote),
                    title: const Text('IR Control'),
                    subtitle: const Text('NEC Protocol (backward compatible)'),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Serial Protocol Info
              _buildSection(
                context,
                'Serial Protocol',
                Icons.code,
                [
                  ListTile(
                    leading: const Icon(Symbols.terminal),
                    title: const Text('Protocol Format'),
                    subtitle: const Text('<CMD><DATA>\\n (ASCII-based)'),
                  ),
                  ListTile(
                    leading: const Icon(Symbols.arrow_forward),
                    title: const Text('Move Command'),
                    subtitle: const Text('M<Yaw:000-180><Pitch:060-120>\\n'),
                  ),
                  ListTile(
                    leading: const Icon(Symbols.sentiment_satisfied),
                    title: const Text('Emotion Command'),
                    subtitle: const Text('E<EmotionID:00-05>\\n'),
                  ),
                  ListTile(
                    leading: const Icon(Symbols.info),
                    title: const Text('Status Request'),
                    subtitle: const Text('S\\n'),
                  ),
                  ListTile(
                    leading: const Icon(Symbols.stop),
                    title: const Text('Emergency Stop'),
                    subtitle: const Text('X\\n'),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // About
              _buildSection(
                context,
                'About',
                Icons.info_outline,
                [
                  ListTile(
                    leading: const Icon(Symbols.app_settings_alt),
                    title: const Text('Robot-AmPI Desktop Controller'),
                    subtitle: const Text('Version 1.0.0'),
                  ),
                  ListTile(
                    leading: const Icon(Symbols.favorite),
                    title: const Text('Made with Flutter'),
                    subtitle: const Text('Cross-platform desktop application'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection(
    BuildContext context,
    String title,
    IconData icon,
    List<Widget> children,
  ) {
    final theme = Theme.of(context);

    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            leading: Icon(icon),
            title: Text(
              title,
              style: theme.textTheme.titleMedium,
            ),
          ),
          ...children,
        ],
      ),
    );
  }
}
