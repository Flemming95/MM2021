/*
First try of pulsing rainbow circles
*/
float _centerX;
float _centerY;
  
void setup() {
  size(500,300);
  smooth();
  frameRate(5); //5 pro sekunde
  background(0);
  stroke(0.01);
  _centerX = width/2;
  _centerY = height/2;
}

void draw() {
  float colour = random(3); //hier Farben einspeisen
  if (colour < 1.0) { //blau
    background(0,0,51);
    float radius = random(300,400); //an dieser Stelle Frequenzen einspeisen
    
    fill(176,224,230);
    ellipse(_centerX, _centerY, radius, radius);
    
    fill(135,206,250);
    radius -= random(50);
    ellipse(_centerX, _centerY, radius, radius);
    
    fill(0,191,255);
    radius -= random(50,100);
    ellipse(_centerX, _centerY, radius, radius);
    
    fill(30,144,255);
    radius -= random(100,150);
    ellipse(_centerX, _centerY, radius, radius);
    
    fill(65,105,225);
    radius -= random(150,200);
    ellipse(_centerX, _centerY, radius, radius);
    
  } else if (colour < 2.0) { //rot
    background(51,0,0);
    float radius = random(300,400); //an dieser Stelle Frequenzen einspeisen
    
    fill(250,128,114);
    ellipse(_centerX, _centerY, radius, radius);
    
    fill(255,69,0);
    radius -= random(50);
    ellipse(_centerX, _centerY, radius, radius);
    
    fill(128,0,0);
    radius -= random(50,100);
    ellipse(_centerX, _centerY, radius, radius);
    
    fill(220,20,60);
    radius -= random(100,150);
    ellipse(_centerX, _centerY, radius, radius);
    
    fill(139,0,0);
    radius -= random(150,200);
    ellipse(_centerX, _centerY, radius, radius);
  } else { //grün
    background(25,51,0);
    float radius = random(300,400); //an dieser Stelle Frequenzen einspeisen
    
    fill(0,128,0);
    ellipse(_centerX, _centerY, radius, radius);
    
    fill(144,238,144);
    radius -= random(50);
    ellipse(_centerX, _centerY, radius, radius);
    
    fill(154,205,50);
    radius -= random(50,100);
    ellipse(_centerX, _centerY, radius, radius);
    
    fill(0,100,0);
    radius -= random(100,150);
    ellipse(_centerX, _centerY, radius, radius);
    
    fill(46,139,87);
    radius -= random(150,200);
    ellipse(_centerX, _centerY, radius, radius);
  }
}
