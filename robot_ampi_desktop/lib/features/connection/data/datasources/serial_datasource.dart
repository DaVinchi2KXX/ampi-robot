import 'dart:async';
import 'dart:typed_data';
import 'package:flutter_libserialport/flutter_libserialport.dart';

/// Serial data source for communicating with Robot-AmPI via serial port.
abstract class SerialDataSource {
  Future<List<String>> getAvailablePorts();
  Future<void> open(String port, {int baudRate});
  Future<void> close();
  Future<void> write(Uint8List data);
  Stream<Uint8List> get onDataReceived;
  bool get isOpen;
}

class SerialDataSourceImpl implements SerialDataSource {
  SerialPort? _port;
  final StreamController<Uint8List> _dataController =
      StreamController.broadcast();
  Timer? _readTimer;

  @override
  bool get isOpen => _port != null && _port!.isOpen;

  @override
  Future<List<String>> getAvailablePorts() async {
    try {
      return SerialPort.availablePorts;
    } catch (e) {
      return [];
    }
  }

  @override
  Future<void> open(String port, {int baudRate = 115200}) async {
    try {
      _port = SerialPort(port);

      final config = SerialPortConfig();
      config.baudRate = baudRate;
      config.bits = 8;
      config.stopBits = 1;
      config.parity = SerialPortParity.none;
      config.setFlowControl(SerialPortFlowControl.none);

      _port!.open(mode: SerialPortMode.readWrite);
      _port!.config = config;

      // Start reading data in a loop
      _startReading();
    } catch (e) {
      _dataController.addError(e);
      rethrow;
    }
  }

  void _startReading() {
    // Use SerialPortReader to create a stream
    final reader = SerialPortReader(_port!);
    reader.stream.listen(
      (data) {
        _dataController.add(data);
      },
      onError: (error) {
        _dataController.addError(error);
      },
    );
  }

  @override
  Future<void> close() async {
    _readTimer?.cancel();
    _readTimer = null;
    _port?.close();
    _port = null;
  }

  @override
  Future<void> write(Uint8List data) async {
    if (_port == null || !_port!.isOpen) {
      throw Exception('Serial port is not open');
    }

    try {
      _port!.write(data);
    } catch (e) {
      _dataController.addError(e);
      rethrow;
    }
  }

  @override
  Stream<Uint8List> get onDataReceived => _dataController.stream;

  void dispose() {
    _readTimer?.cancel();
    close();
    _dataController.close();
  }
}
