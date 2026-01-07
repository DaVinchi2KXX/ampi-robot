import 'package:equatable/equatable.dart';

/// Represents a single LED state in the 8x8 matrix
class LEDState extends Equatable {
  final bool isOn;
  final int brightness; // 0-255

  const LEDState({
    required this.isOn,
    this.brightness = 255,
  });

  const LEDState.off() : isOn = false, brightness = 0;

  const LEDState.on({this.brightness = 255}) : isOn = true;

  LEDState copyWith({
    bool? isOn,
    int? brightness,
  }) {
    return LEDState(
      isOn: isOn ?? this.isOn,
      brightness: brightness ?? this.brightness,
    );
  }

  /// Convert to byte value (0-255)
  int toByte() {
    return isOn ? brightness : 0;
  }

  @override
  List<Object?> get props => [isOn, brightness];
}

/// Represents a single animation frame with eye matrices and head position
class AnimationFrame extends Equatable {
  final String id;
  final int duration; // Duration in milliseconds
  final List<List<LEDState>> leftEye; // 8x8 LED matrix for left eye
  final List<List<LEDState>> rightEye; // 8x8 LED matrix for right eye
  final int yaw; // Head yaw position (0-180)
  final int pitch; // Head pitch position (60-120)
  final int? sound; // Optional sound melody index

  const AnimationFrame({
    required this.id,
    required this.duration,
    required this.leftEye,
    required this.rightEye,
    required this.yaw,
    required this.pitch,
    this.sound,
  });

  /// Create a blank frame with all LEDs off
  factory AnimationFrame.blank({String? id}) {
    final blankEye = List.generate(
      8,
      (_) => List.generate(8, (_) => const LEDState.off()),
    );
    return AnimationFrame(
      id: id ?? generateId(),
      duration: 200,
      leftEye: blankEye,
      rightEye: blankEye,
      yaw: 90,
      pitch: 90,
    );
  }

  /// Create frame from byte arrays (for loading from file)
  factory AnimationFrame.fromBytes({
    required String id,
    required int duration,
    required List<int> leftEyeBytes,
    required List<int> rightEyeBytes,
    required int yaw,
    required int pitch,
    int? sound,
  }) {
    leftEyeBytes = leftEyeBytes.length == 8 ? leftEyeBytes : List.filled(8, 0);
    rightEyeBytes = rightEyeBytes.length == 8 ? rightEyeBytes : List.filled(8, 0);

    return AnimationFrame(
      id: id,
      duration: duration,
      leftEye: _bytesToMatrix(leftEyeBytes),
      rightEye: _bytesToMatrix(rightEyeBytes),
      yaw: yaw,
      pitch: pitch,
      sound: sound,
    );
  }

  /// Convert LED matrix to byte array (8 bytes)
  List<int> leftEyeToBytes() => _matrixToBytes(leftEye);
  List<int> rightEyeToBytes() => _matrixToBytes(rightEye);

  /// Toggle LED at position
  AnimationFrame toggleLED({required bool isLeft, required int row, required int col}) {
    final matrix = isLeft ? leftEye : rightEye;
    final led = matrix[row][col];
    final newMatrix = matrix.map((rowList) {
      return List<LEDState>.from(rowList);
    }).toList();
    newMatrix[row][col] = led.isOn ? const LEDState.off() : const LEDState.on();
    return copyWith(
      leftEye: isLeft ? newMatrix : leftEye,
      rightEye: isLeft ? rightEye : newMatrix,
    );
  }

  /// Set LED state at position
  AnimationFrame setLED({
    required bool isLeft,
    required int row,
    required int col,
    required bool isOn,
  }) {
    final matrix = isLeft ? leftEye : rightEye;
    final newMatrix = matrix.map((rowList) {
      return List<LEDState>.from(rowList);
    }).toList();
    newMatrix[row][col] = isOn ? const LEDState.on() : const LEDState.off();
    return copyWith(
      leftEye: isLeft ? newMatrix : leftEye,
      rightEye: isLeft ? rightEye : newMatrix,
    );
  }

  /// Set entire row
  AnimationFrame setRow({required bool isLeft, required int row, required bool isOn}) {
    final matrix = isLeft ? leftEye : rightEye;
    final newMatrix = matrix.map((rowList) {
      return List<LEDState>.from(rowList);
    }).toList();
    newMatrix[row] = List.generate(8, (_) => isOn ? const LEDState.on() : const LEDState.off());
    return copyWith(
      leftEye: isLeft ? newMatrix : leftEye,
      rightEye: isLeft ? rightEye : newMatrix,
    );
  }

  /// Set entire column
  AnimationFrame setColumn({required bool isLeft, required int col, required bool isOn}) {
    final matrix = isLeft ? leftEye : rightEye;
    final newMatrix = matrix.map((rowList) {
      return List<LEDState>.from(rowList);
    }).toList();
    for (int row = 0; row < 8; row++) {
      newMatrix[row][col] = isOn ? const LEDState.on() : const LEDState.off();
    }
    return copyWith(
      leftEye: isLeft ? newMatrix : leftEye,
      rightEye: isLeft ? rightEye : newMatrix,
    );
  }

  /// Clear all LEDs
  AnimationFrame clear({bool? isLeft}) {
    final blankEye = List.generate(
      8,
      (_) => List.generate(8, (_) => const LEDState.off()),
    );
    return copyWith(
      leftEye: isLeft == true || isLeft == null ? blankEye : leftEye,
      rightEye: isLeft == false ? blankEye : rightEye,
    );
  }

  /// Fill all LEDs
  AnimationFrame fill({bool? isLeft}) {
    final filledEye = List.generate(
      8,
      (_) => List.generate(8, (_) => const LEDState.on()),
    );
    return copyWith(
      leftEye: isLeft == true || isLeft == null ? filledEye : leftEye,
      rightEye: isLeft == false ? filledEye : rightEye,
    );
  }

  /// Invert all LEDs
  AnimationFrame invert({bool? isLeft}) {
    AnimationFrame invertMatrix(List<List<LEDState>> matrix) {
      return AnimationFrame(
        id: id,
        duration: duration,
        leftEye: leftEye,
        rightEye: rightEye,
        yaw: yaw,
        pitch: pitch,
        sound: sound,
      );
    }

    final newLeft = isLeft == false ? leftEye : _invertMatrix(leftEye);
    final newRight = isLeft == true ? rightEye : _invertMatrix(rightEye);

    return copyWith(
      leftEye: newLeft,
      rightEye: newRight,
    );
  }

  /// Rotate matrix 90 degrees clockwise
  AnimationFrame rotate({bool? isLeft}) {
    final newLeft = isLeft == false ? leftEye : _rotateMatrix(leftEye);
    final newRight = isLeft == true ? rightEye : _rotateMatrix(rightEye);

    return copyWith(
      leftEye: newLeft,
      rightEye: newRight,
    );
  }

  /// Shift matrix up
  AnimationFrame shiftUp({bool? isLeft}) {
    final newLeft = isLeft == false ? leftEye : _shiftMatrixUp(leftEye);
    final newRight = isLeft == true ? rightEye : _shiftMatrixUp(rightEye);

    return copyWith(
      leftEye: newLeft,
      rightEye: newRight,
    );
  }

  /// Shift matrix down
  AnimationFrame shiftDown({bool? isLeft}) {
    final newLeft = isLeft == false ? leftEye : _shiftMatrixDown(leftEye);
    final newRight = isLeft == true ? rightEye : _shiftMatrixDown(rightEye);

    return copyWith(
      leftEye: newLeft,
      rightEye: newRight,
    );
  }

  /// Shift matrix left
  AnimationFrame shiftLeft({bool? isLeft}) {
    final newLeft = isLeft == false ? leftEye : _shiftMatrixLeft(leftEye);
    final newRight = isLeft == true ? rightEye : _shiftMatrixLeft(rightEye);

    return copyWith(
      leftEye: newLeft,
      rightEye: newRight,
    );
  }

  /// Shift matrix right
  AnimationFrame shiftRight({bool? isLeft}) {
    final newLeft = isLeft == false ? leftEye : _shiftMatrixRight(leftEye);
    final newRight = isLeft == true ? rightEye : _shiftMatrixRight(rightEye);

    return copyWith(
      leftEye: newLeft,
      rightEye: newRight,
    );
  }

  AnimationFrame copyWith({
    String? id,
    int? duration,
    List<List<LEDState>>? leftEye,
    List<List<LEDState>>? rightEye,
    int? yaw,
    int? pitch,
    int? sound,
  }) {
    return AnimationFrame(
      id: id ?? this.id,
      duration: duration ?? this.duration,
      leftEye: leftEye ?? this.leftEye,
      rightEye: rightEye ?? this.rightEye,
      yaw: yaw ?? this.yaw,
      pitch: pitch ?? this.pitch,
      sound: sound ?? this.sound,
    );
  }

  /// Convert frame to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'duration': duration,
      'leftEye': leftEye.map((row) => row.map((led) => led.toByte()).toList()).toList(),
      'rightEye': rightEye.map((row) => row.map((led) => led.toByte()).toList()).toList(),
      'yaw': yaw,
      'pitch': pitch,
      'sound': sound,
    };
  }

  /// Create frame from JSON
  factory AnimationFrame.fromJson(Map<String, dynamic> json) {
    // Convert 8x8 matrix of byte values back to 8 bytes
    List<int> matrixToBytes(List<List<int>> matrix) {
      return List.generate(8, (row) {
        int byte = 0;
        for (int col = 0; col < 8; col++) {
          if (matrix[row][col] > 0) {
            byte |= (1 << (7 - col));
          }
        }
        return byte;
      });
    }

    return AnimationFrame(
      id: json['id'] as String,
      duration: json['duration'] as int,
      leftEye: _bytesToMatrix(
        matrixToBytes((json['leftEye'] as List).cast<List<int>>()),
      ),
      rightEye: _bytesToMatrix(
        matrixToBytes((json['rightEye'] as List).cast<List<int>>()),
      ),
      yaw: json['yaw'] as int,
      pitch: json['pitch'] as int,
      sound: json['sound'] as int?,
    );
  }

  // Private helper methods

  static List<List<LEDState>> _bytesToMatrix(List<int> bytes) {
    return List.generate(8, (row) {
      final byte = bytes[row];
      return List.generate(8, (col) {
        final bit = (byte >> (7 - col)) & 1;
        return LEDState(isOn: bit == 1, brightness: bit == 1 ? 255 : 0);
      });
    });
  }

  static List<int> _matrixToBytes(List<List<LEDState>> matrix) {
    return List.generate(8, (row) {
      int byte = 0;
      for (int col = 0; col < 8; col++) {
        if (matrix[row][col].isOn) {
          byte |= (1 << (7 - col));
        }
      }
      return byte;
    });
  }

  static List<List<LEDState>> _invertMatrix(List<List<LEDState>> matrix) {
    return matrix.map((row) {
      return row.map((led) => led.copyWith(isOn: !led.isOn)).toList();
    }).toList();
  }

  static List<List<LEDState>> _rotateMatrix(List<List<LEDState>> matrix) {
    return List.generate(8, (row) {
      return List.generate(8, (col) => matrix[7 - col][row]);
    });
  }

  static List<List<LEDState>> _shiftMatrixUp(List<List<LEDState>> matrix) {
    final newMatrix = matrix.skip(1).toList();
    newMatrix.add(matrix[0]);
    return newMatrix;
  }

  static List<List<LEDState>> _shiftMatrixDown(List<List<LEDState>> matrix) {
    final newMatrix = List<List<LEDState>>.from(matrix);
    newMatrix.insert(0, newMatrix.removeLast());
    return newMatrix;
  }

  static List<List<LEDState>> _shiftMatrixLeft(List<List<LEDState>> matrix) {
    return matrix.map((row) {
      final newRow = row.skip(1).toList();
      newRow.add(row[0]);
      return newRow;
    }).toList();
  }

  static List<List<LEDState>> _shiftMatrixRight(List<List<LEDState>> matrix) {
    return matrix.map((row) {
      final newRow = List<LEDState>.from(row);
      newRow.insert(0, newRow.removeLast());
      return newRow;
    }).toList();
  }

  static String generateId() {
    return 'frame_${DateTime.now().millisecondsSinceEpoch}';
  }

  @override
  List<Object?> get props => [id, duration, leftEye, rightEye, yaw, pitch, sound];
}
