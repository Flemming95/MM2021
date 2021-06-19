import ddf.minim.*;
import ddf.minim.analysis.*;
import javax.swing.*;
import javax.swing.filechooser.FileNameExtensionFilter;
import controlP5.*;

Minim minim;
AudioPlayer player;
Button loadFileButton;
Button pauseButton;
Button playButton;
Button exitButton;
Button flowerButton;
Button sunButton;
Button circleButton;
boolean sun;
boolean flower;
boolean circle;
File selection;
int sliderTicks; //slider background color
ControlP5 cp5; 
boolean isPlaying;
int returnVal;
JFileChooser filechooser;
String extensionDescription;
String[] extension;
FileNameExtensionFilter extensionfilter;
FFT fft;

float _centerX;
float _bottomY; //Sonne unten: Y Koordinate liegt bei 0
float x; //End-Koordinaten der Sonnenstrahlen
float y; 
float randomRadius;


float _centerY;
float coordX; //Koordinaten des gezeichneten Musters
float coordY;
float factor;
float noisyRadius; 
float rad;
float noiseArgument;
float radius;
void setup(){
  size(900, 700,P3D);
  minim = new Minim(this);
  //https://github.com/anars/blank-audio/blob/master/1-minute-of-silence.mp3
  //initialising audioplayer
  player = minim.loadFile("silent.mp3",2048);
  
  loadFileButton = new Button(75,100,150.0,20.0, "Choose an audiofile.");
  pauseButton = new Button(170.0,150.0,40.0,20.0, "Pause");
  playButton = new Button(90.0,150.0,40.0,20.0, "Play");
  exitButton = new Button(850,660,40,20,"Exit");
  sunButton = new Button(100, 660, 60,20, "Sun Art");
  flowerButton = new Button(180, 660, 60,20, "Flower Art");
  circleButton = new Button(260, 660, 60,20,"Circle Art");
  
  int minVol= 0; //minimum volume = 0
  int maxVol = 90; //max volume = 90
  cp5 = new ControlP5(this);
  //background color of slider 
   sliderTicks=30;
   cp5.addSlider("Volume")
     .setPosition(60,190) //position of the slider
     .setWidth(150)      
     .setRange(minVol, maxVol) 
     .setValue(20)
     .setNumberOfTickMarks(10)
     .setSliderMode(Slider.FLEXIBLE);
  filechooser= new JFileChooser();
  extensionfilter=new FileNameExtensionFilter(".mp3 or .wav", "mp3", "wav");
  isPlaying= false;
  sun=true;
  flower=false;
  circle=false;
  
  // create an FFT object that has a time-domain buffer 
  // the same size as players sample buffer
  // note that this needs to be a power of two 
  // and that it means the size of the spectrum will be half as large.
  fft = new FFT( player.bufferSize(), player.sampleRate() );
  
  frameRate(5);
 
  _centerX = width/2;
  _bottomY = height;
  _centerY = height/2;
  
  }
 
 void draw(){
  background(0);
  //stroke(255);
  // perform a forward FFT on the samples in player's mix buffer,
  // which contains the mix of both the left and right channels of the file
  /*fft.forward(player.mix);
  //specSize: size of the spectrum created by fft
  for(int i = 0; i < fft.specSize(); i++){
  line( i, height, i,height -  fft.getBand(i)*8);
  }*/
  loadFileButton.drawButton();
  pauseButton.drawButton();
  playButton.drawButton();
  exitButton.drawButton();
  sunButton.drawButton();
  flowerButton.drawButton(); //<>//
  circleButton.drawButton();
  fill(sliderTicks);
  rect(55,190,200,20);
  sliderVol();
  //color line=color(30,144,255);
  //rect(300,50,500,500);
  fft.forward( player.mix );
   if(isPlaying){
 
  //ellipse(300,300, fft.getBand(i), fft.getBand(i)); 

     if(sun==true){
        sunArt();
      }
      if(flower==true){
        flowerArt();
      }
      if(circle==true){
      circleArt();
    }
      loadFileButton.drawButton();
      pauseButton.drawButton();
      playButton.drawButton();
      sunButton.drawButton();
      flowerButton.drawButton();
      exitButton.drawButton();
      circleButton.drawButton();
       //slider 
       //fill(sliderTicks);
       //slider rectangle background  
       rect(55,190,200,20);
    }
}
  
  void mouseClicked(){
    if(loadFileButton.CheckClick()){
        //Filter WAV and MP3 file
        filechooser.setFileFilter(extensionfilter);
        returnVal= filechooser.showOpenDialog(null);
        if(returnVal==JFileChooser.APPROVE_OPTION){
          selection = filechooser.getSelectedFile();
          //lädt AudioFile selection in den Player ein
          player.pause();
          player = minim.loadFile(selection.getPath(),2048);
          player.play();
          isPlaying=true;
        }
     }
     if(pauseButton.CheckClick()){
       player.pause();
       isPlaying=false;
     }
     if(playButton.CheckClick()){
       if(selection!=null){ 
         player.play(); 
         isPlaying=true;
       }
     }
     if(exitButton.CheckClick()){
        exit();
     }
     if(flowerButton.CheckClick()){
       circle= false;
       sun=false;
       flower=true;
     }
     if(sunButton.CheckClick()){
       circle= false;
       flower=false;
       sun=true;
     }
     if(circleButton.CheckClick()){
       sun=false;
       flower=false;
       circle=true;
     }
    } 
 
 /**
 * changes the volume per slider control
 */
 void sliderVol(){
   //gets the current value of the slider, range 0 to 100
   float volume=cp5.getController("Volume").getValue();
   //sets decibel(range 14(loudest) to -80(quietest)) for the volume
   player.setGain(volume-50);
   if(volume==0){
   player.mute();
     }
   else 
     player.unmute();
 }
  
  void flowerArt(){
  float colour = random(3); //<>//
  for(int i = 0; i < fft.specSize(); i++){
  //an dieser Stelle Frequenzen einspeisen
  for (int j = 0; j <= 5; j++) {
    beginShape();
    if (colour < 1) {
      fill(random(100), random(100,200), random(200,255), random(100,255));
    } else if (colour < 2) {
      fill(random(150,255), random(150), random(150), random(100,255));
    } else {
      fill(random(50,150), random(150,255), random(50), random(100,255));
    }
  }
    noiseArgument = random(10);
  {
    // get the amplitude of the frequency band
    for(float angle=0;angle<=360;angle+=1){
      radius=fft.getBand(i);
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
  }  
  
  float customNoise(float value) { 
  float retValue = pow(sin(value), 3); 
  return retValue;
  }
  
  void sunArt(){
    float colour = color(255,153,51); //hier Farben einspeisen
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
    for(int i = 0; i < fft.specSize(); i++){
    for (float ang = 0; ang <= 360; ang += 5) { 
    randomRadius = fft.getBand(i)*1.5; //Frequenzen bestimmen Länge der Strahlen
    float rad = radians(ang);
    x = _centerX + (randomRadius * cos(rad));
    y = _bottomY + (randomRadius * sin(rad));
    
    stroke(255);
    strokeWeight(1.5);
    line(_centerX,_bottomY,x,y);
  }
  noStroke();
  //fill(0);
  ellipse(_centerX, _bottomY,150,150); //200, 200);
  }
  } 
  
  void circleArt(){
  smooth();
  noStroke();
  background(255);
  //strokeWeight(0.5);
  float colour = color(1,0,0);//(255,153,51); //hier Farben einspeisen
  if (colour < 1.0) { //blau
    background(0,0,51);
    for(int i = 0; i < fft.specSize(); i++){
    radius = fft.getBand(i)*2; //an dieser Stelle Frequenzen einspeisen
    
    fill(176,224,230);
    ellipse(_centerX, _centerY, radius*1.3, radius*1.3);
    
    //biggest circle
    fill(65,105,225);
    radius -= random(200,250);
    ellipse(_centerX, _centerY, radius/1.7, radius/1.7);
    
    fill(30,144,255);
    radius -= random(150,200);
    ellipse(_centerX, _centerY, radius/2, radius/2);
    
    fill(0,191,255);
    radius -= random(100,150);
    ellipse(_centerX, _centerY, radius/3, radius/3);
    
    //smallest
    fill(135,206,250);
    radius -= random(100);
    ellipse(_centerX, _centerY, radius/4, radius/4);
    }
} else if (colour < 2.0) { //rot
   background(51,0,0);
   for(int i = 0; i < fft.specSize(); i++){
    radius = fft.getBand(i); //an dieser Stelle Frequenzen einspeisen
    
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
    }
  }else { //grün
    background(25,51,0);
    for(int i = 0; i < fft.specSize(); i++){
    radius = fft.getBand(i); //an dieser Stelle Frequenzen einspeisen
    
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
} 
    
 class Button {
  float _x;
  float _y;
  float _width;
  float _height;
  String _label;
  
  public Button(float x, float y, float w, float h, String l) {
    _x=x; _y=y; _width=w; _height=h;
    _label = l;
  }
  
  public void drawButton() {
    stroke(0,0,0);
    fill(220);
    rect(_x,_y,_width,_height);
    fill(0);
    textAlign(CENTER);
    text(_label,_x+(_width/2.0),_y+(_height/2.0)+6);
  }
  
  public boolean CheckClick() {
    return mouseX > _x && mouseX < (_x + _width) && mouseY > _y && mouseY < (_y + _height);
  }
}
