import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:robot_ampi_desktop/features/connection/domain/entities/connection_state.dart';
import 'package:robot_ampi_desktop/features/connection/presentation/providers/connection_provider.dart';

class ConnectionPage extends ConsumerStatefulWidget {
  const ConnectionPage({super.key});

  @override
  ConsumerState<ConnectionPage> createState() => _ConnectionPageState();
}

class _ConnectionPageState extends ConsumerState<ConnectionPage> {
  String? _selectedPort;
  bool _isLoadingPorts = false;
  List<String> _availablePorts = [];

  @override
  void initState() {
    super.initState();
    _refreshPorts();
  }

  Future<void> _refreshPorts() async {
    setState(() => _isLoadingPorts = true);
    final ports = await ref.read(connectionStateProvider.notifier).getAvailablePorts();
    setState(() {
      _availablePorts = ports;
      _isLoadingPorts = false;
      if (_availablePorts.isNotEmpty && _selectedPort == null) {
        _selectedPort = _availablePorts.first;
      }
    });
  }

  Future<void> _connect() async {
    if (_selectedPort == null) return;
    await ref
        .read(connectionStateProvider.notifier)
        .connect(_selectedPort!);
  }

  Future<void> _disconnect() async {
    await ref.read(connectionStateProvider.notifier).disconnect();
  }

  @override
  Widget build(BuildContext context) {
    final connectionState = ref.watch(connectionStateProvider);
    final theme = Theme.of(context);

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
                      Symbols.cable,
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
                          'Serial Connection',
                          style: theme.textTheme.headlineMedium,
                        ),
                        Text(
                          'Connect to Robot-AmPI via serial port',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Connection Status Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Row(
                    children: [
                      _buildStatusIndicator(connectionState),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Status: ${_getStatusText(connectionState)}',
                              style: theme.textTheme.titleLarge,
                            ),
                            if (connectionState.portName != null)
                              Text(
                                'Port: ${connectionState.portName}',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color:
                                      theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            if (connectionState.errorMessage != null)
                              Text(
                                connectionState.errorMessage!,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.error,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Port Selection
              if (!connectionState.isConnected) ...[
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _selectedPort,
                        decoration: const InputDecoration(
                          labelText: 'Serial Port',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Symbols.usb),
                        ),
                        items: _availablePorts.map((port) {
                          return DropdownMenuItem(
                            value: port,
                            child: Text(port),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() => _selectedPort = value);
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    IconButton.filled(
                      onPressed: _isLoadingPorts ? null : _refreshPorts,
                      icon: _isLoadingPorts
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Symbols.refresh),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Connect Button
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: _selectedPort == null ||
                            connectionState.isConnecting
                        ? null
                        : _connect,
                    icon: connectionState.isConnecting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Symbols.link),
                    label: const Text('Connect'),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
              ] else ...[
                // Disconnect Button
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.tonalIcon(
                    onPressed: _disconnect,
                    icon: const Icon(Symbols.link_off),
                    label: const Text('Disconnect'),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
              ],
              const Spacer(),

              // Info Card
              Card(
                color: theme.colorScheme.surfaceContainerHighest,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Icon(
                        Symbols.info,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Make sure your Robot-AmPI is powered on and connected via USB',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
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

  Widget _buildStatusIndicator(RobotConnectionState state) {
    Color color;
    IconData icon;

    if (state.isConnecting) {
      color = Colors.orange;
      icon = Symbols.sync;
    } else if (state.isConnected) {
      color = Colors.green;
      icon = Symbols.check_circle;
    } else {
      color = Colors.red;
      icon = Symbols.cancel;
    }

    return Container(
      width: 16,
      height: 16,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.4),
            blurRadius: 8,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Icon(icon, size: 12, color: Colors.white),
    );
  }

  String _getStatusText(RobotConnectionState state) {
    if (state.isConnecting) return 'Connecting...';
    if (state.isConnected) return 'Connected';
    if (state.errorMessage != null) return 'Error';
    return 'Disconnected';
  }
}
