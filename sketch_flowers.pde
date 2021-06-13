/*
First try of pulsing rainbow circles
*/
float _centerX; //Fenster-Mitte
float _centerY;
float coordX; //Koordinaten des gezeichneten Musters
float coordY;
float factor;
float noisyRadius; 
float rad;
float noiseArgument;
  
void setup() {
  size(500,300);
  smooth();
  frameRate(5); //5 pro sekunde
  background(0);
  strokeWeight(0.01);
  _centerX = width/2;
  _centerY = height/2;
}

void draw() {
  float colour = random(3);
  float radius = random(100,200); //an dieser Stelle Frequenzen einspeisen
  background(0);
  for (int i = 0; i <= 5; i++) {
    beginShape();
    if (colour < 1) {
      fill(random(100), random(100,200), random(200,255), random(100,255));
    } else if (colour < 2) {
      fill(random(150,255), random(150), random(150), random(100,255));
    } else {
      fill(random(50,150), random(150,255), random(50), random(100,255));
    }
    noiseArgument = random(10);
    for(float angle=0;angle<=360;angle+=1){
      noiseArgument += 0.09; //Eingabe in die noise Funktion muss inkrementiert werden
      factor = 35 * customNoise(noiseArgument);
      noisyRadius = radius + factor; 
      
      rad = radians(angle);
      coordX = _centerX + (noisyRadius * cos(rad)); 
      coordY = _centerY + (noisyRadius * sin(rad));
      
      curveVertex(coordX, coordY);
    }
    endShape();
    radius -= 20;
  }
}

float customNoise(float value) { 
  float retValue = pow(sin(value), 3); 
  return retValue;
}
   
