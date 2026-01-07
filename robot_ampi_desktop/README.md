# Robot-AmPI Desktop Controller

Cross-platform Flutter desktop application for controlling the Robot-AmPI robot head via serial port.

## Features

- **Connection Management**: Auto-discovery and connection to serial ports
- **Control Panel**: Directional pad for head movement and emotion buttons
- **Virtual Joystick**: Smooth real-time servo control with visual feedback
- **Animation Editor**: (Coming Soon) Create custom animation sequences
- **Settings**: View and configure robot parameters

## Requirements

- Flutter SDK 3.24 or higher
- Dart 3.0 or higher
- Linux, Windows, or macOS

## Installation

1. **Install Flutter**
   ```bash
   # Download Flutter SDK from https://flutter.dev/docs/get-started/install
   # Add Flutter to your PATH
   flutter doctor
   ```

2. **Navigate to project directory**
   ```bash
   cd robot_ampi_desktop
   ```

3. **Install dependencies**
   ```bash
   flutter pub get
   ```

## Running the App

```bash
# Run on Linux
flutter run -d linux

# Run on Windows
flutter run -d windows

# Run on macOS
flutter run -d macos
```

## Building for Release

```bash
# Linux
flutter build linux --release

# Windows
flutter build windows --release

# macOS
flutter build macos --release
```

## Serial Protocol

The app communicates with Robot-AmPI using ASCII-based serial commands:

| Command | Format | Description |
|---------|--------|-------------|
| Move | `M<Yaw:000-180><Pitch:060-120>\n` | Move head to position |
| Emotion | `E<EmotionID:00-05>\n` | Show emotion (0=Happy, 1=Angry, 2=Sad, 3=Surprised, 4=Love, 5=Sleepy) |
| Status | `S\n` | Request current status |
| Ping | `P\n` | Heartbeat check |
| Stop | `X\n` | Emergency stop |

**Response Format**: `<RSP><DATA>\n`

## Project Structure

```
lib/
├── main.dart                          # App entry point
├── app.dart                           # Root widget with navigation
├── core/
│   ├── constants/
│   │   ├── commands.dart              # Serial command protocol
│   │   ├── emotions.dart              # Emotion definitions
│   │   └── servo_limits.dart          # Hardware limits
├── features/
│   ├── connection/                    # Serial port management
│   ├── control_panel/                 # Main controls UI
│   ├── joystick/                      # Virtual joystick
│   ├── animation_editor/              # Custom animations (WIP)
│   └── settings/                      # Settings & info
└── shared/
    └── theme/
        └── app_theme.dart             # Material Design 3 theme
```

## Hardware Setup

1. Connect Robot-AmPI to your computer via USB
2. Power on the robot
3. Open the app and navigate to the Connection tab
4. Select the correct serial port (e.g., `/dev/ttyUSB0` on Linux, `COM3` on Windows)
5. Click "Connect"

## Controls

### Control Panel
- **Direction Pad**: 4-way movement control (Up, Down, Left, Right)
- **Emotions**: 6 preset emotions
- **Quick Actions**: Center head, Emergency stop

### Virtual Joystick
- Drag the knob to move the head smoothly
- Release to return to center position
- Real-time position feedback

## Troubleshooting

**Port not found?**
- Check USB connection
- Verify driver installation (CH340/CP2102 for Arduino Nano)
- Run with sudo/Administrator if needed

**Permission denied on Linux?**
```bash
sudo usermod -a -G dialout $USER
# Log out and log back in
```

**Connection fails?**
- Ensure Arduino is powered on
- Check baud rate matches (115200)
- Try unplugging and replugging USB

## License

MIT License

## Credits

- Robot-AmPI hardware by Amperka
- Built with Flutter and Material Design 3
