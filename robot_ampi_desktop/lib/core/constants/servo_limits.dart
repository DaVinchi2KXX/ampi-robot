/// Servo hardware limits for Robot-AmPI
class ServoLimits {
  // Yaw servo (left-right rotation)
  static const int yawMin = 0;
  static const int yawMax = 180;
  static const int yawMid = 90;

  // Pitch servo (up-down tilt)
  static const int pitchMin = 60;
  static const int pitchMax = 120;
  static const int pitchMid = 90;

  // Movement step size for button presses
  static const int movementStep = 2;

  /// Constrain yaw value to valid range
  static int constrainYaw(int value) {
    return value.clamp(yawMin, yawMax);
  }

  /// Constrain pitch value to valid range
  static int constrainPitch(int value) {
    return value.clamp(pitchMin, pitchMax);
  }

  /// Check if yaw value is valid
  static bool isValidYaw(int value) {
    return value >= yawMin && value <= yawMax;
  }

  /// Check if pitch value is valid
  static bool isValidPitch(int value) {
    return value >= pitchMin && value <= pitchMax;
  }
}
