import processing.video.*;
import ddf.minim.*;
import ddf.minim.analysis.*;
import javax.swing.*;
import javax.swing.filechooser.FileNameExtensionFilter;
import controlP5.*;

//colortracking
Capture video;

//TODO Idee: Statt feste Farben zu verwenden, am Anfang des Programm-Ablaufs bzw im Menue den User
//selbst eine feste oder variable Anzahl an Farben definieren lassen. Somit koennte man
//das ganze besser auf User-Spezifische licht/kamera/farb-verhaeltnisse anpassen und generell
//die usabiity deutlich verbessern. 
color trackRedColor;
color trackFirstColor, trackSecondColor, trackThirdColor;
//To make variations based on the color values
float trackR1, trackR2, trackR3, trackG1, trackG2, trackG3, trackB1, trackB2, trackB3;
//Threshhold for accepting what is considered the right color
float threshold = 75;

//The rectangle in the center, for defining colors
int centerRectangleX, centerRectangleY;
int centerRectSize = 35;


//The middle of the video screen
int middle;
int centerX;
int centerY;

//To place rectangles with the available colors
int color1PreviewX, color2PreviewX, color3PreviewX;
int colorPreviewY;
int previewRectSize = 15; //25
//To count what color to select next
int colorCounter = 1;

int currentColor;

//Booleans to track if colors have been chosen
boolean colorChosen1 = false;
boolean colorChosen2 = false;
boolean colorChosen3 = false;

//Boolean to track if the color is currently present as well as that accepted color
boolean colorPresent = false;
color presentColor;

//audioplayer
Minim minim;
AudioPlayer player;
Button loadFileButton;
//Button pauseButton;
//Button playButton;
Button exitButton;
Button saveButton;
Button flowerButton;
Button sunButton;
Button pcircleButton;
Button rcircleButton;
boolean sun;
boolean flower;
boolean pcircle; 
boolean rcircle;
File selection; //file selected from filechooser
int sliderTicks; //slider background color
ControlP5 cp5; 
Textlabel songname;
int gap; //gap between window edge to visualisation field
int gapCam; // gap between window edge and cam image

int returnVal; //return value of the Filechooser
JFileChooser filechooser;
FileNameExtensionFilter extensionfilter;
FFT fft; //Fast Fourier Transform

//visualisation
float centerXRect; ////center X- coordinate of visualisation rect
float bottomYRect; // bottom Y-coord of visualisation rect,
float centerYRect; 
float x; //x-value where beams end
float y; //y-value where beams start
float radius; //length of beams, size of circles/ petals  
float coordX; //Koordinaten des gezeichneten Musters
float coordY;
float factor;
float noisyRadius; 
float rad;
float noiseArgument;


//recording visuals
boolean recording = false;

void setup(){
  size(1200, 700);
  
  //colorTracking
  String[] cameras = Capture.list();
  printArray(cameras);
  //TODO: Currently uses the first available camera. Maybe make this selectable in the menu, for people running multiple cameras? 
  video = new Capture(this,cameras[0]);
  video.start();
  //redColor is old, I'll leave it in for now
  trackRedColor = color(255,0,0);
  //Middle Pixel of the camera screen
  middle = (video.width/2) + (video.height/2) * video.width;
  //Center of the video frame
  
  //Coordinates for the color displaying rectangles
  color3PreviewX = width-40; 
  color2PreviewX = color3PreviewX-40; 
  color1PreviewX = color2PreviewX-40; 
  colorPreviewY = 25; 
 
  centerX = width/2; //coordinateX for center of the window 
  centerY = height/2; //coordinateY for center of the window 
  
  minim = new Minim(this);
  //https://github.com/anars/blank-audio/blob/master/1-minute-of-silence.mp3
  //initialising audioplayer
  player = minim.loadFile("silent.mp3",2048);
  
  //Buttons
  float buttonheight=20;
  float buttonlength=60;
  float bottomButtonY = height - 40; 
  loadFileButton = new Button(75,100, buttonlength + 90,buttonheight, "Choose an audiofile.");
  //pauseButton = new Button(170.0,150.0, buttonlength, buttonheight, "Pause");
  //playButton = new Button(90.0,150.0, buttonlength, buttonheight, "Play");
  sunButton = new Button(centerX, bottomButtonY, buttonlength, buttonheight, "Sun Art");
  flowerButton = new Button(centerX + 70, bottomButtonY, buttonlength + 10, buttonheight, "Flower Art");
  pcircleButton = new Button(centerX + 150, bottomButtonY, buttonlength * 2, buttonheight,"Pulsing Circle Art");
  rcircleButton = new Button(centerX + 280, bottomButtonY, buttonlength * 2, buttonheight, "Rotating Circle Art");
  saveButton = new Button(width - 140, bottomButtonY, buttonlength, buttonheight, "Save");  
  exitButton = new Button(width - 70  ,bottomButtonY,buttonlength, buttonheight,"Exit");
  
  //slider
  int minVol = 0; //minimum volume = 0
  int maxVol = 90; //max volume = 90
  int startVolume = 20;
  cp5 = new ControlP5(this);
  //tranparency of sliders background  
   sliderTicks=30;
   cp5.addSlider("Volume")
     .setPosition(60,190) //position of the slider
     .setWidth(150)      
     .setRange(minVol, maxVol) 
     .setValue(startVolume)
     .setNumberOfTickMarks(10)
     .setSliderMode(Slider.FLEXIBLE); 
  
  filechooser= new JFileChooser();
  extensionfilter=new FileNameExtensionFilter(".mp3 or .wav", "mp3", "wav");
  
  sun=true;
  flower=false;
  pcircle=false;
  rcircle=false;
  
  // create an FFT object that has a time-domain buffer 
  // the same size as players sample buffer
  // note that this needs to be a power of two 
  // and that it means the size of the spectrum will be half as large.
  fft = new FFT( player.bufferSize(), player.sampleRate() );
  
  frameRate(60);
  gap = 10;
  centerXRect = width * 2/3 - gap; //center X- coordinate of visualisation rect
  bottomYRect = height - 90; // bottom Y-coord of visualisation rect
  centerYRect =  (height - 100 +  gap) / 2 ; //center Y-coord of visualisation rect
  }
 
 void draw(){
  background(0);
  //Visualisation field
  //field width: 2/3 of window width, height: height - 110
  rect(width/3 - gap , gap, width - width/3 - gap, height - 100 );

  loadFileButton.drawButton();
  //pauseButton.drawButton();
  //playButton.drawButton();
  exitButton.drawButton();
  sunButton.drawButton();
  flowerButton.drawButton(); 
  pcircleButton.drawButton();
  rcircleButton.drawButton();
  
  //slider
  fill(sliderTicks);
  rect(55,190,200,20);
  sliderVol();
  
  showWebcam();

  fft.forward(player.mix);
  
   if(player.isPlaying()){
    clip(width/3 - gap, gap, width - width/3 -gap, height - 100);
     //start recording 
      if(sun==true){
        sunArt();
      }
     else if(flower==true){
        flowerArt();
      }
     else if(pcircle==true){
       pulsingCircleArt();
      }
     else if(rcircle==true){
      rotatingCircleArt();
      }
      loadFileButton.drawButton();
      //pauseButton.drawButton();
      //playButton.drawButton();
      sunButton.drawButton();
      flowerButton.drawButton();
      exitButton.drawButton();
      pcircleButton.drawButton();
      rcircleButton.drawButton();
      noClip(); //undo clipping , prevents buttons and cam from being removed
      //slider rectangle background  
      rect(55,190,200,20);
      showWebcam();
    
      saveButton.drawButton(); 
     
   }
      //stop recording if(!player.isPlaying())  
}
  
  void captureEvent(Capture video) {
    video.read();
  }
  
  void showWebcam(){
   video.loadPixels();
   gapCam = 30;
   int cameraBottomGap = 75;
   //shows image of (webcam, x-coordinate, y-coordinate, width , height of the image)  
   image(video, gapCam , centerY, centerX/2 , centerY - cameraBottomGap);
   //Updates current mouse position to use it for clicks
   //update(mouseX, mouseY);
  
   //Average color values, later used to find the center of the found colors 
   float avgX = 0;
   float avgY = 0;
   int count = 0;
   
  //Rectangle to mark the center. Need to make this transparent and preferably have it declared somewhere else or under a condition 
  strokeWeight(1.0);
  stroke(0);
  fill(0,0,0,0);
  rect(centerX/4 - centerRectSize/2 + gapCam , centerY + centerY/2 - centerRectSize/2 - cameraBottomGap/2 , centerRectSize, centerRectSize);
  //tint(255,5);
   
  //loop to walk through all pixels
  for (int x = 0; x < video.width; x++) {
    for (int y = 0; y < video.height; y++) {
      int loc = x + y * video.width;
      // Track current color
      this.currentColor = video.pixels[loc];
      float r1 = red(currentColor);
      //float r2 = red(trackRedColor);
      float g1 = green(currentColor);
      //float g2 = green(trackRedColor);
      float b1 = blue(currentColor);
      //float b2 = blue(trackRedColor);
      
      // Use euclidean distance to compare colors
      float d1 = dist(r1, g1, b1, trackR1, trackG1, trackB1);
      float d2 = dist(r1, g1, b1, trackR2, trackG2, trackB2);
      float d3 = dist(r1, g1, b1, trackR3, trackG3, trackB3);
      
      
      //If the calculated color is within the threshhold, we accept it.
      if (d1 < threshold) {
        colorPresent = true;
        presentColor = trackFirstColor;
        avgX += x;
        avgY += y;
        count++;
      }
      else if(d2 < threshold){
        colorPresent = true;
        presentColor = trackSecondColor;
        avgX += x;
        avgY += y;
        count++;
      }
      
      else if( d3 < threshold){
        colorPresent = true;
        presentColor = trackThirdColor;
        avgX += x;
        avgY += y;
        count++;
      }
      else{
        colorPresent = false;
      }
    }
    //If color (1-3) has been chosen, a rectangle displaying the color will be shown.
    if (colorChosen1){
      fill(trackFirstColor);
      rect(color1PreviewX, colorPreviewY, previewRectSize, previewRectSize);
    }
    if (colorChosen2){
      fill(trackSecondColor);
      rect(color2PreviewX, colorPreviewY, previewRectSize, previewRectSize);     
    }
    if (colorChosen3){
      fill(trackThirdColor);
      rect(color3PreviewX, colorPreviewY, previewRectSize, previewRectSize);
    }
  }
  if (count > 0) {
    avgX = avgX / count;
    avgY = avgY / count;
   
    fill(trackRedColor);
    strokeWeight(4.0);
    stroke(0);
    ellipse(avgX, avgY, 16, 16);
  }   
 }
  
  void mouseClicked(){
    if(loadFileButton.CheckClick()){
        //Filter WAV and MP3 file
        filechooser.setFileFilter(extensionfilter);
        filechooser.setAcceptAllFileFilterUsed(false);
        returnVal= filechooser.showOpenDialog(filechooser);
        if(returnVal==JFileChooser.APPROVE_OPTION){
          selection = filechooser.getSelectedFile();
          //loads audioFile selection in the player
          player.pause(); //previous file stops playing
          player = minim.loadFile(selection.getPath(),2048);
          player.play(); //plays the selected file
          songname = cp5.addTextlabel("songname")
                    .setText("Playing: " + selection.getName())
                    .setPosition(60,150)
                    .setColorValue(0xffffffff)
                    .setFont(createFont("Arial", 11))
                    ;
          player.isPlaying();
        }
     }
     /*if(pauseButton.CheckClick()){
       player.pause();
       isPlaying=false;
     }
     if(playButton.CheckClick()){
       if(selection!=null){ //if a file is selected from the user, play
         player.play(); 
         isPlaying=true;
       }
     } */
     else if(exitButton.CheckClick()){
       player.close();
        exit();
     }
     else if(flowerButton.CheckClick()){
       rcircle=false;
       pcircle= false;
       sun=false;
       flower=true;
     }
     else if(sunButton.CheckClick()){
       rcircle=false;
       pcircle= false;
       flower=false;
       sun=true;
     }
     else if(pcircleButton.CheckClick()){
       rcircle=false;
       sun=false;
       flower=false;
       pcircle=true;
     }
     else if(rcircleButton.CheckClick()){
       rcircle=true;
       sun=false;
       flower=false;
       pcircle=false;
     }
     else if(saveButton.CheckClick()){
     //open file dialog to save 
     //save as , save as random file
     }
     /*
    if (colorCounter > 3){ colorCounter = 1; }
    if (colorCounter==1){
    trackFirstColor = video.pixels[middle];
    trackR1 = 
    colorCounter += 1;
    colorChosen1=true;
    }
    else if (colorCounter==2){
    trackSecondColor = video.pixels[middle];
    colorCounter += 1;
    colorChosen2=true;
    }
    else if (colorCounter==3){
    trackThirdColor = video.pixels[middle];
    colorCounter = 1;
    colorChosen3=true;
    */
    else {
      trackNewColor();
    }
  
}

  void trackNewColor() {
    if (colorCounter > 3){ colorCounter = 1; }
    if (colorCounter==1){
      trackFirstColor = video.pixels[middle];
      trackR1 = red(trackFirstColor);
      trackG1 = green(trackFirstColor);
      trackB1 = blue(trackFirstColor);
      colorCounter += 1;
      colorChosen1=true;
    }
    else if (colorCounter==2){
      trackSecondColor = video.pixels[middle];
      trackR2 = red(trackSecondColor);
      trackG2 = green(trackSecondColor);
      trackB2 = blue(trackSecondColor);
      colorCounter += 1;
      colorChosen2=true;
    }
    else if (colorCounter==3){
      trackThirdColor = video.pixels[middle];
      trackR3 = red(trackThirdColor);
      trackG3 = green(trackThirdColor);
      trackB3 = blue(trackThirdColor);
      colorCounter = 1;
      colorChosen3=true;
    }
  }
    //To update the current mouse position. Can use this for UI clicks I guess
  void update(int x, int y){
  }
  
  //Not used at the moment. 
  boolean overCenterRect(int x, int y, int width, int height) {
  if (mouseX >= x && mouseX <= x+width && 
      mouseY >= y && mouseY <= y+height) {
        return true;
      } else {
        return false;
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
  
  //draws a flower that reacts to frequency
  void flowerArt(){
   float colour = presentColor;
   for(int i = 0; i < fft.specSize(); i++){
      radius=map(fft.getBand(i),0,1,50,200); //an dieser Stelle Frequenzen einspeisen
   } 
  for (int j = 0; j <= 5; j++) {
    beginShape();
    /*
    if (colour < 1) {
      fill(random(100), random(100,200), random(200,255),random(100,255));
    } else if (colour < 2) {
      fill(random(150,255), random(150), random(150), random(100,255));
    } else {
      fill(random(50,150), random(150,255), random(50), random(100,255));
    }
    */
    fill(presentColor);
    rect(width/3 - gap , gap, width - width/3 - gap, height - 100 );
   
    
    noiseArgument = random(10);
    
    for(float angle=0;angle<=360;angle+=1){
      noiseArgument += 0.15; //Eingabe in die noise Funktion muss inkrementiert werden
      factor = 35 * customNoise(noiseArgument);
      noisyRadius = radius + factor; 
      
      rad = radians(angle);
      coordX = centerXRect + (noisyRadius * cos(rad)); 
      coordY = centerYRect + (noisyRadius * sin(rad));
      
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
  
  
  //draws a sun with beams, reacts to frequency
  void sunArt(){
    float colour = currentColor; //hier Farben einspeisen
    hint(ENABLE_STROKE_PERSPECTIVE) ;
    if (colour < 1) {
      fill(255,153,51);
      rect(width/3 - gap , gap, width - width/3 - gap, height - 100 );
    }
    else if (colour < 2) {
      fill(102,204,0);
      rect(width/3 - gap , gap, width - width/3 - gap, height - 100  );
    }
    else if (colour < 3) {
      fill(102,178,255);
      rect(width/3 - gap , gap, width - width/3 - gap, height - 100  );
    }
    else {
      fill(255,153,204);
      rect(width/3 - gap , gap, width - width/3 - gap, height - 100 );
    }
    
    for(int i = 0; i < fft.specSize(); i +=5){
      for (float ang = 0; ang <= 360; ang += 5) { 
        radius = fft.getBand(i)*2; //Frequenzen bestimmen Länge der Strahlen
        float rad = radians(ang);
        x = centerXRect  + (radius * cos(rad));
        y = bottomYRect + (radius * sin(rad));
        
        strokeWeight(1);
        stroke(color(255));
        line(centerXRect, bottomYRect , x, y);
       }
      //circle sun
      noStroke();
      fill(250,40);
      ellipse(centerXRect, bottomYRect, 100, 100);
    
      //transparent circles sun beam
      fill(255,30);
      ellipse(centerXRect, bottomYRect, radius*2 , radius*2);
     
      }
    
  }
  
  //draws circles that reacts to freq
  void pulsingCircleArt(){
    noStroke();
    
    //strokeWeight(0.5);
    float colour = trackFirstColor; //hier Farben einspeisen
      if (colour < 1.0) { //blau
      fill(trackFirstColor);
      rect(width/3 - gap, gap, width - width/3 - gap, height - 100);
      
      for(int i = 0; i < fft.specSize(); i++){
        radius = fft.getBand(i)*1.5; //an dieser Stelle Frequenzen einspeisen
        
        fill(trackFirstColor,60);
        ellipse(centerXRect, centerYRect, radius*1.3, radius*1.3);
    
        //biggest circle
        /*
        fill(65,105,225,60);
        radius -= random(150,250);
        ellipse(centerXRect, centerYRect, radius/1.7, radius/1.7);
    
        fill(0,191,255,40);
        radius -= random(100,150);
        ellipse(centerXRect, centerYRect, radius/3, radius/3);
        
        //smallest
        fill(135,206,250,30);
        radius -= random(100);
        ellipse(centerXRect, centerYRect, radius/4, radius/4);
        */
        //biggest circle
        
        fill(makeColorVariationHalfTransparent(trackFirstColor));
        radius -= random(150,250);
        ellipse(centerXRect, centerYRect, radius/1.7, radius/1.7);
    
        fill(makeColorVariationSaturated(trackFirstColor));
        radius -= random(100,150);
        ellipse(centerXRect, centerYRect, radius/3, radius/3);
        
        //smallest
        fill(135,206,250,30);
        radius -= random(100);
        ellipse(centerXRect, centerYRect, radius/4, radius/4);
      }
     }
    /*}else if(colour < 2.0) { //rot
     background(51,0,0);
     for(int i = 0; i < fft.specSize(); i++){
      radius = fft.getBand(i)*2; //an dieser Stelle Frequenzen einspeisen
    
      fill(250,128,114,60);
      ellipse(centerXRect, centerYRect, radius*1.3, radius*1.3);
    
      fill(139,0,0,60);
      radius -= random(150,250);
      ellipse(centerXRect, centerYRect, radius/1.7, radius/1.7);
     
      fill(128,0,0,40);
      radius -= random(100,150);
      ellipse(centerXRect, centerYRect, radius/3, radius/3);
      
      fill(255,69,0,30);
      radius -= random(100);
      ellipse(centerXRect, centerYRect, radius/4, radius/4);
      }
    }  else { //grün
      background(0,30,0);
      for(int i = 0; i < fft.specSize(); i++){
       radius = fft.getBand(i)*2; //an dieser Stelle Frequenzen einspeisen
    
       fill(154, 205, 50,60); //0,128,0,60);
       ellipse(centerXRect, centerYRect, radius*1.3, radius*1.3);
       
       fill(65, 105, 0,60);
       radius -= random(150,250);
       ellipse(centerXRect, centerYRect, radius/1.7, radius/1.7);
       
       fill(154,205,50,40);
       radius -= random(100,150);
       ellipse(centerXRect, centerYRect, radius/4, radius/4);
    
       fill(144,238,144,30);
       radius -= random(100);
       ellipse(centerXRect, centerYRect, radius/4, radius/4);
       }
    }*/
  }
  
 void rotatingCircleArt(){
  fill(0);
  rect(width/3 - gap, gap, width - width/3 - gap,  height - 100);
  
  int minSize = 130; //circle size
  //prevents other objects from being translated or rotated
   pushMatrix();
   translate(centerXRect, centerYRect);
   rotate(radians(map(player.position()*10, 0, player.length(), 0, 360)));
   for (int i=0;i<fft.specSize();i+=4){     
     stroke(color(204,0,0)); //colorinput here
     strokeWeight(1);
     //i=lines, 0= i's lower bound current range, fft.specSize()=i's upper bound current range
     //0=i's lower target range, 2*PI = i's upper target range
     float r = map(i, 0, fft.specSize(), 0, 2 * PI);
     //frequency 
     float s = abs(fft.getBand(i))*10;
     ellipse(0,0, s/5 + minSize, s/5 + minSize);
     line(sin(r) * (minSize), cos(r) * (minSize), sin(r) * (s + minSize), cos(r) * (s + minSize));
     
    }
    popMatrix();
 }
 
 color makeColorVariationSaturated(color c){
   float redValue = red(c);
   float greenValue = green(c);
   float blueValue = blue(c);
   color saturatedColor;
   
   if (redValue == max(redValue, greenValue, blueValue)){
     saturatedColor = color(255, 0, 0);
   }
   else if(greenValue == max(redValue, greenValue, blueValue)){
     saturatedColor = color(0, 255, 0);
   }
   else {
     saturatedColor = color(0, 0, 255);
   }
   return saturatedColor;
 }
 
 color makeColorVariationHalfTransparent(color c){
   return color(red(c), green(c), blue(c), 120);
 }
 
 color makeColorRandomAroundMain(color c){
   float redValue = red(c);
   float greenValue = green(c);
   float blueValue = blue(c);
   color mainColor;
   
   if (redValue == max(redValue, greenValue, blueValue)){
     mainColor = color(redValue, greenValue-random(15), blueValue-random(15));
   }
   else if(greenValue == max(redValue, greenValue, blueValue)){
     mainColor = color(redValue-random(22), greenValue, blueValue-random(22));
   }
   else {
     mainColor = color(redValue-random(22), greenValue-random(22), blueValue);
   }
   return mainColor;
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
