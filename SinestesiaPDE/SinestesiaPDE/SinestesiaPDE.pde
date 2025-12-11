/*
grupo Sinestesia
integrantes: Abril Funes, Avril Fernandez Cabreba, Ian Urbañski, Juan Ignacio Ventimiglia y Juan Lehue.
*/

import oscP5.*; 
import netP5.*;
import spout.*; 
import java.util.Arrays; 
import ddf.minim.*; 



// --- CUBO 1 (Izquierda) ---
float CUBE1_ROT_X = 0;
float CUBE1_ROT_Y = 0;
float CUBE1_ROT_Z = 0;

// --- CUBO 2 (Centro) ---
float CUBE2_ROT_X = 0;
float CUBE2_ROT_Y = 0;
float CUBE2_ROT_Z = 0;

// --- CUBO 3 (Derecha) ---
float CUBE3_ROT_X = 0;
float CUBE3_ROT_Y = 0;
float CUBE3_ROT_Z = 0;



final float GRAVITY = 0.01f;
final float FRICTION = -0.9f;
final float LANDMARK_RADIUS = 150.0f;
final float CUBE_SIZE = 200.0f;
final int PARTICLES_PER_SYSTEM = 25;


final PVector CUBE_1_CENTER = new PVector(-400, 0, 0);
final PVector CUBE_2_CENTER = new PVector(0, 0, 0);
final PVector CUBE_3_CENTER = new PVector(400, 0, 0);


public static PShape shapeSphereOBJ;
public static PShape shapeCubeOBJ;
public static PShape shapePyramidOBJ;

ParticleSystem system1, system2, system3;



PVector[] poseLandmarks = new PVector[0];
PVector mouse3D = new PVector(0, 0, 0);

PVector hand1Position = new PVector(0, 0, 0);
PVector hand2Position = new PVector(0, 0, 0);

float lastHand1X = 0.5;
float lastHand1Y = 0.5;

float lastHand2X = 0.5;
float lastHand2Y = 0.5;

PVector leftHand = new PVector();
PVector rightHand = new PVector();
float cubeSize = CUBE_SIZE;
//================================================


int lastLeftInside = 0;
int lastRightInside = 0;



Minim minim;
AudioPlayer[] soundsA = new AudioPlayer[3];
AudioPlayer[] soundsB = new AudioPlayer[3];
AudioPlayer[] soundsC = new AudioPlayer[3];


float cube1Volume = 0.001;   // Volumen de cubo 1 
float cube2Volume = 0.05;   // Volumen de cubo 2 
float cube3Volume = 0.05;   // Volumen de cubo 3 

final long SOUND_COOLDOWN_MS = 1000; 
long[] lastSoundTime = {0, 0, 0,0};
// ===============================================================

OscP5 oscP5;
NetAddress myRemoteLocation;
Spout spout;

//puertos utilizados en OSC
final int OSC_RECEIVE_PORT = 7002;
final int OSC_SEND_PORT = 7004;




void settings() {
  size(1280, 720, P3D);
  PJOGL.profile = 1;
}


void setup() {
  colorMode(HSB, 360, 100, 100, 100);

  minim = new Minim(this);

  soundsA[0] = minim.loadFile(dataPath("A1.wav"));
  soundsA[1] = minim.loadFile(dataPath("A2.wav"));
  soundsA[2] = minim.loadFile(dataPath("A3.wav"));
 
  soundsB[0] = minim.loadFile(dataPath("B1.wav"));
  soundsB[1] = minim.loadFile(dataPath("B2.wav"));
  soundsB[2] = minim.loadFile(dataPath("B3.wav"));
  
  soundsC[0] = minim.loadFile(dataPath("C1.wav"));
  soundsC[1] = minim.loadFile(dataPath("C2.wav"));
  soundsC[2] = minim.loadFile(dataPath("C3.wav"));

  shapeSphereOBJ  = loadShape("esfera21.obj");
  shapeCubeOBJ    = loadShape("esfera31.obj");
  shapePyramidOBJ = loadShape("esferaconpicos.obj");

  perspective();

  spout = new Spout(this);
  spout.createSender("Processing Static Cubes");

  system1 = new ParticleSystem (1, PARTICLES_PER_SYSTEM, Particle3D.SHAPE_PYRAMID, CUBE_1_CENTER, CUBE_SIZE, this, radians(CUBE1_ROT_X), radians(CUBE1_ROT_Y), radians(CUBE1_ROT_Z), 10);
  system2 = new ParticleSystem (2, PARTICLES_PER_SYSTEM, Particle3D.SHAPE_CUBE, CUBE_2_CENTER, CUBE_SIZE, this, radians(CUBE2_ROT_X), radians(CUBE2_ROT_Y), radians(CUBE2_ROT_Z), 15);
  system3 = new ParticleSystem (3, PARTICLES_PER_SYSTEM, Particle3D.SHAPE_SPHERE, CUBE_3_CENTER, CUBE_SIZE, this, radians(CUBE3_ROT_X), radians(CUBE3_ROT_Y), radians(CUBE3_ROT_Z), 15);

  initOSCConnection();
}


void draw() {
  background(0);

  translate(width / 2.0f, height / 2.0f, 0);
  translate(0, 0, -150);

  ambientLight(0, 0, 150);
  directionalLight(255, 255, 255, 0.5f, 0.5f, -1);

  mouse3D.set(mouseX - width / 2.0f, mouseY - height / 2.0f, 0);

  noStroke();

  // --- Mano 1 ---
  pushMatrix();
  translate(hand1Position.x, hand1Position.y, hand1Position.z);
  fill(20, 100, 100);
  sphere(LANDMARK_RADIUS / 5);
  popMatrix();

  // --- Mano 2 ---
  pushMatrix();
  translate(hand2Position.x, hand2Position.y, hand2Position.z);
  fill(180, 100, 100);
  sphere(LANDMARK_RADIUS / 5);
  popMatrix();

  stroke(255, 255, 255, 100);
  strokeWeight(2);
  noFill();

  pushMatrix();
  translate(CUBE_1_CENTER.x, CUBE_1_CENTER.y, CUBE_1_CENTER.z);
  rotateX(radians(CUBE1_ROT_X));
  rotateY(radians(CUBE1_ROT_Y));
  rotateZ(radians(CUBE1_ROT_Z));
  box(CUBE_SIZE);
  popMatrix();

  pushMatrix();
  translate(CUBE_2_CENTER.x, CUBE_2_CENTER.y, CUBE_2_CENTER.z);
  rotateX(radians(CUBE2_ROT_X));
  rotateY(radians(CUBE2_ROT_Y));
  rotateZ(radians(CUBE2_ROT_Z));
  box(CUBE_SIZE);
  popMatrix();

  pushMatrix();
  translate(CUBE_3_CENTER.x, CUBE_3_CENTER.y, CUBE_3_CENTER.z);
  rotateX(radians(CUBE3_ROT_X));
  rotateY(radians(CUBE3_ROT_Y));
  rotateZ(radians(CUBE3_ROT_Z));
  box(CUBE_SIZE);
  popMatrix();

//ejecutamos cada sistema de particulas
  system1.run(poseLandmarks, LANDMARK_RADIUS, GRAVITY, FRICTION, mouse3D, hand1Position, hand2Position);
  system2.run(poseLandmarks, LANDMARK_RADIUS, GRAVITY, FRICTION, mouse3D, hand1Position, hand2Position);
  system3.run(poseLandmarks, LANDMARK_RADIUS, GRAVITY, FRICTION, mouse3D, hand1Position, hand2Position);


// esto hace que las particulas reboten en un cubo rotado
  system1.rotX = radians(CUBE1_ROT_X);
  system1.rotY = radians(CUBE1_ROT_Y);
  system1.rotZ = radians(CUBE1_ROT_Z);

  system2.rotX = radians(CUBE2_ROT_X);
  system2.rotY = radians(CUBE2_ROT_Y);
  system2.rotZ = radians(CUBE2_ROT_Z);

  system3.rotX = radians(CUBE3_ROT_X);
  system3.rotY = radians(CUBE3_ROT_Y);
  system3.rotZ = radians(CUBE3_ROT_Z);


  //deteccion de manos 
  leftHand.set(hand1Position);
  rightHand.set(hand2Position);



  int currentLeftCube = getCubeIndex(leftHand);
  int currentRightCube = getCubeIndex(rightHand);

  if (currentLeftCube != 0) {
    println("👉 Mano IZQUIERDA tocando CUBO: " + currentLeftCube);
  }

  if (currentRightCube != 0) {
    println("👉 Mano DERECHA tocando CUBO: " + currentRightCube);
  }

//detecta si la mano cambio de cubo

  if (currentLeftCube != lastLeftInside) {
    OscMessage mLeft = new OscMessage("/hand/left/cubeIndex");
    mLeft.add(currentLeftCube);
    oscP5.send(mLeft, myRemoteLocation);

  
    if (currentLeftCube != 0) {
      println("✋ IZQUIERDA: Entrando al Cubo " + currentLeftCube);
    } else if (lastLeftInside != 0) {
      println("✋ IZQUIERDA: Saliendo del Cubo " + lastLeftInside);
    }

    // Actualiza el estado guardado
    lastLeftInside = currentLeftCube;
  }


  if (currentRightCube != lastRightInside) {

    // El mensaje OSC reportará el ÍNDICE del cubo tocado (0, 1, 2 o 3)
    OscMessage mRight = new OscMessage("/hand/right/cubeIndex");
    mRight.add(currentRightCube);
    oscP5.send(mRight, myRemoteLocation);

    // Opcional: imprimir debug en consola
    if (currentRightCube != 0) {
      println("✋ DERECHA: Entrando al Cubo " + currentRightCube);
    } else if (lastRightInside != 0) {
      println("✋ DERECHA: Saliendo del Cubo " + lastRightInside);
    }

    // Actualizar el estado guardado
    lastRightInside = currentRightCube;
  }
  // =======================================================



  spout.sendTexture();
}




void initOSCConnection() {
  try {
    oscP5 = new OscP5(this, OSC_RECEIVE_PORT);
    myRemoteLocation = new NetAddress("127.0.0.1", OSC_SEND_PORT);
    println("✓ OSC inicializado correctamente");
  }
  catch (Exception e) {
    println("✗ Error al inicializar OSC: " + e.getMessage());
  }
}




void oscEvent(OscMessage theOscMessage) {
  String address = theOscMessage.addrPattern();

  if (address.equals("/Mano1_ejeX")) {
    if (theOscMessage.arguments().length >= 1) {
      lastHand1X = theOscMessage.get(0).floatValue();
      updateHandPosition(1, lastHand1X, lastHand1Y);
    }
  } else if (address.equals("/Mano1_ejeY")) {
    if (theOscMessage.arguments().length >= 1) {
      lastHand1Y = theOscMessage.get(0).floatValue();
      updateHandPosition(1, lastHand1X, lastHand1Y);
    }
  } else if (address.equals("/Mano2_ejeX")) {
    if (theOscMessage.arguments().length >= 1) {
      lastHand2X = theOscMessage.get(0).floatValue();
      updateHandPosition(2, lastHand2X, lastHand2Y);
    }
  } else if (address.equals("/Mano2_ejeY")) {
    if (theOscMessage.arguments().length >= 1) {
      lastHand2Y = theOscMessage.get(0).floatValue();
      updateHandPosition(2, lastHand2X, lastHand2Y);
    }
  }

  try {
    if (address.equals("/pose/landmarks") || address.equals("/hand/landmarks")) {
    }

    if (address.equals("/simulation/reset")) {
      resetSimulation();
    }
  }
  catch (Exception e) {
    println("✗ Error procesando mensaje OSC: " + address);
    println("  " + e.getMessage());
  }
}

 void resetSimulation() {
  system1.reset();
  system2.reset();
  system3.reset();
  println("↻ Simulación reseteada");
}


void keyPressed() {
  if (key == 'r' || key == 'R') {
    resetSimulation();
  }

  if (key == 'd' || key == 'D') {
    println("═══════════════════════════════════");
    println("DEBUG INFO:");
    println("  Sistemas Activos: 3");
    println("  Partículas totales: " + (PARTICLES_PER_SYSTEM * 3));
    println("  FPS: " + round(frameRate));
    println("═══════════════════════════════════");
  }

  if (key == 'h' || key == 'H') {
    println("═══════════════════════════════════");
    println("CONTROLES:");
    println("  R - Resetear simulación");
    println("  D - Mostrar debug info");
    println("  H - Mostrar ayuda");
    println("═══════════════════════════════════");
  }
}


public void tryPlaySound(int cubeID, float volume) {
    if (cubeID < 1 || cubeID > 3) {
        return;
    }
        
    long currentTime = millis();
    
    // Verifica si ha pasado suficiente tiempo desde el último sonido de este cubo.
    if (currentTime - lastSoundTime[cubeID] > SOUND_COOLDOWN_MS) {
        
        // 1. Reproducir el sonido
        playRandomSound(cubeID, volume);
        lastSoundTime[cubeID] = currentTime;
    }
}


public void playRandomSound(int cubeID, float volume) {
  AudioPlayer[] selectedArray;

  if (cubeID == 1) {
    selectedArray = soundsA;
  } else if (cubeID == 2) {
    selectedArray = soundsB;
  } else if (cubeID == 3) {
    selectedArray = soundsC;
  } else {
    return; // No hay sonido para el cubo 0 (fuera)
  }

  int randomIndex = (int)random(selectedArray.length);
  AudioPlayer sound = selectedArray[randomIndex];

  if (sound == null) {
    println("⚠️ ERROR: El archivo de sonido para el cubo " + cubeID + " (índice " + randomIndex + ") no se cargó correctamente.");
    return;
  }

float finalVolume = volume;  // volumen que viene del sistema

// Aplicar el volumen por cubo
if (cubeID == 1) finalVolume *= cube1Volume;
if (cubeID == 2) finalVolume *= cube2Volume;
if (cubeID == 3) finalVolume *= cube3Volume;

  float minimVolume = map(finalVolume, 0, 1, -30.0f, 0.0f);
  sound.setGain(minimVolume);
  sound.rewind();
  sound.play();
}





void updateHandPosition(int handID, float normX, float normY) {
  println("Hand " + handID + " - X_Norm: " + normX + ", Y_Norm: " + normY);

  float x = map(normX, 0, 1, width/2, -width/2);
  float y = map(normY, 0, 1, height/2, -height/2);
  float z = 0;

  if (handID == 1) {
    hand1Position.set(x, y, z);
  } else if (handID == 2) {
    hand2Position.set(x, y, z);
  }
}

int getCubeIndex(PVector hand) {
  float half = CUBE_SIZE / 2;

  // CUBO 1
  if (hand.x > CUBE_1_CENTER.x - half && hand.x < CUBE_1_CENTER.x + half &&
    hand.y > CUBE_1_CENTER.y - half && hand.y < CUBE_1_CENTER.y + half &&
    hand.z > CUBE_1_CENTER.z - half && hand.z < CUBE_1_CENTER.z + half) {
    return 1;
  }

  // CUBO 2
  if (hand.x > CUBE_2_CENTER.x - half && hand.x < CUBE_2_CENTER.x + half &&
    hand.y > CUBE_2_CENTER.y - half && hand.y < CUBE_2_CENTER.y + half &&
    hand.z > CUBE_2_CENTER.z - half && hand.z < CUBE_2_CENTER.z + half) {
    return 2;
  }

  // CUBO 3
  if (hand.x > CUBE_3_CENTER.x - half && hand.x < CUBE_3_CENTER.x + half &&
    hand.y > CUBE_3_CENTER.y - half && hand.y < CUBE_3_CENTER.y + half &&
    hand.z > CUBE_3_CENTER.z - half && hand.z < CUBE_3_CENTER.z + half) {
    return 3;
  }

  return 0; // fuera de todos
}

void stop() {
  // Libera los recursos de audio
  for (AudioPlayer sound : soundsA) sound.close();
  for (AudioPlayer sound : soundsB) sound.close();
  for (AudioPlayer sound : soundsC) sound.close();
  minim.stop();
  super.stop();
}
