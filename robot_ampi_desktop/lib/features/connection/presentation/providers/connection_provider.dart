import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:robot_ampi_desktop/core/constants/commands.dart';
import 'package:robot_ampi_desktop/features/connection/data/datasources/serial_datasource.dart';
import 'package:robot_ampi_desktop/features/connection/domain/entities/connection_state.dart';
import 'package:robot_ampi_desktop/features/connection/domain/repositories/serial_repository.dart';

// Data source provider
final serialDataSourceProvider = Provider<SerialDataSource>((ref) {
  final source = SerialDataSourceImpl();
  ref.onDispose(() => source.dispose());
  return source;
});

// Repository provider
final serialRepositoryProvider = Provider<SerialRepository>((ref) {
  return SerialRepositoryImpl(
    dataSource: ref.watch(serialDataSourceProvider),
  );
});

// Connection state provider
final connectionStateProvider =
    StateNotifierProvider<ConnectionNotifier, RobotConnectionState>((ref) {
  final repository = ref.watch(serialRepositoryProvider);
  return ConnectionNotifier(repository: repository);
});

/// Notifier for managing serial connection state
class ConnectionNotifier extends StateNotifier<RobotConnectionState> {
  final SerialRepository _repository;

  ConnectionNotifier({required SerialRepository repository})
      : _repository = repository,
        super(const RobotConnectionState.disconnected());

  /// Get list of available serial ports
  Future<List<String>> getAvailablePorts() async {
    try {
      return await _repository.getAvailablePorts();
    } catch (e) {
      state = RobotConnectionState.withError('Failed to get ports: $e');
      return [];
    }
  }

  /// Connect to a serial port
  Future<void> connect(String port, {int baudRate = SerialCommands.baudRate}) async {
    try {
      state = const RobotConnectionState.connecting();
      await _repository.connect(port, baudRate: baudRate);
      state = RobotConnectionState.connectedWithPort(port);
    } catch (e) {
      state = RobotConnectionState.withError('Connection failed: $e');
    }
  }

  /// Disconnect from serial port
  Future<void> disconnect() async {
    try {
      await _repository.disconnect();
      state = const RobotConnectionState.disconnected();
    } catch (e) {
      state = RobotConnectionState.withError('Disconnect failed: $e');
    }
  }

  /// Send data to robot
  Future<void> sendData(Uint8List data) async {
    try {
      await _repository.sendData(data);
    } catch (e) {
      state = RobotConnectionState.withError('Send failed: $e');
    }
  }

  /// Check if connected
  bool get isConnected => _repository.isConnected;

  /// Get current port
  String? get currentPort => _repository.currentPort;

  /// Get data stream from robot
  Stream<Uint8List> get dataStream => _repository.dataStream;
}

// Data stream provider (for listening to incoming data)
final serialDataStreamProvider = StreamProvider<Uint8List>((ref) {
  final connectionNotifier = ref.watch(connectionStateProvider.notifier);
  return connectionNotifier.dataStream;
});
