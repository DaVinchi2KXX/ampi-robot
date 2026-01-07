# Robot-AmPI: AGENTS Documentation

## Overview

Robot-AmPI is an Arduino-based expressive robot head project that combines servo motor control, LED matrix displays, and audio feedback to create an interactive robotic face with emotion capabilities.

## Hardware Architecture

### Main Controller
- **Arduino Nano** - Primary microcontroller
- **ATmega328P** (16 MHz, 2KB RAM, 32KB Flash)

### Actuators
| Component | Pin | Range | Description |
|-----------|-----|-------|-------------|
| Yaw Servo | A3 | 0-180° | Left-right head rotation |
| Pitch Servo | A0 | 60-120° | Up-down head tilt |

### Displays
- **2x LED Matrix (8x8)** for eyes
  - Left eye: I²C address `0x60`
  - Right eye: I²C address `0x63`
  - Library: `TroykaLedMatrix`

### Input/Output
| Component | Pin | Protocol | Purpose |
|-----------|-----|----------|---------|
| IR Receiver | D2 | NEC Protocol | Remote control input |
| Piezo Buzzer | D3 | PWM | Sound effects/melodies |

## Software Architecture

### Operating Modes

#### 1. MODE_HEAD_CONTROL (Default)
- IR remote controls head movement
- Eyes follow gaze direction
- Auto-return to center after 500ms inactivity
- Supports diagonal movements and smooth transitions

#### 2. MODE_EMOTIONS
- Arrow keys cycle through emotions
- Number buttons for quick emotion access
- Head movements used for emotion animations

### Emotion System

Six predefined emotions with multi-sensory feedback:

| Emotion | Button | Visual | Audio | Movement |
|---------|--------|--------|-------|----------|
| Happy | GREEN | Smile with blinking | Rising melody (1000-1400 Hz) | None |
| Angry | MODE1/1 | Angry eyebrows (L/R specific) | Descending aggressive (300-150 Hz) | Head shake |
| Sad | MODE2/2 | Down-turned corners | Descending melody | Head lowers |
| Surprised | MODE3/3 | Wide-open eyes | High-pitched (1500-2000 Hz) | Quick lift |
| Love | - | Heart symbols | Romantic 5-note melody | Gentle nod/sway |
| Sleepy | - | Half-closed eyes | Lullaby melody | Slow drooping |

## Dependencies

```cpp
#include <Servo.h>           // Servo motor control
#include <IRremote.h>         // IR remote reception
#include <TroykaLedMatrix.h>  // LED matrix control
#include <anyrtttl.h>         // RTTTL melody playback
#include <TimerMs.h>          // Precise timing
```

## Code Structure

### Key Functions

| Function | Purpose |
|----------|---------|
| `setup()` | Initialize hardware, load icons from PROGMEM |
| `loop()` | Main state machine, IR processing, timer handling |
| `processIRCode()` | Decode and route IR commands |
| `switchMode()` | Handle mode transitions |
| `showEmotion()` | Execute emotion sequences |
| `eyeIcon()` | Display icons on LED matrices |
| `playMelody()` | Play RTTTL melodies |
| `moveHead()` | Constrained servo movement |

### Constants & Configuration

```cpp
// Servo constraints
#define YAW_MIN 0
#define YAW_MAX 180
#define PITCH_MIN 60
#define PITCH_MAX 120

// Timing
#define GAZE_RETURN_DELAY 500  // ms
#define BLINK_INTERVAL 3000    // ms
```

## IR Remote Mapping

### Head Control Mode
| Button | Action |
|--------|--------|
| UP | Look up |
| DOWN | Look down |
| LEFT | Look left |
| RIGHT | Look right |
| OK | Toggle emotion mode |

### Emotion Mode
| Button | Emotion |
|--------|---------|
| 1 / MODE1 | Angry |
| 2 / MODE2 | Sad |
| 3 / MODE3 | Surprised |
| GREEN | Happy |
| RED | Toggle head control mode |

## Adding New Emotions

To add a new emotion:

1. **Define emotion enum:**
   ```cpp
   enum Emotion { ..., NEW_EMOTION };
   ```

2. **Create eye icons:**
   - Use [LED Matrix Editor](https://xantorohara.github.io/led-matrix-editor/)
   - Export as byte arrays
   - Store in `PROGMEM`

3. **Add melody:**
   - Find/create RTTTL string
   - Add to melody switch case

4. **Define movement:**
   - Add servo sequence in emotion handler

5. **Map IR button:**
   - Add to `processIRCode()` switch statement

## Safety Constraints

- Servo angles are constrained to prevent mechanical damage
- Movement transitions are rate-limited for smooth operation
- Watchdog timer prevents runaway states

## Development Setup

1. **Hardware:**
   - Arduino IDE 1.8+
   - Arduino Nano or compatible
   - USB cable for programming

2. **Libraries:**
   ```bash
   # Install via Arduino Library Manager
   - IRremote
   - Servo (built-in)
   - TroykaLedMatrix
   - anyrtttl
   - TimerMs
   ```

3. **Compilation:**
   - Board: Arduino Nano
   - Processor: ATmega328P (Old Bootloader)

## File Reference

- **Main sketch:** `RobotHeadWithEmotions.ino` (24KB)
- **Documentation:** `README.md` (Russian)
- **License:** MIT

## Contributing

When contributing:
1. Test all servo movements safely
2. Verify IR codes with your remote
3. Document new emotion mappings
4. Keep eye icons symmetrical where appropriate
5. Maintain bilingual comments (RU/EN)

## License

MIT License - See LICENSE file for details
