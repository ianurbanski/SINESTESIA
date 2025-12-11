import processing.core.*;

class ParticleSystem {
  PApplet p;
  Particle3D[] particles;  
  int cubeID;  
  PVector containerCenter;  
  float containerSize;  
  int particleShape;
  float rotX, rotY, rotZ;
  float shapeScaleFactor;



 
  ParticleSystem(int cubeID, int numParticles, int shapeType, PVector center, float size, PApplet parent, float rx, float ry, float rz, float sFactor) {
    this.cubeID = cubeID;
    this.p = parent;
    this.containerCenter = center;
    this.containerSize = size;
    this.particleShape = shapeType;
    this.particles = new Particle3D[numParticles];

    this.rotX = rx; 
    this.rotY = ry;
    this.rotZ = rz;

    this.shapeScaleFactor = sFactor;

    initializeParticles(numParticles);
  }
  
  

 
  void initializeParticles(int numParticles) {
    float halfSize = containerSize / 2.0f;

    for (int i = 0; i < numParticles; i++) {
      // Posición inicial aleatoria dentro de los límites del cubo
      float startX = containerCenter.x + p.random(-halfSize, halfSize);
      float startY = containerCenter.y + p.random(-halfSize, halfSize);
      float startZ = containerCenter.z + p.random(-halfSize, halfSize);

      // Crea una nueva partícula
      PShape model;

      if (particleShape == Particle3D.SHAPE_SPHERE)  model = SinestesiaPDE.shapeSphereOBJ; 
      else if (particleShape == Particle3D.SHAPE_CUBE) model = SinestesiaPDE.shapeCubeOBJ;
      else model = SinestesiaPDE.shapePyramidOBJ;

      particles[i] = new Particle3D(startX, startY, startZ, random(15, 30), i, particles, p, particleShape, containerCenter, containerSize, model, rotX, rotY, rotZ, shapeScaleFactor, cubeID);
    }
  }



  void run(PVector[] poseLandmarks, float landmarkRadius, float gravity, float friction, PVector mouse3D, PVector hand1Pos, PVector hand2Pos) {
    for (Particle3D particle : particles) {

    
      particle.containerRotX = this.rotX;
      particle.containerRotY = this.rotY;
      particle.containerRotZ = this.rotZ;
      // -----------------------------------------------------------------------

      
      if (poseLandmarks.length > 0) {
        particle.collideWithPose(poseLandmarks, landmarkRadius);
      }
      particle.collideWithMouse(hand1Pos, landmarkRadius, 1);
      particle.collideWithMouse(hand2Pos, landmarkRadius, 2);

      

      
      particle.move(p, gravity, friction);

      particle.display();
    }
  }



  /*
  - reinicia el sistema
  */
  void reset() {
    float halfSize = containerSize / 2.0f;

    for (Particle3D particle : particles) {
      particle.x = containerCenter.x + p.random(-halfSize, halfSize);
      particle.y = containerCenter.y + p.random(-halfSize, halfSize);
      particle.z = containerCenter.z + p.random(-halfSize, halfSize);

      // Reiniciar velocidades
      particle.vx = 0;
      particle.vy = 0;
      particle.vz = 0;
    }
  }
}
