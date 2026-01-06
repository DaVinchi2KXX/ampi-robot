// Подключаем библиотеку для работы с мелодиями в формате RTTTL
#include <anyrtttl.h>

// Подключаем библиотеку для работы с ИК-приёмником
#include <IRremote.hpp>

// Подключаем библиотеку для работы с сервоприводом
#include <Servo.h>

// Подключаем библиотеку для работы с таймером millis
#include <TimerMs.h>

// Подключаем библиотеку для работы со светодиодными матрицами
#include <TroykaLedMatrix.h>

// Даём понятное имя пину 3 с пищалкой
constexpr uint8_t BUZZER_PIN = 3;

// Даём понятное имя пину 2 с ИК-приёмником
constexpr uint8_t IR_RECEIVE_PIN = 2;

// Даём понятное имя пину A3 с сервоприводом
constexpr uint8_t SERVO_YAW_PIN = A3;
// Даём понятное имя пину A0 с сервоприводом
constexpr uint8_t SERVO_PITCH_PIN = A0;

// Создаём объект сервопривода влево-вправо
Servo servoYaw;
// Создаём объект сервопривода вверх-вниз
Servo servoPitch;

// Создаём объект для работы с таймером
TimerMs timer;

// Создаём объект матрицы левого глаза
// на шине I²C с адресом 0x60 (указан по умолчанию)
TroykaLedMatrix matrixL;
// Создаём объект матрицы правого глаза
// на шине I²C с адресом 0x63
TroykaLedMatrix matrixR(0x63);

// Создаём константу для хранения базовой частоты
constexpr int FREQUENCY = 2000;

// Создаём константы для хранения минимальной и максимальной частоты
constexpr int MIN_FREQUENCY = FREQUENCY - (0.25 * FREQUENCY);
constexpr int MAX_FREQUENCY = FREQUENCY + (0.25 * FREQUENCY);

// Задаём максимально доступные углы поворота сервопривода головы влево-вправо
constexpr uint8_t MAX_ANGLE_YAW_R = 0;
constexpr uint8_t MAX_ANGLE_YAW_L = 180;

// Задаём максимально доступные углы поворота сервопривода головы вверх-вниз
constexpr uint8_t MAX_ANGLE_PITCH_DOWN = 60;
constexpr uint8_t MAX_ANGLE_PITCH_UP = 120;

// Вычисляем средний угол поворота сервопривода головы влево-вправо
constexpr uint8_t MID_ANGLE_YAW = (MAX_ANGLE_YAW_R + MAX_ANGLE_YAW_L) / 2;

// Вычисляем средний угол поворота сервопривода головы вверх-вниз
constexpr uint8_t MID_ANGLE_PITCH = (MAX_ANGLE_PITCH_DOWN + MAX_ANGLE_PITCH_UP) / 2;

// Создаём переменную для хранения текущего положения сервопривода головы влево-вправо
uint8_t angleYaw = MID_ANGLE_YAW;
// Создаём переменную для хранения текущего положения сервопривода головы вверх-вниз
uint8_t anglePitch = MID_ANGLE_PITCH;

// Создаём константу для хранения паузы между поворотом вала сервопривода
constexpr uint8_t ANGLE_RANGE = 2;
// Используем отдельную константу для расчёта количества эмоций
constexpr uint8_t EMOTION_COUNT = 6;

// ==================== ИКОНКИ НАПРАВЛЕНИЙ ВЗГЛЯДА ====================

// Создаём иконку «Взгляд прямо» в шестнадцатеричной системе HEX
constexpr uint8_t ICON_EYE_STRAIGHT[] PROGMEM = {
  0x7e, 0x81, 0x81, 0x99, 0x99, 0x81, 0x81, 0x7e
};

// Создаём иконку «Взгляд влево»
constexpr uint8_t ICON_EYE_LEFT[] PROGMEM = {
  0x7e, 0x81, 0x81, 0xe1, 0xe1, 0x81, 0x81, 0x7e
};

// Создаём иконку «Взгляд вправо»
constexpr uint8_t ICON_EYE_RIGHT[] PROGMEM = {
  0x7e, 0x81, 0x81, 0x87, 0x87, 0x81, 0x81, 0x7e
};

// Создаём иконку «Взгляд вверх»
constexpr uint8_t ICON_EYE_UP[] PROGMEM = {
  0x7e, 0x99, 0x99, 0x81, 0x81, 0x81, 0x81, 0x7e
};

// Создаём иконку «Взгляд вниз»
constexpr uint8_t ICON_EYE_DOWN[] PROGMEM = {
  0x7e, 0x81, 0x81, 0x81, 0x81, 0x99, 0x99, 0x7e
};

// ==================== ИКОНКИ ЭМОЦИЙ ====================

// Создаём иконку «Глаза выключены»
constexpr uint8_t ICON_EYE_OFF[] PROGMEM = {
  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
};

// ==================== РАДОСТЬ ====================
// Создаём иконку «Радость» - улыбка
constexpr uint8_t ICON_EYE_HAPPY[] PROGMEM = {
  0x3c, 0x42, 0x99, 0xa5, 0xa5, 0x99, 0x42, 0x3c
};

// ==================== ЗЛОСТЬ ====================
// Создаём иконку «Злость» для левого глаза
constexpr uint8_t ICON_EYE_ANGRY_L[] PROGMEM = {
  0x40, 0xa0, 0x90, 0x88, 0xb4, 0xb2, 0x82, 0x7c
};

// Создаём иконку «Злость» для правого глаза
constexpr uint8_t ICON_EYE_ANGRY_R[] PROGMEM = {
  0x02, 0x05, 0x09, 0x11, 0x2d, 0x4d, 0x41, 0x3e
};

// ==================== ГРУСТЬ ====================
// Создаём иконку «Грусть» для левого глаза
constexpr uint8_t ICON_EYE_SAD_L[] PROGMEM = {
  0x0e, 0x11, 0x21, 0x41, 0x4d, 0x4d, 0x42, 0x3c
};

// Создаём иконку «Грусть» для правого глаза
constexpr uint8_t ICON_EYE_SAD_R[] PROGMEM = {
  0x70, 0x88, 0x84, 0x82, 0xb2, 0xb2, 0x42, 0x3c
};

// ==================== УДИВЛЕНИЕ ====================
// Создаём иконку «Удивление» - широко открытые глаза
constexpr uint8_t ICON_EYE_SURPRISED[] PROGMEM = {
  0x3c, 0x7e, 0xff, 0xe7, 0xe7, 0xff, 0x7e, 0x3c
};

// ==================== СЕРДЕЧКИ ====================
// Создаём иконку «Сердечки»
constexpr uint8_t ICON_EYE_LOVE[] PROGMEM = {
  0x0c, 0x1e, 0x3f, 0x7e, 0x3f, 0x1e, 0x0c, 0x00
};

// ==================== СОНЛИВОСТЬ ====================
// Создаём иконки «Сонливость»
constexpr uint8_t ICON_EYE_SLEEPY_L[] PROGMEM = {
  0x40, 0x20, 0x10, 0x08, 0x04, 0x0e, 0x1f, 0x00
};

constexpr uint8_t ICON_EYE_SLEEPY_R[] PROGMEM = {
  0x02, 0x04, 0x08, 0x10, 0x20, 0x70, 0xf8, 0x00
};

// ==================== РЕЖИМЫ РАБОТЫ ====================

// Создаём перечисление режимов робота
enum RobotMode {
  MODE_HEAD_CONTROL,  // Режим управления головой
  MODE_EMOTIONS       // Режим отображения эмоций
};

// Создаём перечисление состояний робота
enum RobotState {
  ROBOT_ON,
  ROBOT_OFF
};

// Создаём перечисление эмоций
enum Emotion {
  EMOTION_HAPPY,      // Радость
  EMOTION_ANGRY,      // Злость
  EMOTION_SAD,        // Грусть
  EMOTION_SURPRISED,  // Удивление
  EMOTION_LOVE,       // Сердечки
  EMOTION_SLEEPY      // Сонливость
};

// Создаём переменную для хранения режима работы
RobotMode robotMode = MODE_HEAD_CONTROL;

// Создаём переменную для хранения состояния робота
RobotState robotState = ROBOT_ON;

// Создаём переменную для хранения текущей эмоции
Emotion currentEmotion = EMOTION_HAPPY;

// ==================== КОДЫ ИК-ПУЛЬТА ====================
// ВАЖНО: Раскомментируйте и измените эти коды согласно вашему пульту!
// Используйте скетч из эксперимента №7 для определения кодов кнопок
enum CODE {
  POWER = 0x0B,       // Включение/выключение
  LEFT = 0x08,        // Влево
  RIGHT = 0x19,       // Вправо
  UP = 0x06,          // Вверх
  DOWN = 0x1D,        // Вниз
  UP_LEFT = 0x0A,     // Вверх-влево
  UP_RIGHT = 0x1A,    // Вверх-вправо
  DOWN_LEFT = 0x18,   // Вниз-влево
  DOWN_RIGHT = 0x04,  // Вниз-вправо
  RED = 0x00,         // Красная кнопка - переключение режима
  GREEN = 0x03,       // Зелёная кнопка - радость
  BLUE = 0x01,        // Синяя кнопка - следующая эмоция
  MODE1 = 0x45,       // Кнопка 1 - злость
  MODE2 = 0x46,       // Кнопка 2 - грусть
  MODE3 = 0x47        // Кнопка 3 - удивление
} code;

// ==================== СТРУКТУРА АНИМАЦИИ ====================

struct AnimationFrame {
  uint8_t* iconEyeL;
  uint8_t* iconEyeR;
  int timeFrame;
};

// ==================== ФУНКЦИИ ====================

void setup() {
  // Подключаем сервомоторы головы
  servoYaw.attach(SERVO_YAW_PIN);
  servoPitch.attach(SERVO_PITCH_PIN);

  // Устанавливаем начальные углы
  angleYaw = MID_ANGLE_YAW;
  anglePitch = MID_ANGLE_PITCH;
  servoYaw.write(angleYaw);
  servoPitch.write(anglePitch);

  // Инициализируем ИК-приёмник
  IrReceiver.begin(IR_RECEIVE_PIN);

  // Инициализируем матрицы
  matrixL.begin();
  matrixR.begin();
  matrixL.clear();
  matrixR.clear();

  // Отображаем иконку «Взгляд прямо»
  drawIcon(ICON_EYE_STRAIGHT, ICON_EYE_STRAIGHT);

  // Настраиваем таймер
  timer.setTimerMode();

  // Инициализируем генератор случайных чисел
  randomSeed(analogRead(A1));

  robotState = ROBOT_ON;
}

void loop() {
  if (robotState == ROBOT_ON) {
    handleRobotOn();
  } else {
    handleRobotOff();
  }
}

// Функция отображения иконки на матрицах
void drawIcon(uint8_t* iconEyeL, uint8_t* iconEyeR) {
  matrixL.drawBitmapF(iconEyeL);
  matrixR.drawBitmapF(iconEyeR);
}

// Функция обработки режима «Робот выключен»
void handleRobotOff() {
  drawIcon(ICON_EYE_OFF, ICON_EYE_OFF);
  while (robotState == ROBOT_OFF) {
    remoteHandlerRobotOff();
  }
}

// Функция обработки режима «Робот включен»
void handleRobotOn() {
  drawIcon(ICON_EYE_STRAIGHT, ICON_EYE_STRAIGHT);
  while (robotState == ROBOT_ON) {
    if (robotMode == MODE_HEAD_CONTROL) {
      remoteHandlerHeadControl();
    } else {
      remoteHandlerEmotions();
    }
  }
}

// Функция обработки ИК-приёмника в режиме «Робот выключен»
void remoteHandlerRobotOff() {
  if (IrReceiver.decode()) {
    uint32_t code = IrReceiver.decodedIRData.command;

    if (code == POWER) {
      delay(500);
      robotState = ROBOT_ON;
    }

    IrReceiver.resume();
  }
}

// Функция обработки ИК-приёмника в режиме управления головой
void remoteHandlerHeadControl() {
  if (IrReceiver.decode()) {
    uint32_t receivedCode = IrReceiver.decodedIRData.command;

    timer.setTime(500);
    timer.start();

    switch (receivedCode) {
      case POWER:
        delay(500);
        robotState = ROBOT_OFF;
        break;

      case LEFT:
        angleYaw = constrain(angleYaw - ANGLE_RANGE, MAX_ANGLE_YAW_R, MAX_ANGLE_YAW_L);
        servoYaw.write(angleYaw);
        drawIcon(ICON_EYE_LEFT, ICON_EYE_LEFT);
        break;

      case RIGHT:
        angleYaw = constrain(angleYaw + ANGLE_RANGE, MAX_ANGLE_YAW_R, MAX_ANGLE_YAW_L);
        servoYaw.write(angleYaw);
        drawIcon(ICON_EYE_RIGHT, ICON_EYE_RIGHT);
        break;

      case UP:
        anglePitch = constrain(anglePitch + ANGLE_RANGE, MAX_ANGLE_PITCH_DOWN, MAX_ANGLE_PITCH_UP);
        servoPitch.write(anglePitch);
        drawIcon(ICON_EYE_UP, ICON_EYE_UP);
        break;

      case DOWN:
        anglePitch = constrain(anglePitch - ANGLE_RANGE, MAX_ANGLE_PITCH_DOWN, MAX_ANGLE_PITCH_UP);
        servoPitch.write(anglePitch);
        drawIcon(ICON_EYE_DOWN, ICON_EYE_DOWN);
        break;

      case UP_LEFT:
        angleYaw = constrain(angleYaw - ANGLE_RANGE, MAX_ANGLE_YAW_R, MAX_ANGLE_YAW_L);
        anglePitch = constrain(anglePitch + ANGLE_RANGE, MAX_ANGLE_PITCH_DOWN, MAX_ANGLE_PITCH_UP);
        servoYaw.write(angleYaw);
        servoPitch.write(anglePitch);
        drawIcon(ICON_EYE_LEFT, ICON_EYE_LEFT);
        break;

      case UP_RIGHT:
        angleYaw = constrain(angleYaw + ANGLE_RANGE, MAX_ANGLE_YAW_R, MAX_ANGLE_YAW_L);
        anglePitch = constrain(anglePitch + ANGLE_RANGE, MAX_ANGLE_PITCH_DOWN, MAX_ANGLE_PITCH_UP);
        servoYaw.write(angleYaw);
        servoPitch.write(anglePitch);
        drawIcon(ICON_EYE_RIGHT, ICON_EYE_RIGHT);
        break;

      case DOWN_LEFT:
        angleYaw = constrain(angleYaw - ANGLE_RANGE, MAX_ANGLE_YAW_R, MAX_ANGLE_YAW_L);
        anglePitch = constrain(anglePitch - ANGLE_RANGE, MAX_ANGLE_PITCH_DOWN, MAX_ANGLE_PITCH_UP);
        servoYaw.write(angleYaw);
        servoPitch.write(anglePitch);
        drawIcon(ICON_EYE_LEFT, ICON_EYE_LEFT);
        break;

      case DOWN_RIGHT:
        angleYaw = constrain(angleYaw + ANGLE_RANGE, MAX_ANGLE_YAW_R, MAX_ANGLE_YAW_L);
        anglePitch = constrain(anglePitch - ANGLE_RANGE, MAX_ANGLE_PITCH_DOWN, MAX_ANGLE_PITCH_UP);
        servoYaw.write(angleYaw);
        servoPitch.write(anglePitch);
        drawIcon(ICON_EYE_RIGHT, ICON_EYE_RIGHT);
        break;

      case RED:
        // Переключение между режимами управления головой и эмоциями
        toggleMode();
        break;

      case GREEN:
        // Быстрое отображение радости с анимацией
        showEmotion(EMOTION_HAPPY);
        break;

      case BLUE:
        // Следующая эмоция
        nextEmotion();
        showEmotion(currentEmotion);
        delay(2000);
        break;

      case MODE1:
        // Злость
        showEmotion(EMOTION_ANGRY);
        delay(2000);
        break;

      case MODE2:
        // Грусть
        showEmotion(EMOTION_SAD);
        delay(2000);
        break;

      case MODE3:
        // Сердечки
        showEmotion(EMOTION_LOVE);
        delay(2000);
        break;
    }

    IrReceiver.resume();
  }

  // Возвращаем взгляд прямо если нет нажатий 500мс
  if (timer.tick()) {
    drawIcon(ICON_EYE_STRAIGHT, ICON_EYE_STRAIGHT);
  }
}

// Функция обработки ИК-приёмника в режиме эмоций
void remoteHandlerEmotions() {
  if (IrReceiver.decode()) {
    uint32_t receivedCode = IrReceiver.decodedIRData.command;

    switch (receivedCode) {
      case POWER:
        delay(500);
        robotState = ROBOT_OFF;
        break;

      case RED:
        // Переключение между режимами
        toggleMode();
        break;

      case GREEN:
        // Радость
        showEmotion(EMOTION_HAPPY);
        break;

      case BLUE:
        // Следующая эмоция
        nextEmotion();
        showEmotion(currentEmotion);
        break;

      case MODE1:
        // Злость
        showEmotion(EMOTION_ANGRY);
        break;

      case MODE2:
        // Грусть
        showEmotion(EMOTION_SAD);
        break;

      case MODE3:
        // Сердечки
        showEmotion(EMOTION_LOVE);
        break;

      case UP:
      case DOWN:
      case LEFT:
      case RIGHT:
      case UP_LEFT:
      case UP_RIGHT:
      case DOWN_LEFT:
      case DOWN_RIGHT:
        // В режиме эмоций стрелки переключают эмоции
        nextEmotion();
        showEmotion(currentEmotion);
        break;
    }

    IrReceiver.resume();
  }
}

// Переключение между режимами работы
void toggleMode() {
  IrReceiver.stop();

  if (robotMode == MODE_HEAD_CONTROL) {
    robotMode = MODE_EMOTIONS;
    // Сигнал о переключении в режим эмоций
    playModeSwitchSound(true);
  } else {
    robotMode = MODE_HEAD_CONTROL;
    // Сигнал о переключении в режим управления головой
    playModeSwitchSound(false);
    // Возвращаем голову в центр
    angleYaw = MID_ANGLE_YAW;
    anglePitch = MID_ANGLE_PITCH;
    servoYaw.write(angleYaw);
    servoPitch.write(anglePitch);
    drawIcon(ICON_EYE_STRAIGHT, ICON_EYE_STRAIGHT);
  }

  IrReceiver.start();
}

// Переключение на следующую эмоцию
void nextEmotion() {
  currentEmotion = (Emotion)((currentEmotion + 1) % EMOTION_COUNT);
}

// Отображение эмоции с анимацией
void showEmotion(Emotion emotion) {
  IrReceiver.stop();

  switch (emotion) {
    case EMOTION_HAPPY:
      showHappyAnimation();
      break;
    case EMOTION_ANGRY:
      showAngryAnimation();
      break;
    case EMOTION_SAD:
      showSadAnimation();
      break;
    case EMOTION_SURPRISED:
      showSurprisedAnimation();
      break;
    case EMOTION_LOVE:
      showLoveAnimation();
      break;
    case EMOTION_SLEEPY:
      showSleepyAnimation();
      break;
  }

  IrReceiver.start();
}

// Анимация радости
void showHappyAnimation() {
  // Моргание и улыбка
  for (int i = 0; i < 3; i++) {
    drawIcon(ICON_EYE_OFF, ICON_EYE_OFF);
    delay(100);
    drawIcon(ICON_EYE_HAPPY, ICON_EYE_HAPPY);
    delay(100);
  }

  // Звук радости
  playHappySound();

  // Удерживаем эмоцию
  delay(1000);

  // Возвращаем нормальный вид
  drawIcon(ICON_EYE_STRAIGHT, ICON_EYE_STRAIGHT);
}

// Анимация злости
void showAngryAnimation() {
  // Плавный переход к злости
  drawIcon(ICON_EYE_STRAIGHT, ICON_EYE_STRAIGHT);
  delay(200);
  drawIcon(ICON_EYE_ANGRY_L, ICON_EYE_ANGRY_R);
  delay(100);

  // Тряска головой для демонстрации злости
  for (int i = 0; i < 3; i++) {
    angleYaw = MID_ANGLE_YAW + 10;
    servoYaw.write(angleYaw);
    delay(100);
    angleYaw = MID_ANGLE_YAW - 10;
    servoYaw.write(angleYaw);
    delay(100);
  }

  // Возвращаем в центр
  angleYaw = MID_ANGLE_YAW;
  servoYaw.write(angleYaw);

  // Звук злости
  playAngrySound();

  // Удерживаем эмоцию
  delay(1000);

  // Возвращаем нормальный вид
  drawIcon(ICON_EYE_STRAIGHT, ICON_EYE_STRAIGHT);
}

// Анимация грусти
void showSadAnimation() {
  // Медленный переход к грусти
  drawIcon(ICON_EYE_SAD_L, ICON_EYE_SAD_R);

  // Опускаем голову
  for (int i = 0; i < 5; i++) {
    anglePitch = constrain(anglePitch - 2, MAX_ANGLE_PITCH_DOWN, MAX_ANGLE_PITCH_UP);
    servoPitch.write(anglePitch);
    delay(100);
  }

  // Звук грусти
  playSadSound();

  // Удерживаем эмоцию
  delay(1500);

  // Возвращаем голову в центр
  anglePitch = MID_ANGLE_PITCH;
  servoPitch.write(anglePitch);
  delay(500);

  // Возвращаем нормальный вид
  drawIcon(ICON_EYE_STRAIGHT, ICON_EYE_STRAIGHT);
}

// Анимация удивления
void showSurprisedAnimation() {
  // Быстрое появление удивлённых глаз
  drawIcon(ICON_EYE_OFF, ICON_EYE_OFF);
  delay(50);
  drawIcon(ICON_EYE_SURPRISED, ICON_EYE_SURPRISED);

  // Резкий подъём головы
  anglePitch = constrain(MID_ANGLE_PITCH + 15, MAX_ANGLE_PITCH_DOWN, MAX_ANGLE_PITCH_UP);
  servoPitch.write(anglePitch);

  // Звук удивления
  playSurprisedSound();

  // Удерживаем эмоцию
  delay(800);

  // Возвращаем голову в центр
  anglePitch = MID_ANGLE_PITCH;
  servoPitch.write(anglePitch);

  // Возвращаем нормальный вид
  drawIcon(ICON_EYE_STRAIGHT, ICON_EYE_STRAIGHT);
}

// Анимация «Сердечки»
void showLoveAnimation() {
  // Мягкое моргание с сердечками
  for (int i = 0; i < 2; i++) {
    drawIcon(ICON_EYE_OFF, ICON_EYE_OFF);
    delay(120);
    drawIcon(ICON_EYE_LOVE, ICON_EYE_LOVE);
    delay(180);
  }

  // Небольшие кивки головой
  anglePitch = constrain(MID_ANGLE_PITCH + 6, MAX_ANGLE_PITCH_DOWN, MAX_ANGLE_PITCH_UP);
  servoPitch.write(anglePitch);
  delay(150);
  anglePitch = constrain(MID_ANGLE_PITCH - 6, MAX_ANGLE_PITCH_DOWN, MAX_ANGLE_PITCH_UP);
  servoPitch.write(anglePitch);
  delay(150);
  anglePitch = MID_ANGLE_PITCH;
  servoPitch.write(anglePitch);

  // Небольшое покачивание влево-вправо
  uint8_t initialYaw = angleYaw;
  angleYaw = constrain(MID_ANGLE_YAW - 8, MAX_ANGLE_YAW_R, MAX_ANGLE_YAW_L);
  servoYaw.write(angleYaw);
  delay(180);
  angleYaw = constrain(MID_ANGLE_YAW + 8, MAX_ANGLE_YAW_R, MAX_ANGLE_YAW_L);
  servoYaw.write(angleYaw);
  delay(180);
  angleYaw = initialYaw;
  servoYaw.write(angleYaw);

  // Звук влюблённости
  playLoveSound();

  // Удерживаем эмоцию
  delay(1200);

  // Возвращаем нормальный вид
  drawIcon(ICON_EYE_STRAIGHT, ICON_EYE_STRAIGHT);
}

// Анимация сонливости
void showSleepyAnimation() {
  // Мягкое закрытие глаз
  drawIcon(ICON_EYE_SLEEPY_L, ICON_EYE_SLEEPY_R);

  // Медленно опускаем голову
  for (int i = 0; i < 6; i++) {
    anglePitch = constrain(anglePitch - 2, MAX_ANGLE_PITCH_DOWN, MAX_ANGLE_PITCH_UP);
    servoPitch.write(anglePitch);
    delay(120);
  }

  // Спокойный звук сна
  playSleepySound();

  // Лёгкое возвратно-поступательное движение как «дремота»
  for (int i = 0; i < 2; i++) {
    anglePitch = constrain(anglePitch + 3, MAX_ANGLE_PITCH_DOWN, MAX_ANGLE_PITCH_UP);
    servoPitch.write(anglePitch);
    delay(200);
    anglePitch = constrain(anglePitch - 3, MAX_ANGLE_PITCH_DOWN, MAX_ANGLE_PITCH_UP);
    servoPitch.write(anglePitch);
    delay(200);
  }

  // Возвращаем голову в центр
  anglePitch = MID_ANGLE_PITCH;
  servoPitch.write(anglePitch);
  delay(300);

  // Возвращаем нормальный вид
  drawIcon(ICON_EYE_STRAIGHT, ICON_EYE_STRAIGHT);
}

// ==================== ЗВУКОВЫЕ ЭФФЕКТЫ ====================

// Звук переключения режима
void playModeSwitchSound(bool toEmotion) {
  if (toEmotion) {
    tone(BUZZER_PIN, 800, 100);
    delay(150);
    tone(BUZZER_PIN, 1200, 100);
  } else {
    tone(BUZZER_PIN, 1200, 100);
    delay(150);
    tone(BUZZER_PIN, 800, 100);
  }
  delay(200);
}

// Звук радости
void playHappySound() {
  for (int i = 0; i < 3; i++) {
    tone(BUZZER_PIN, 1000 + i * 200, 100);
    delay(120);
  }
  noTone(BUZZER_PIN);
}

// Звук злости
void playAngrySound() {
  for (int i = 0; i < 5; i++) {
    int freq = 300 - i * 30;
    tone(BUZZER_PIN, freq, 80);
    delay(100);
  }
  noTone(BUZZER_PIN);
}

// Звук грусти
void playSadSound() {
  for (int i = 0; i < 4; i++) {
    int freq = 600 - i * 80;
    tone(BUZZER_PIN, freq, 200);
    delay(250);
  }
  noTone(BUZZER_PIN);
}

// Звук удивления
void playSurprisedSound() {
  tone(BUZZER_PIN, 1500, 100);
  delay(150);
  tone(BUZZER_PIN, 2000, 150);
  delay(200);
  noTone(BUZZER_PIN);
}

// Звук сердечек
void playLoveSound() {
  int melody[] = { 880, 988, 1175, 988, 880 };
  for (int i = 0; i < 5; i++) {
    tone(BUZZER_PIN, melody[i], 120);
    delay(160);
  }
  noTone(BUZZER_PIN);
}

// Звук сонливости
void playSleepySound() {
  int melody[] = { 523, 494, 440, 392 };
  for (int i = 0; i < 4; i++) {
    tone(BUZZER_PIN, melody[i], 200);
    delay(260);
  }
  noTone(BUZZER_PIN);
}
