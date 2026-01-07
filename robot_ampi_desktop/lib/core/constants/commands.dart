import 'dart:typed_data';

/// Serial command protocol constants for Robot-AmPI communication.
///
/// Protocol Format: <CMD><DATA>\n
/// Response Format: <RSP><DATA>\n
class SerialCommands {
  // Baud rate for serial communication
  static const int baudRate = 115200;

  // ==================== COMMAND DEFINITIONS ====================

  // Command codes (ASCII characters)
  static const int cmdMove = 0x4D; // 'M' - Move head
  static const int cmdEmotion = 0x45; // 'E' - Show emotion
  static const int cmdStatus = 0x53; // 'S' - Get status
  static const int cmdConfig = 0x43; // 'C' - Configure
  static const int cmdPing = 0x50; // 'P' - Heartbeat
  static const int cmdStop = 0x58; // 'X' - Emergency stop

  // Response codes
  static const int rspAck = 0x41; // 'A' - Acknowledge
  static const int rspStatus = 0x53; // 'S' - Status
  static const int rspPong = 0x50; // 'P' - Pong
  static const int rspError = 0x45; // 'E' - Error
  static const int rspStop = 0x58; // 'X' - Stop acknowledged

  // ==================== COMMAND BUILDERS ====================

  /// Build a move command: M<Yaw:000-180><Pitch:060-120>\n
  /// Example: M090090\n (center position)
  static Uint8List buildMoveCommand(int yaw, int pitch) {
    final buffer = StringBuffer('M');
    buffer.write(yaw.toString().padLeft(3, '0'));
    buffer.write(pitch.toString().padLeft(3, '0'));
    buffer.write('\n');
    return Uint8List.fromList(buffer.toString().codeUnits);
  }

  /// Build an emotion command: E<EmotionID:00-05>\n
  /// Example: E00\n (happy emotion)
  static Uint8List buildEmotionCommand(int emotionId) {
    final buffer = StringBuffer('E');
    buffer.write(emotionId.toString().padLeft(2, '0'));
    buffer.write('\n');
    return Uint8List.fromList(buffer.toString().codeUnits);
  }

  /// Build a status request command: S\n
  static Uint8List buildStatusCommand() {
    return Uint8List.fromList('S\n'.codeUnits);
  }

  /// Build a ping command: P\n
  static Uint8List buildPingCommand() {
    return Uint8List.fromList('P\n'.codeUnits);
  }

  /// Build a stop command: X\n
  static Uint8List buildStopCommand() {
    return Uint8List.fromList('X\n'.codeUnits);
  }

  /// Build a config command: C<ParamID><Value>\n
  /// Example: C00180\n (set max yaw to 180)
  static Uint8List buildConfigCommand(int paramId, int value) {
    final buffer = StringBuffer('C');
    buffer.write(paramId);
    buffer.write(value);
    buffer.write('\n');
    return Uint8List.fromList(buffer.toString().codeUnits);
  }

  // ==================== RESPONSE PARSERS ====================

  /// Parse move acknowledge response: A<Yaw><Pitch>\n
  static ({int yaw, int pitch})? parseMoveAck(String response) {
    if (response.isEmpty || response[0] != String.fromCharCode(rspAck)) {
      return null;
    }

    if (response.length < 7) return null;

    final yawStr = response.substring(1, 4);
    final pitchStr = response.substring(4, 7);

    try {
      final yaw = int.parse(yawStr);
      final pitch = int.parse(pitchStr);
      return (yaw: yaw, pitch: pitch);
    } catch (e) {
      return null;
    }
  }

  /// Parse emotion acknowledge response: A<EmotionID>\n
  static int? parseEmotionAck(String response) {
    if (response.isEmpty || response[0] != String.fromCharCode(rspAck)) {
      return null;
    }

    if (response.length < 3) return null;

    try {
      return int.parse(response.substring(1, 3));
    } catch (e) {
      return null;
    }
  }

  /// Parse status response: S<Yaw><Pitch><Mode><State>\n
  static ({int yaw, int pitch, int mode, int state})? parseStatusResponse(
      String response) {
    if (response.isEmpty || response[0] != String.fromCharCode(rspStatus)) {
      return null;
    }

    if (response.length < 9) return null;

    try {
      final yaw = int.parse(response.substring(1, 4));
      final pitch = int.parse(response.substring(4, 7));
      final mode = int.parse(response[7]);
      final state = int.parse(response[8]);
      return (yaw: yaw, pitch: pitch, mode: mode, state: state);
    } catch (e) {
      return null;
    }
  }

  /// Parse pong response: P<1=alive>\n
  static bool parsePongResponse(String response) {
    return response.startsWith('P1');
  }

  /// Parse error response: E<ErrorCode>\n
  static int? parseErrorResponse(String response) {
    if (response.isEmpty || response[0] != String.fromCharCode(rspError)) {
      return null;
    }

    try {
      return int.parse(response.substring(1, 3));
    } catch (e) {
      return null;
    }
  }

  // ==================== ERROR CODES ====================

  static const int errUnknownCmd = 0; // Unknown command
  static const int errInvalidData = 1; // Invalid data format
  static const int errOutOfRange = 2; // Value out of range
  static const int errChecksum = 3; // Checksum mismatch

  static String getErrorMessage(int errorCode) {
    switch (errorCode) {
      case errUnknownCmd:
        return 'Unknown command';
      case errInvalidData:
        return 'Invalid data format';
      case errOutOfRange:
        return 'Value out of range';
      case errChecksum:
        return 'Checksum mismatch';
      default:
        return 'Unknown error';
    }
  }

  // ==================== CONFIG PARAMS ====================

  static const int configYawMin = 0;
  static const int configYawMax = 1;
  static const int configPitchMin = 2;
  static const int configPitchMax = 3;
}
