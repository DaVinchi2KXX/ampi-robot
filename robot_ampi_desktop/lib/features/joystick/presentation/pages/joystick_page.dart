import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:robot_ampi_desktop/core/constants/commands.dart';
import 'package:robot_ampi_desktop/core/constants/servo_limits.dart';
import 'package:robot_ampi_desktop/features/connection/presentation/providers/connection_provider.dart';

class JoystickPage extends ConsumerStatefulWidget {
  const JoystickPage({super.key});

  @override
  ConsumerState<JoystickPage> createState() => _JoystickPageState();
}

class _JoystickPageState extends ConsumerState<JoystickPage> {
  int _currentYaw = ServoLimits.yawMid;
  int _currentPitch = ServoLimits.pitchMid;
  bool _isDragging = false;
  final Duration _updateInterval = const Duration(milliseconds: 50);
  DateTime? _lastUpdate;

  void _onJoystickMoved(Offset position) {
    if (!_isDragging) return;

    final now = DateTime.now();
    if (_lastUpdate != null &&
        now.difference(_lastUpdate!) < _updateInterval) {
      return;
    }
    _lastUpdate = now;

    final notifier = ref.read(connectionStateProvider.notifier);
    if (!notifier.isConnected) return;

    // Convert joystick position (-1 to 1) to servo angles
    final newYaw = ServoLimits.yawMid +
        (position.dx * (ServoLimits.yawMax - ServoLimits.yawMin) / 2).round();
    final newPitch = ServoLimits.pitchMid -
        (position.dy * (ServoLimits.pitchMax - ServoLimits.pitchMin) / 2).round();

    _currentYaw = ServoLimits.constrainYaw(newYaw);
    _currentPitch = ServoLimits.constrainPitch(newPitch);

    notifier.sendData(
      SerialCommands.buildMoveCommand(_currentYaw, _currentPitch),
    );

    setState(() {});
  }

  void _onJoystickReleased() {
    setState(() => _isDragging = false);
  }

  @override
  Widget build(BuildContext context) {
    final connectionState = ref.watch(connectionStateProvider);
    final theme = Theme.of(context);
    final isConnected = connectionState.isConnected;

    return Scaffold(
      body: SafeArea(
        child: Padding(
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
                      Symbols.joystick,
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
                          'Virtual Joystick',
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
              const SizedBox(height: 32),

              // Joystick
              Expanded(
                child: Center(
                  child: VirtualJoystick(
                    onMoved: _onJoystickMoved,
                    onReleased: _onJoystickReleased,
                    onDragStarted: () => setState(() => _isDragging = true),
                    isEnabled: isConnected,
                  ),
                ),
              ),

              // Quick Actions
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    alignment: WrapAlignment.center,
                    children: [
                      FilledButton.icon(
                        onPressed: isConnected
                            ? () {
                                _currentYaw = ServoLimits.yawMid;
                                _currentPitch = ServoLimits.pitchMid;
                                ref
                                    .read(connectionStateProvider.notifier)
                                    .sendData(SerialCommands.buildMoveCommand(
                                        _currentYaw, _currentPitch));
                                setState(() {});
                              }
                            : null,
                        icon: const Icon(Symbols.center_focus_strong),
                        label: const Text('Center'),
                      ),
                      FilledButton.tonalIcon(
                        onPressed: isConnected
                            ? () {
                                ref
                                    .read(connectionStateProvider.notifier)
                                    .sendData(SerialCommands.buildStopCommand());
                              }
                            : null,
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
}

class VirtualJoystick extends StatefulWidget {
  final ValueChanged<Offset> onMoved;
  final VoidCallback onReleased;
  final VoidCallback onDragStarted;
  final bool isEnabled;

  const VirtualJoystick({
    super.key,
    required this.onMoved,
    required this.onReleased,
    required this.onDragStarted,
    this.isEnabled = true,
  });

  @override
  State<VirtualJoystick> createState() => _VirtualJoystickState();
}

class _VirtualJoystickState extends State<VirtualJoystick> {
  Offset _knobPosition = Offset.zero;
  double _radius = 120;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onPanStart: widget.isEnabled
          ? (details) {
              widget.onDragStarted();
              _updatePosition(details.localPosition);
            }
          : null,
      onPanUpdate: widget.isEnabled
          ? (details) => _updatePosition(details.localPosition)
          : null,
      onPanEnd: widget.isEnabled
          ? (_) {
              setState(() => _knobPosition = Offset.zero);
              widget.onMoved(Offset.zero);
              widget.onReleased();
            }
          : null,
      child: Container(
        width: _radius * 2,
        height: _radius * 2,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: widget.isEnabled
              ? theme.colorScheme.surfaceContainerHighest
              : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
          boxShadow: [
            BoxShadow(
              color: theme.colorScheme.shadow.withValues(alpha: 0.2),
              blurRadius: 20,
              spreadRadius: 5,
            ),
          ],
        ),
        child: Stack(
          children: [
            // Background grid
            CustomPaint(
              size: Size(_radius * 2, _radius * 2),
              painter: JoystickBackgroundPainter(
                color: theme.colorScheme.outlineVariant,
              ),
            ),
            // Position indicator
            AnimatedPositioned(
              duration: const Duration(milliseconds: 50),
              curve: Curves.easeOut,
              left: _radius + _knobPosition.dx - 35,
              top: _radius + _knobPosition.dy - 35,
              child: Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: widget.isEnabled
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurfaceVariant,
                  boxShadow: [
                    BoxShadow(
                      color: (widget.isEnabled
                              ? theme.colorScheme.primary
                              : theme.colorScheme.onSurfaceVariant)
                          .withValues(alpha: 0.4),
                      blurRadius: 12,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Icon(
                  Symbols.radio_button_checked,
                  color: widget.isEnabled
                      ? theme.colorScheme.onPrimary
                      : theme.colorScheme.surface,
                  size: 32,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _updatePosition(Offset localPosition) {
    final center = Offset(_radius, _radius);
    final offset = localPosition - center;

    // Constrain to circle
    final distance = offset.distance;
    final constrainedOffset = distance > _radius - 35
        ? offset / distance * (_radius - 35)
        : offset;

    // Calculate normalized position (-1 to 1)
    final normalizedPosition = constrainedOffset / (_radius - 35);

    setState(() => _knobPosition = constrainedOffset);
    widget.onMoved(normalizedPosition);
  }
}

class JoystickBackgroundPainter extends CustomPainter {
  final Color color;

  JoystickBackgroundPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    // Draw circle outline
    canvas.drawCircle(center, size.width / 2 - 2, paint);

    // Draw crosshair
    canvas.drawLine(
      Offset(center.dx - 20, center.dy),
      Offset(center.dx + 20, center.dy),
      paint,
    );
    canvas.drawLine(
      Offset(center.dx, center.dy - 20),
      Offset(center.dx, center.dy + 20),
      paint,
    );

    // Draw concentric circles
    for (double r in [0.33, 0.66]) {
      canvas.drawCircle(center, size.width / 2 * r, paint..strokeWidth = 0.5);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
