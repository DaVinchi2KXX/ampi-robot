import 'dart:typed_data';
import 'package:robot_ampi_desktop/features/connection/data/datasources/serial_datasource.dart';

/// Serial repository interface for communicating with Robot-AmPI
abstract class SerialRepository {
  /// Get list of available serial ports
  Future<List<String>> getAvailablePorts();

  /// Connect to a serial port
  Future<void> connect(String port, {int baudRate});

  /// Disconnect from serial port
  Future<void> disconnect();

  /// Send raw data to robot
  Future<void> sendData(Uint8List data);

  /// Stream of incoming data from robot
  Stream<Uint8List> get dataStream;

  /// Check if currently connected
  bool get isConnected;

  /// Get current port name
  String? get currentPort;
}

class SerialRepositoryImpl implements SerialRepository {
  final SerialDataSource dataSource;

  SerialRepositoryImpl({required this.dataSource});

  @override
  Future<List<String>> getAvailablePorts() async {
    return dataSource.getAvailablePorts();
  }

  @override
  Future<void> connect(String port, {int baudRate = 115200}) async {
    await dataSource.open(port, baudRate: baudRate);
  }

  @override
  Future<void> disconnect() async {
    await dataSource.close();
  }

  @override
  Future<void> sendData(Uint8List data) async {
    await dataSource.write(data);
  }

  @override
  Stream<Uint8List> get dataStream => dataSource.onDataReceived;

  @override
  bool get isConnected => dataSource.isOpen;

  @override
  String? get currentPort => dataSource.isOpen ? 'Connected' : null;
}
