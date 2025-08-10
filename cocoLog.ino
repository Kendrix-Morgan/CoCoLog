// ✅ [Includes and Global Variables]
#include <M5StickCPlus.h>
#include <Wire.h>
#include "MAX30105.h"
#include "heartRate.h"
#include "spo2_algorithm.h"
#include <BLEDevice.h>
#include <BLEServer.h>
#include <BLEUtils.h>
#include <BLE2902.h>

TFT_eSprite Disbuff = TFT_eSprite(&M5.Lcd);
MAX30105 Sensor;

#define MAX_BRIGHTNESS 255
#define bufferLength   100
const byte Button_A = 37;
const byte pulseLED = 26;

uint32_t irBuffer[bufferLength];
uint32_t redBuffer[bufferLength];

int8_t flag_Reset;
int32_t spo2, heartRate, old_spo2;
int8_t validSPO2, validHeartRate;
const byte RATE_SIZE = 5;
uint16_t rate_begin = 0;
uint16_t rates[RATE_SIZE];
byte rateSpot = 0;
float beatsPerMinute;
int beatAvg;
byte num_fail;

uint16_t line[2][320] = {0};

uint32_t red_pos = 0, ir_pos = 0;
uint16_t ir_max = 0, red_max = 0, ir_min = 0, red_min = 0, ir_last = 0, red_last = 0;
uint16_t ir_last_raw = 0, red_last_raw = 0;
uint16_t ir_disdata, red_disdata;
uint16_t Alpha = (uint16_t)(0.3 * 256);
uint32_t t1, t2, last_beat, Program_freq;

static long last10Beats[10] = {0};
static int beatIndex = 0;
static bool bufferFilled = false;
float HRV = 0;

bool fingerWasPresent = false;
unsigned long fingerStartTime = 0;

BLECharacteristic *pCharacteristic;
bool deviceConnected = false;
bool resultSent = false;

class MyServerCallbacks : public BLEServerCallbacks {
  void onConnect(BLEServer*) override {
    deviceConnected = true;
  }

  void onDisconnect(BLEServer* pServer) override {
    deviceConnected = false;
    Serial.println("BLE Disconnected, restarting advertising...");
    pServer->startAdvertising();
  }
};

void setup() {
  M5.begin();
  Serial.begin(115200);
  pinMode(25, INPUT_PULLUP);
  pinMode(pulseLED, OUTPUT);
  Wire.begin(0, 26);

  M5.Lcd.setRotation(3);
  M5.Lcd.setSwapBytes(false);
  Disbuff.createSprite(240, 135);
  Disbuff.setSwapBytes(true);

  // ✅ BLE Setup
  BLEDevice::init("CocoLog");
  BLEServer *pServer = BLEDevice::createServer();
  pServer->setCallbacks(new MyServerCallbacks());

  BLEService *pService = pServer->createService("6E400001-B5A3-F393-E0A9-E50E24DCCA9E");
  pCharacteristic = pService->createCharacteristic(
    "6E400003-B5A3-F393-E0A9-E50E24DCCA9E",
    BLECharacteristic::PROPERTY_NOTIFY | BLECharacteristic::PROPERTY_WRITE_NR
  );

  class MyCallbacks : public BLECharacteristicCallbacks {
    void onWrite(BLECharacteristic *pCharacteristic) override {
      std::string value = pCharacteristic->getValue();
      if (value == "start") {
        flag_Reset = 1;
        resultSent = false;
      }
    }
  };

  pCharacteristic->setCallbacks(new MyCallbacks());
  pCharacteristic->addDescriptor(new BLE2902());
  pService->start();
  pServer->getAdvertising()->start();

  if (!Sensor.begin(Wire, I2C_SPEED_FAST)) {
    M5.Lcd.print("Init Failed");
    Serial.println("MAX30102 was not found. Please check wiring/power.");
    while (1);
  }

  Sensor.setup();
}

void loop() {
  uint16_t ir, red;

  if (flag_Reset) {
    Sensor.clearFIFO();
    delay(5);
    flag_Reset = 0;
  }

  while (flag_Reset == 0) {
    while (Sensor.available() == false) {
      delay(10);
      Sensor.check();
    }

    while (1) {
      red = Sensor.getRed();
      ir = Sensor.getIR();

      if ((ir > 1000) && (red > 1000)) {
        if (!fingerWasPresent) {
          fingerWasPresent = true;
          fingerStartTime = millis(); // 🌟 Start timer
        }

        if (millis() - fingerStartTime >= 3000) { // ⏱ Wait at least 3 seconds
          num_fail = 0;
          t1 = millis();
          redBuffer[(red_pos + 100) % 100] = red;
          irBuffer[(ir_pos + 100) % 100] = ir;
          t2 = millis();
          Program_freq++;

          if (checkForBeat(ir)) {
            long delta = millis() - last_beat - (t2 - t1) * (Program_freq - 1);
            last_beat = millis();

            last10Beats[beatIndex] = last_beat;
            beatIndex++;
            if (beatIndex >= 6) {
              beatIndex = 0;
              bufferFilled = true;
            }

            if (bufferFilled) {
              float intervals[5], sum = 0, mean, variance = 0;
              for (int i = 0; i < 5; i++) {
                intervals[i] = (last10Beats[(i + 1) % 10] - last10Beats[i]) / 1000.0;
                sum += intervals[i];
              }
              mean = sum / 5;
              for (int i = 0; i < 5; i++) variance += pow(intervals[i] - mean, 2);
              HRV = sqrt(variance / 5.0);
            }

            Program_freq = 0;
            beatsPerMinute = 60 / (delta / 1000.0);
            if ((beatsPerMinute > 30) && (beatsPerMinute < 120)) {
              rate_begin++;
              if ((abs(beatsPerMinute - beatAvg) > 15) && ((beatsPerMinute < 55) || (beatsPerMinute > 95)))
                beatsPerMinute = beatAvg * 0.9 + beatsPerMinute * 0.1;
              if ((abs(beatsPerMinute - beatAvg) > 10) && (beatAvg > 60) &&
                  ((beatsPerMinute < 65) || (beatsPerMinute > 90)))
                beatsPerMinute = beatsPerMinute * 0.4 + beatAvg * 0.6;
              rates[rateSpot++] = (byte)beatsPerMinute;
              rateSpot %= RATE_SIZE;
              beatAvg = beatsPerMinute;
            }
          }
        }

      } else {
        // 🛑 Finger removed → Send final result
        if (fingerWasPresent && !resultSent) {
          if (deviceConnected) {
            String msg = String(beatAvg) + "," + String(HRV, 2) + "," + String(spo2) + "\n";
            pCharacteristic->setValue(msg.c_str());
            pCharacteristic->notify();
          }
          fingerWasPresent = false;
          resultSent = true;
          Sensor.clearFIFO();
          break;
        }

        num_fail++;
        red = red_last_raw;
        ir = ir_last_raw;
        fingerWasPresent = false;
        fingerStartTime = 0;
      }

      line[0][(red_pos + 240) % 320] = (red_last_raw * (256 - Alpha) + red * Alpha) / 256;
      line[1][(ir_pos + 240) % 320] = (ir_last_raw * (256 - Alpha) + ir * Alpha) / 256;
      red_last_raw = line[0][(red_pos + 240) % 320];
      ir_last_raw = line[1][(ir_pos + 240) % 320];
      red_pos++;
      ir_pos++;

      if ((Sensor.check() == false) || flag_Reset) break;
    }

    Sensor.clearFIFO();

    for (int i = 0; i < 240; i++) {
      if (i == 0) {
        red_max = red_min = line[0][(red_pos + i) % 320];
        ir_max = ir_min = line[1][(ir_pos + i) % 320];
      } else {
        red_max = max(red_max, line[0][(red_pos + i) % 320]);
        red_min = min(red_min, line[0][(red_pos + i) % 320]);
        ir_max = max(ir_max, line[1][(ir_pos + i) % 320]);
        ir_min = min(ir_min, line[1][(ir_pos + i) % 320]);
      }
      if (flag_Reset) break;
    }

    Disbuff.fillRect(0, 0, 240, 135, BLACK);

    for (int i = 0; i < 240; i++) {
      red_disdata = map(line[0][(red_pos + i) % 320], red_max, red_min, 0, 135);
      ir_disdata  = map(line[1][(ir_pos + i) % 320], ir_max, ir_min, 0, 135);
      Disbuff.drawLine(i, red_last, i + 1, red_disdata, RED);
      Disbuff.drawLine(i, ir_last, i + 1, ir_disdata, BLUE);
      ir_last = ir_disdata;
      red_last = red_disdata;
      if (flag_Reset) break;
    }

    old_spo2 = spo2;
    if (red_pos > 100)
      maxim_heart_rate_and_oxygen_saturation(irBuffer, bufferLength,
                                             redBuffer, &spo2, &validSPO2,
                                             &heartRate, &validHeartRate);
    if (!validSPO2) spo2 = old_spo2;

    Disbuff.setTextSize(2);
    Disbuff.setTextColor(GREEN);
    Disbuff.setCursor(5, 30); Disbuff.printf("Oxygen Level:\n");
    Disbuff.setCursor(160, 30); Disbuff.printf("%d%%", spo2);
    Disbuff.setCursor(5, 60); Disbuff.printf("BPM:\n");
    Disbuff.setCursor(160, 60); Disbuff.printf("%d", beatAvg);
    Disbuff.setCursor(5, 90); Disbuff.printf("HRV:\n");
    Disbuff.setCursor(160, 90); Disbuff.printf("%.2f", HRV);
    Disbuff.pushSprite(0, 0);
  }
}