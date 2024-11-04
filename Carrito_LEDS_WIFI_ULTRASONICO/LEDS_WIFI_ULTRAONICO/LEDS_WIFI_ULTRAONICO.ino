#include <WiFi.h>
#include <HTTPClient.h>
#include <ArduinoJson.h>
#include "mbedtls/sha256.h"

const char* ssid = "ELIAS";
const char* password = "987654321";
const char* url_last_status = "http://54.198.42.156:5000/last_status";
const char* url_update = "http://54.198.42.156:5000/status";

// Pines de motor y LEDs
const int enable[] = {26, 25};
const int inputs[] = {27, 14, 13, 12};
const int led_frente[] = {2, 4};      // LEDs frontales
const int led_traseros[] = {22, 21};  // LEDs traseros

// Pines para el sensor ultrasónico
const int trigPin = 18;
const int echoPin = 19;

const int movimientos[][4] = {
  {HIGH, LOW, HIGH, LOW}, // Adelante
  {LOW, HIGH, LOW, HIGH}, // Atrás
  {LOW, LOW, HIGH, LOW},  // Izquierda
  {HIGH, LOW, LOW, LOW},  // Derecha
  {LOW, LOW, LOW, LOW},   // Parar
  {HIGH, LOW, HIGH, LOW}, // Vuelta derecha esquinada
  {HIGH, LOW, HIGH, LOW}, // Vuelta izquierda esquinada
  {HIGH, LOW, LOW, HIGH}  // Giro sobre su propio eje
};

const int velocidades[][2] = {
  {255, 255}, {255, 255}, {0, 255}, {255, 0},
  {0, 0}, {255, 200}, {200, 255},
  {250, 250}  // Velocidades para el giro sobre su propio eje
};

int ultimoStatus = 0;
unsigned long tiempoParpadeo = 0;
unsigned long tiempoUltimaConsulta = 0;
const unsigned long intervaloConsulta = 500; // Intervalo de 500 ms (medio segundo)
bool estadoParpadeo = false;
bool obstaculoDetectado = false;

void setup() {
  Serial.begin(115200);
  WiFi.begin(ssid, password);
  while (WiFi.status() != WL_CONNECTED) delay(500);

  for (int pin : enable) pinMode(pin, OUTPUT);
  for (int pin : inputs) pinMode(pin, OUTPUT);
  for (int pin : led_frente) pinMode(pin, OUTPUT);
  for (int pin : led_traseros) pinMode(pin, OUTPUT);

  // Configuración del sensor ultrasónico
  pinMode(trigPin, OUTPUT);
  pinMode(echoPin, INPUT);
}

void loop() {
  bool obstaculo = detectarObstaculo();
  unsigned long tiempoActual = millis();
  
  if (obstaculo) {
    if (!obstaculoDetectado) {
      obstaculoDetectado = true;
      ejecutarMovimiento(8); // 8 = Giro sobre su propio eje
    }
  } else {
    if (obstaculoDetectado) {
      obstaculoDetectado = false;
      detenerMotores(); // Detiene inmediatamente el giro cuando ya no hay obstáculo

      // Realiza una nueva consulta de estado tan pronto como el obstáculo se despeje
      if (tiempoActual - tiempoUltimaConsulta >= intervaloConsulta) {
        int status = obtenerStatusAPI();
        ejecutarMovimiento(status);
        actualizarLeds(status);
        ultimoStatus = status;
        tiempoUltimaConsulta = tiempoActual;
      }
    } else {
      if (tiempoActual - tiempoUltimaConsulta >= intervaloConsulta) {
        int status = obtenerStatusAPI();
        if (status != ultimoStatus) {
          ejecutarMovimiento(status);
          actualizarLeds(status);
          ultimoStatus = status;
        }
        tiempoUltimaConsulta = tiempoActual;
      }
    }
  }

  // Parpadeo de LEDs cuando está detenido
  if (ultimoStatus == 5 && millis() - tiempoParpadeo >= 300) {
    estadoParpadeo = !estadoParpadeo;
    for (int pin : led_frente) digitalWrite(pin, estadoParpadeo);
    for (int pin : led_traseros) digitalWrite(pin, estadoParpadeo);
    tiempoParpadeo = millis();
  }
}

void ejecutarMovimiento(int status) {
  int tipo = status - 1;
  
  // Ejecuta el movimiento y enciende los motores
  for (int i = 0; i < 4; i++) digitalWrite(inputs[i], movimientos[tipo][i]);
  analogWrite(enable[0], velocidades[tipo][0]);
  analogWrite(enable[1], velocidades[tipo][1]);

  // Si es giro a la izquierda o derecha, dura 1 segundo y luego se detiene
  if (status == 3 || status == 4) { // Izquierda o Derecha
    delay(1000); // Duración del giro de 1 segundo (aproximadamente 90 grados)
    detenerMotores(); // Detener los motores después del giro
  }
}

void actualizarLeds(int status) {
  apagarLeds();
  if (status == 1) { // Adelante
    encenderLeds(led_frente);
  } else if (status == 2) { // Atrás
    encenderLeds(led_traseros);
  } else if (status == 3) { // Izquierda
    digitalWrite(led_frente[0], HIGH);  // LED frontal izquierdo
    digitalWrite(led_traseros[0], HIGH); // LED trasero izquierdo
  } else if (status == 4) { // Derecha
    digitalWrite(led_frente[1], HIGH);   // LED frontal derecho
    digitalWrite(led_traseros[1], HIGH);  // LED trasero derecho
  } else if (status == 6) { // Esquinado izquierda
    digitalWrite(led_frente[1], HIGH);   // LED frontal izquierdo
    digitalWrite(led_traseros[1], HIGH); // LED trasero izquierdo
  } else if (status == 7) { // Esquinado derecha
    digitalWrite(led_frente[0], HIGH);   // LED frontal derecho
    digitalWrite(led_traseros[0], HIGH); // LED trasero derecho
  }
}

void apagarLeds() {
  for (int pin : led_frente) digitalWrite(pin, LOW);
  for (int pin : led_traseros) digitalWrite(pin, LOW);
}

void encenderLeds(const int* leds) {
  for (int i = 0; i < 2; i++) digitalWrite(leds[i], HIGH);
}

void detenerMotores() {
  for (int pin : enable) analogWrite(pin, 0);
}

int obtenerStatusAPI() {
  if (WiFi.status() != WL_CONNECTED) return 5; // Valor de "detener"
  HTTPClient http;
  http.begin(url_last_status);
  http.setTimeout(500); // Tiempo de espera de medio segundo (500 ms)
  int status = 5;  // Valor por defecto si falla
  if (http.GET() == HTTP_CODE_OK) {
    StaticJsonDocument<512> doc;
    deserializeJson(doc, http.getString());
    status = doc[0]["status"];
    actualizarIdDevice();
  }
  http.end();
  return status;
}

void actualizarIdDevice() {
  HTTPClient http;
  http.begin(url_update);
  http.addHeader("Content-Type", "application/json");
  unsigned char hash[32];
  mbedtls_sha256((const unsigned char*)"Alejandro elias vazquez", strlen("Alejandro elias vazquez"), hash, 0);
  
  String hashString;
  for (int i = 0; i < 32; i++) hashString += String(hash[i], HEX);
  
  StaticJsonDocument<128> doc;
  doc["id_device"] = hashString;
  String jsonString;
  serializeJson(doc, jsonString);

  if (http.PUT(jsonString) != HTTP_CODE_OK) Serial.println("Error al actualizar ID");
  http.end();
}

// Función para detectar obstáculo con sensor ultrasónico
bool detectarObstaculo() {
  digitalWrite(trigPin, LOW);
  delayMicroseconds(2);
  digitalWrite(trigPin, HIGH);
  delayMicroseconds(10);
  digitalWrite(trigPin, LOW);
  long duracion = pulseIn(echoPin, HIGH);
  long distancia = duracion * 0.034 / 2; // Cálculo de distancia en cm
  return (distancia <= 30); // Retorna verdadero si la distancia es 30 cm o menor
}
