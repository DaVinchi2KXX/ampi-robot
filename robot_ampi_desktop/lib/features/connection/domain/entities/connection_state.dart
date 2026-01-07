import 'package:equatable/equatable.dart';

/// Connection state entity for Robot-AmPI serial connection
class RobotConnectionState extends Equatable {
  final bool isConnected;
  final String? portName;
  final String? errorMessage;
  final bool isConnecting;

  const RobotConnectionState({
    required this.isConnected,
    this.portName,
    this.errorMessage,
    this.isConnecting = false,
  });

  const RobotConnectionState.disconnected()
      : isConnected = false,
        portName = null,
        errorMessage = null,
        isConnecting = false;

  const RobotConnectionState.connecting()
      : isConnected = false,
        portName = null,
        errorMessage = null,
        isConnecting = true;

  RobotConnectionState.connectedWithPort(String port)
      : isConnected = true,
        portName = port,
        errorMessage = null,
        isConnecting = false;

  RobotConnectionState.withError(String error)
      : isConnected = false,
        portName = null,
        errorMessage = error,
        isConnecting = false;

  @override
  List<Object?> get props => [isConnected, portName, errorMessage, isConnecting];
}
