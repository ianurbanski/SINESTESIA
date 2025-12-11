import processing.core.*;




class Particle3D {
  
  final static int SHAPE_SPHERE = 0;
  final static int SHAPE_CUBE = 1;
  final static int SHAPE_PYRAMID = 2;


  float x, y, z;
  float vx, vy, vz;
  float diameter;
  
 
  int id;
  int cubeID;
  float mass;
  int shapeType; 

  
  PShape model3D;

  
  float rotX, rotY, rotZ;
  float rotSpeedX, rotSpeedY, rotSpeedZ;

  // Color
  float hue;

 
  PVector containerCenter;
  float containerSize;
  float containerHalfSize;

  float containerRotX, containerRotY, containerRotZ;

  float visualScale;

  
  PApplet p;
  Particle3D[] others;

  final float MOUSE_RADIUS = 150.0f;

 
  Particle3D(float xin, float yin, float zin, float din, int idin, Particle3D[] oin, PApplet parent, int sType, PVector center, float size, PShape model3D, float rotX, float rotY, float rotZ, float sFactor, int cubeID) {
    
    this.cubeID = cubeID;
    this.p = parent;
    this.x = xin;
    this.y = yin;
    this.z = zin;
    this.diameter = din;
    this.id = idin;
    this.others = oin;
    this.mass = din * 0.1f;

    this.shapeType = sType;

    this.containerCenter = center;
    this.containerSize = size;
    this.containerHalfSize = size / 2.0f;


    this.containerRotX = rotX;
    this.containerRotY = rotY;
    this.containerRotZ = rotZ;

    this.visualScale = sFactor;

    
    this.vx = 0;
    this.vy = 0;
    this.vz = 0;
    
    this.rotX = parent.random(parent.TWO_PI);
    this.rotY = parent.random(parent.TWO_PI);
    this.rotZ = parent.random(parent.TWO_PI);
    
    this.rotSpeedX = parent.random(-0.03f, 0.03f);
    this.rotSpeedY = parent.random(-0.03f, 0.03f);
    this.rotSpeedZ = parent.random(-0.03f, 0.03f);
    
   
    this.model3D = model3D;
  }



 void collideWithPose(PVector[] landmarks, float landmarkRadius) {
    for (int i = 0; i < landmarks.length; i++) {
      PVector landmark = landmarks[i];
      int landmarkID = i;

      float dx = landmark.x - this.x;
      float dy = landmark.y - this.y;
      float dz = landmark.z - this.z;

      float distance = PApplet.sqrt(dx * dx + dy * dy + dz * dz);
      float minDist = landmarkRadius / 2 + this.diameter / 2;

      if (distance < minDist && distance > 0) {
        float force = (minDist - distance) * 0.2f;

        float nx = dx / distance;
        float ny = dy / distance;
        float nz = dz / distance;

        this.vx -= nx * force;
        this.vy -= ny * force;
        this.vz -= nz * force;

        this.x -= nx * (minDist - distance) * 0.5f;
        this.y -= ny * (minDist - distance) * 0.5f;
        this.z -= nz * (minDist - distance) * 0.5f;

        float normalizedForce = constrain(force / 10.0f, 0, 1);
        ((SinestesiaPDE)p).tryPlaySound(this.cubeID, normalizedForce);
      }
    }
  }




  void collideWithMouse(PVector mousePos, float mouseRadius, int handID) {
    final float REPULSION_FACTOR = 0.2f;

    float dx = mousePos.x - this.x;
    float dy = mousePos.y - this.y;
    float dz = 0;

    float distance = PApplet.sqrt(dx * dx + dy * dy + dz * dz);
    float minDist = mouseRadius / 2 + this.diameter / 2;

    if (distance < minDist && distance > 0) {
      float force = (minDist - distance) * REPULSION_FACTOR * 5.0f;

      float nx = dx / distance;
      float ny = dy / distance;

      this.vx -= nx * force;
      this.vy -= ny * force;

      this.x -= nx * (minDist - distance) * 0.1f;
      this.y -= ny * (minDist - distance) * 0.1f;

      float normalizedForce = constrain(force / 10.0f, 0, 1);
      ((SinestesiaPDE)p).tryPlaySound(this.cubeID, normalizedForce);
    }
  } 




  void move(PApplet p, float gravity, float friction) {
    final float THRESHOLD = 0.01f;

    
    this.vy += gravity;
    this.x += this.vx;
    this.y += this.vy;
    this.z += this.vz;

   
    float rx = this.x - containerCenter.x;
    float ry = this.y - containerCenter.y;
    float rz = this.z - containerCenter.z;


    float temp_x, temp_y, temp_z;

   
    temp_x = rx * PApplet.cos(-containerRotZ) - ry * PApplet.sin(-containerRotZ);
    temp_y = rx * PApplet.sin(-containerRotZ) + ry * PApplet.cos(-containerRotZ);
    rx = temp_x;
    ry = temp_y;

   
    temp_x = rx * PApplet.cos(-containerRotY) + rz * PApplet.sin(-containerRotY);
    temp_z = -rx * PApplet.sin(-containerRotY) + rz * PApplet.cos(-containerRotY);
    rx = temp_x;
    rz = temp_z;

    
    temp_y = ry * PApplet.cos(-containerRotX) - rz * PApplet.sin(-containerRotX);
    temp_z = ry * PApplet.sin(-containerRotX) + rz * PApplet.cos(-containerRotX);
    ry = temp_y;
    rz = temp_z;

   
    float margin = this.diameter / 2.0f;
    float maxLocal = containerHalfSize - margin;

    // Colisión X
    if (rx > maxLocal) {
      rx = maxLocal;
      this.vx *= friction;
      if (PApplet.abs(this.vx) < THRESHOLD) this.vx = 0;
    } else if (rx < -maxLocal) {
      rx = -maxLocal;
      this.vx *= friction;
      if (PApplet.abs(this.vx) < THRESHOLD) this.vx = 0;
    }

    // Colisión Y
    if (ry > maxLocal) {
      ry = maxLocal;
      this.vy *= friction;
      if (PApplet.abs(this.vy) < THRESHOLD) this.vy = 0;
    } else if (ry < -maxLocal) {
      ry = -maxLocal;
      this.vy *= friction;
      if (PApplet.abs(this.vy) < THRESHOLD) this.vy = 0;
    }

    // Colisión Z
    if (rz > maxLocal) {
      rz = maxLocal;
      this.vz *= friction;
      if (PApplet.abs(this.vz) < THRESHOLD) this.vz = 0;
    } else if (rz < -maxLocal) {
      rz = -maxLocal;
      this.vz *= friction;
      if (PApplet.abs(this.vz) < THRESHOLD) this.vz = 0;
    }

  

    // Rotación normal X
    temp_y = ry * PApplet.cos(containerRotX) - rz * PApplet.sin(containerRotX);
    temp_z = ry * PApplet.sin(containerRotX) + rz * PApplet.cos(containerRotX);
    ry = temp_y;
    rz = temp_z;

    // Rotación normal Y
    temp_x = rx * PApplet.cos(containerRotY) + rz * PApplet.sin(containerRotY);
    temp_z = -rx * PApplet.sin(containerRotY) + rz * PApplet.cos(containerRotY);
    rx = temp_x;
    rz = temp_z;

    // Rotación normal Z
    temp_x = rx * PApplet.cos(containerRotZ) - ry * PApplet.sin(containerRotZ);
    temp_y = rx * PApplet.sin(containerRotZ) + ry * PApplet.cos(containerRotZ);
    rx = temp_x;
    ry = temp_y;

 
    this.x = rx + containerCenter.x;
    this.y = ry + containerCenter.y;
    this.z = rz + containerCenter.z;

   
    this.rotX += this.rotSpeedX;
    this.rotY += this.rotSpeedY;
    this.rotZ += this.rotSpeedZ;
  }
  
  


  void display() {
    p.pushMatrix();
    p.translate(this.x, this.y, this.z);

    // Rotación de la partícula
    p.rotateX(this.rotX);
    p.rotateY(this.rotY);
    p.rotateZ(this.rotZ);

    p.noStroke();

    // Escala final del modelo
    float scaleFactor = this.diameter;

    if (model3D != null) {
      // **✓ CAMBIO 7: Usar la nueva escala visual del sistema**
      p.scale(this.visualScale);
      // ------------------------------------------------------
      p.shape(model3D);
    }

    p.popMatrix();
  }

 PVector getPosition() {
    return new PVector(this.x, this.y, this.z);
  }
}
