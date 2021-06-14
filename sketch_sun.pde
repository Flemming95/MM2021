float _centerX;
float _bottomY; //Sonne unten: Y Koordinate liegt bei 0
float x; //End-Koordinaten der Sonnenstrahlen
float y; 
float randomRadius;

void setup() {
  size(500,300);
  strokeWeight(0.5); 
  smooth();
  _centerX = width/2;
  _bottomY = height;
  frameRate(5);
}

void draw() {
  float colour = random(4); //Farbe ändern
  if (colour < 1) {
    background(255,153,51);
    fill(255,153,51);
  } else if (colour < 2) {
    background(102,204,0);
    fill(102,204,0);
  } else if (colour < 3) {
    background(102,178,255);
    fill(102,178,255);
  } else {
    background(255,153,204);
    fill(255,153,204);
  }
  
  for (float ang = 0; ang <= 360; ang += 5) { 
    randomRadius = random(110, 250); //Frequenzen bestimmen Länge der Strahlen
    float rad = radians(ang);
    x = _centerX + (randomRadius * cos(rad));
    y = _bottomY + (randomRadius * sin(rad));
    
    stroke(255);
    strokeWeight(1.5);
    line(_centerX,_bottomY,x,y);
  }
  noStroke();
  //fill(0);
  ellipse(_centerX, _bottomY, 200, 200);
}
