// ==================== SERIAL COMMAND PROTOCOL ====================
// Desktop App to Robot-AmPI Serial Communication
// Protocol: ASCII-based commands with newline termination
// Format: <CMD><DATA>\n

#ifndef SERIAL_COMMANDS_H
#define SERIAL_COMMANDS_H

#include <Arduino.h>

// Serial baud rate
constexpr uint32_t SERIAL_BAUD = 115200;

// Command buffer size
constexpr uint8_t SERIAL_BUFFER_SIZE = 32;

// Command timeout in milliseconds
constexpr uint16_t SERIAL_TIMEOUT = 100;

// ==================== COMMAND DEFINITIONS ====================

// Serial command codes (ASCII characters)
enum SerialCommand : char {
  CMD_MOVE = 'M',      // Move head: M<Yaw:000-180><Pitch:060-120>\n
  CMD_EMOTION = 'E',   // Show emotion: E<EmotionID:00-05>\n
  CMD_STATUS = 'S',    // Get status: S\n
  CMD_CONFIG = 'C',    // Configure: C<ParamID><Value>\n
  CMD_PING = 'P',      // Heartbeat: P\n
  CMD_STOP = 'X'       // Emergency stop: X\n
};

// Response codes
enum SerialResponse : char {
  RSP_ACK = 'A',       // Acknowledge: A<DATA>\n
  RSP_STATUS = 'S',    // Status: S<Yaw><Pitch><Mode><State>\n
  RSP_PONG = 'P',      // Pong: P<1=alive>\n
  RSP_ERROR = 'E',     // Error: E<ErrorCode><Message>\n
  RSP_STOP = 'X'       // Stop acknowledged: X\n
};

// Error codes
enum SerialErrorCode : uint8_t {
  ERR_UNKNOWN_CMD = 0,   // Unknown command
  ERR_INVALID_DATA = 1,  // Invalid data format
  ERR_OUT_OF_RANGE = 2,  // Value out of range
  ERR_CHECKSUM = 3       // Checksum mismatch (reserved for future)
};

// Configuration parameter IDs
enum SerialConfigParam : uint8_t {
  CONFIG_YAW_MIN = 0,    // Yaw minimum angle
  CONFIG_YAW_MAX = 1,    // Yaw maximum angle
  CONFIG_PITCH_MIN = 2,  // Pitch minimum angle
  CONFIG_PITCH_MAX = 3   // Pitch maximum angle
};

// ==================== COMMAND PARSING ====================

// Parse move command: M<Yaw:000-180><Pitch:060-120>\n
struct MoveCommandData {
  uint8_t yaw;
  uint8_t pitch;
  bool valid;
};

MoveCommandData parseMoveCommand(const char* data) {
  MoveCommandData result = {0, 0, false};

  // Extract yaw (3 digits)
  char yawStr[4] = {0};
  yawStr[0] = data[0];
  yawStr[1] = data[1];
  yawStr[2] = data[2];

  // Extract pitch (3 digits)
  char pitchStr[4] = {0};
  pitchStr[0] = data[3];
  pitchStr[1] = data[4];
  pitchStr[2] = data[5];

  // Convert to integers
  int yaw = atoi(yawStr);
  int pitch = atoi(pitchStr);

  // Validate ranges
  if (yaw >= 0 && yaw <= 180 && pitch >= 60 && pitch <= 120) {
    result.yaw = (uint8_t)yaw;
    result.pitch = (uint8_t)pitch;
    result.valid = true;
  }

  return result;
}

// Parse emotion command: E<EmotionID:00-05>\n
struct EmotionCommandData {
  uint8_t emotionId;
  bool valid;
};

EmotionCommandData parseEmotionCommand(const char* data) {
  EmotionCommandData result = {0, false};

  // Extract emotion ID (2 digits)
  char idStr[3] = {0};
  idStr[0] = data[0];
  idStr[1] = data[1];

  int id = atoi(idStr);

  // Validate range (0-5 for 6 emotions)
  if (id >= 0 && id <= 5) {
    result.emotionId = (uint8_t)id;
    result.valid = true;
  }

  return result;
}

// Parse config command: C<ParamID><Value>\n
struct ConfigCommandData {
  uint8_t paramId;
  uint16_t value;
  bool valid;
};

ConfigCommandData parseConfigCommand(const char* data) {
  ConfigCommandData result = {0, 0, false};

  // Extract param ID (1 digit)
  result.paramId = data[0] - '0';

  // Extract value (up to 3 digits)
  char valueStr[4] = {0};
  uint8_t valueLen = strlen(data + 1);
  if (valueLen > 3) valueLen = 3;
  strncpy(valueStr, data + 1, valueLen);

  result.value = (uint16_t)atoi(valueStr);
  result.valid = true;

  return result;
}

// ==================== RESPONSE BUILDING ====================

// Build acknowledge response for move command
void sendMoveAck(uint8_t yaw, uint8_t pitch) {
  Serial.print(RSP_ACK);
  Serial.print(yaw / 100);
  Serial.print((yaw / 10) % 10);
  Serial.print(yaw % 10);
  Serial.print(pitch / 100);
  Serial.print((pitch / 10) % 10);
  Serial.println(pitch % 10);
}

// Build acknowledge response for emotion command
void sendEmotionAck(uint8_t emotionId) {
  Serial.print(RSP_ACK);
  Serial.print(emotionId / 10);
  Serial.println(emotionId % 10);
}

// Build status response: S<Yaw><Pitch><Mode><State>\n
void sendStatusResponse() {
  // External declarations for robot state variables
  extern uint8_t angleYaw;
  extern uint8_t anglePitch;
  extern RobotMode robotMode;
  extern RobotState robotState;

  Serial.print(RSP_STATUS);
  Serial.print(angleYaw / 100);
  Serial.print((angleYaw / 10) % 10);
  Serial.print(angleYaw % 10);
  Serial.print(anglePitch / 100);
  Serial.print((anglePitch / 10) % 10);
  Serial.print(anglePitch % 10);
  Serial.print(robotMode);
  Serial.println(robotState);
}

// Build pong response
void sendPongResponse() {
  Serial.println("P1");
}

// Build error response
void sendErrorResponse(uint8_t errorCode) {
  Serial.print(RSP_ERROR);
  Serial.print(errorCode / 10);
  Serial.println(errorCode % 10);
}

// Build stop acknowledge
void sendStopAck() {
  Serial.println(RSP_STOP);
}

#endif // SERIAL_COMMANDS_H
