/*
Second try of pulsing rainbow circles
*/
float _centerX; //Fenster-Mitte
float _centerY;
float coordX; //Koordinaten des gezeichneten Musters
float coordY;
float factor;
float noisyRadius; 
float rad;
float noiseArgument;
float radius;
float count;
boolean pulse;
int trans;
  
void setup() {
  size(500,300);
  smooth();
  frameRate(20); //20 pro sekunde
  background(0);
  strokeWeight(0.01);
  _centerX = width/2;
  _centerY = height/2;
  //start:
  radius = 100;
  noiseArgument = 10;
  count = 0;
  //pulse = true;
  trans = 255;
}

void draw() {
  background(0);
  pushMatrix();
  translate(_centerX, _centerY);
  rotate(frameCount / 50.0);
  flower(noiseArgument, 270, color(135, 206, 250, 150), false);
  flower(noiseArgument, 220, color(135, 206, 250, 150), false);
  flower(noiseArgument, 180, color(135, 206, 250, 150), false);
  flower(noiseArgument, 150, color(135, 206, 250, 150), false);
  flower(noiseArgument, 130, color(135, 206, 250, trans), true);
  flower(noiseArgument, radius, color(125,185,245, trans), true);
  flower(noiseArgument, radius-30, color(115,165,240, trans), true);
  flower(noiseArgument, radius-60, color(100,149,237, trans), true);
  
  //um ein pulsieren hinzukriegen....??? boah keine Ahnung
  if (count == 0) { //wir fangen bei count == 0 an
    pulse = true;
  }
  if (count == 30) { 
    pulse = false;
  }
  if (pulse) { 
    radius += 1;
    trans -= 5;
    count++;
  }
  if (!pulse) {
    radius -= 1;
    trans += 5;
    count--;
  }

  popMatrix();
}

void flower(float noiseArgument, float radius, color c, boolean fill) { 
            //noiseArgument bildet Basis für die customNoise Funktion
            //radius für Größe der Blume
  /*
  Ein Flower Shape erzeugen
  */
  beginShape();
  if (fill == true) {
    fill(c);
  } else {
    stroke(255);
    strokeWeight(1);
    noFill();
  }
  for(float angle=0;angle<=360;angle+=1){
    factor = 35 * customNoise(noiseArgument);
    noisyRadius = radius + factor;
    rad = radians(angle);
    coordX = (noisyRadius * cos(rad)); 
    coordY = (noisyRadius * sin(rad));
    curveVertex(coordX, coordY);
    noiseArgument += 0.0872; //Eingabe in die noise Funktion muss inkrementiert werden
  }
  endShape(CLOSE);
}

float customNoise(float value) { 
  float retValue = sin(value); 
  //float retValue = pow(sin(value), 5); 
  return retValue;
}
   
