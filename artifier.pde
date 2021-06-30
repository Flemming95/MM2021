import processing.video.*;
import ddf.minim.*;
import ddf.minim.analysis.*;
import javax.swing.*;
import javax.swing.filechooser.FileNameExtensionFilter;
import controlP5.*;
import com.hamoid.*;

//main menue
int xspacing = 20;   // How far apart should each horizontal location be spaced
int w;              // Width of entire wave
float theta = 0.0;  // Start angle at 0
float amplitude = 75.0;  // Height of wave
float period = 500.0;  // How many pixels before the wave repeats
float dx;  // Value for incrementing X, a function of period and xspacing
float[] yvalues;  // Using an array to store height values for the wave
Button startButton;
Button quitButton;
boolean starting=false;
Textlabel appname;

//tutorial
boolean tutorial=false;
int savedTime; //
int totalTime = 20000; // 200000 ms = 20 seconds
PImage tuto1; 
PImage tuto2;

//colortracking
Capture video;

//TODO Idee: Statt feste Farben zu verwenden, am Anfang des Programm-Ablaufs bzw im Menue den User
//selbst eine feste oder variable Anzahl an Farben definieren lassen. Somit koennte man
//das ganze besser auf User-Spezifische licht/kamera/farb-verhaeltnisse anpassen und generell
//die usabiity deutlich verbessern. 
color trackRedColor;
color trackFirstColor, trackSecondColor, trackThirdColor;
color fillBackground;
//To make variations based on the color values
float trackR1, trackR2, trackR3, trackG1, trackG2, trackG3, trackB1, trackB2, trackB3;
//Threshhold for accepting what is considered the right color
float threshold = 80;

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

color currentColor;

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
Button tutorialButton;
//Button pauseButton;
//Button playButton;
Button exitButton;
Button saveButton;
Button cityButton;
Button sunButton;
Button pcircleButton;
Button rcircleButton;
Button backgrButton;
boolean sun;
boolean city;
boolean pcircle; 
boolean rcircle;
boolean buttonSetup;
boolean backgr;
File selection; //file selected from filechooser
Slider vol;
int sliderTicks; //slider background color
ControlP5 cp5; 
Textlabel songname;
int gap=10; //gap between window edge to visualisation field
int gapCam=30; // gap between window edge and cam image

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
VideoExport videoExport;
boolean recording = false;
PGraphics pg;

void setup() {
  size(1200, 700);

  //main menue art
  w = width+20;
  dx = (TWO_PI / period) * xspacing;
  yvalues = new float[w/xspacing];

  //colorTracking
  String[] cameras = Capture.list();
  printArray(cameras);
  //TODO: Currently uses the first available camera. Maybe make this selectable in the menu, for people running multiple cameras? 
  video = new Capture(this, cameras[0]);
  video.start();
  //redColor is old, I'll leave it in for now
  trackRedColor = color(255, 0, 0);
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
  player = minim.loadFile("silent.mp3", 2048);



  //Buttons
  float buttonheight=20;
  float buttonlength=60;
  float bottomButtonY = height - 40; 
  startButton= new Button(centerX-300, centerY+200, buttonlength, buttonheight, "Start");
  quitButton=  new Button(centerX-300, centerY+250, buttonlength, buttonheight, "Quit");
  loadFileButton = new Button(75, 100, buttonlength + 90, buttonheight, "Choose an audiofile.");
  tutorialButton = new Button(gapCam, bottomButtonY, buttonlength, buttonheight, "Tutorial");   
  //pauseButton = new Button(170.0,150.0, buttonlength, buttonheight, "Pause");
  //playButton = new Button(90.0,150.0, buttonlength, buttonheight, "Play");
  sunButton = new Button(centerX, bottomButtonY, buttonlength, buttonheight, "[S]un Art");
  cityButton = new Button(centerX + 70, bottomButtonY, buttonlength + 10, buttonheight, "[C]ity Art");
  pcircleButton = new Button(centerX + 150, bottomButtonY, buttonlength * 2, buttonheight, "[P]ulsing Circle Art");
  rcircleButton = new Button(centerX + 280, bottomButtonY, buttonlength * 2, buttonheight, "[R]otating Circle Art");
  saveButton = new Button(width - 140, bottomButtonY, buttonlength, buttonheight, "Save");  
  exitButton = new Button(width - 70, bottomButtonY, buttonlength, buttonheight, "Exit[X]");
  backgrButton = new Button( centerX - 150, bottomButtonY, buttonlength*2, buttonheight, "[B]ackground");

  cp5 = new ControlP5(this);
  //slider
  int minVol = 0; //minimum volume = 0
  int maxVol = 90; //max volume = 90
  int startVolume = 20;
  //tranparency of sliders background 
  sliderTicks=30;
  vol=cp5.addSlider("Volume")
    .setPosition(60, 190) //position of the slider
    .setWidth(150)      
    .setRange(minVol, maxVol) 
    .setValue(startVolume)
    .setNumberOfTickMarks(10)
    .setSliderMode(Slider.FLEXIBLE); 

  filechooser= new JFileChooser();
  extensionfilter=new FileNameExtensionFilter(".mp3 or .wav", "mp3", "wav");

  buttonSetup = false;
  sun=true;
  city=false;
  pcircle=false;
  rcircle=false;
  backgr=false;

  // create an FFT object that has a time-domain buffer 
  // the same size as players sample buffer
  // note that this needs to be a power of two 
  // and that it means the size of the spectrum will be half as large.
  fft = new FFT( player.bufferSize(), player.sampleRate() );

  frameRate(30);
  centerXRect = width * 2/3 - gap; //center X- coordinate of visualisation rect
  bottomYRect = height - 90; // bottom Y-coord of visualisation rect
  centerYRect =  (height - 100 +  gap) / 2 ; //center Y-coord of visualisation rect

  videoExport = new VideoExport(this);
  videoExport.startMovie();

  appname=cp5.addTextlabel("appname") //adds label "Artifier" to main menue
    .setText("Artifier")
    .setPosition(centerX+100, 0)
    .setColorValue(0xffffffff)
    .setFont(createFont("Times New Roman", 90));

  tuto1= loadImage("tutorial01.png");
  tuto2= loadImage("tutorial02.png");
  savedTime=millis();
}


void draw() {

  //if start is clicked, show ...
  if (starting) {
    currentColor = video.pixels[middle];
    if (!buttonSetup) {
      background(0);
      loadFileButton.drawButton();
      tutorialButton.drawButton();
      exitButton.drawButton();
      sunButton.drawButton();
      cityButton.drawButton(); 
      pcircleButton.drawButton();
      rcircleButton.drawButton();
      backgrButton.drawButton();
      buttonSetup = true;
    }
    //TESTTEST
    if (backgr) {
      fillBackground = color(video.pixels[middle]);
      backgr=false;
    }
    //changing "Artifier" position and fontsize
    appname.setPosition(60, 20);
    appname.setFont(createFont("Times New Roman", 60));
    vol.show(); //shows slider 

    //slider
    fill(sliderTicks);
    rect(55, 190, 200, 20);
    sliderVol();

    showWebcam();
    if (tutorial) {
      playTutorial();
    }

    fft.forward(player.mix);

    if (player.isPlaying()) {

      clip(width/3 - gap, gap, width - width/3 -gap, height - 100);
      videoExport.setAudioFileName(selection.getPath());
      //videoExport.saveFrame();
      //start recording 

      if (sun) {
        sunArt();
      } else if (city) {
        cityArt();
      } else if (pcircle) {
        pulsingCircleArt();
      } else if (rcircle) {
        rotatingCircleArt();
      }

      noClip(); //undo clipping , prevents buttons and cam from being removed
      //slider rectangle background  
      rect(55, 190, 200, 20);
      showWebcam();

      saveButton.drawButton();
    }
    if (!player.isPlaying())
      videoExport.endMovie();
    //stop recording
  } else {
    background(0);
    vol.hide(); //hide slider
    mainArt(); 
    startButton.drawButton(); 
    quitButton.drawButton();
  }
}

void captureEvent(Capture video) {
  video.read();
}

void showWebcam() {
  video.loadPixels();
  int cameraBottomGap = 75;
  //shows image of (webcam, x-coordinate, y-coordinate, width , height of the image)  
  image(video, gapCam, centerY, centerX/2, centerY - cameraBottomGap);
  //Updates current mouse position to use it for clicks
  //update(mouseX, mouseY);

  //Rectangle to mark the center. Need to make this transparent and preferably have it declared somewhere else or under a condition 
  strokeWeight(1.0);
  stroke(0);
  fill(0, 0, 0, 0);
  rect(centerX/4 - centerRectSize/2 + gapCam, centerY + centerY/2 - centerRectSize/2 - cameraBottomGap/2, centerRectSize, centerRectSize);
  //tint(255,5);





  /* NOT IMPLEMENTED: This could be used to track the currently shown color
   
   //Average color values, later used to find the center of the found colors 
   float avgX = 0;
   float avgY = 0;
   int count = 0;
   
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
   } else if (d2 < threshold) {
   colorPresent = true;
   presentColor = trackSecondColor;
   avgX += x;
   avgY += y;
   count++;
   } else if ( d3 < threshold) {
   colorPresent = true;
   presentColor = trackThirdColor;
   avgX += x;
   avgY += y;
   count++;
   } else {
   colorPresent = false;
   }
   }
   //If color (1-3) has been chosen, a rectangle displaying the color will be shown.
   if (colorChosen1) {
   fill(trackFirstColor);
   rect(color1PreviewX, colorPreviewY, previewRectSize, previewRectSize);
   }
   if (colorChosen2) {
   fill(trackSecondColor);
   rect(color2PreviewX, colorPreviewY, previewRectSize, previewRectSize);
   }
   if (colorChosen3) {
   fill(trackThirdColor);
   rect(color3PreviewX, colorPreviewY, previewRectSize, previewRectSize);
   }
   }
   //Circle thing for color tracking
   if (count > 0) {
   avgX = avgX / count;
   avgY = avgY / count;
   
   fill(trackRedColor);
   strokeWeight(4.0);
   stroke(0);
   ellipse(avgX, avgY, 16, 16);
   }
   
   */
}

void keyPressed() {
  if (key == 'S' || key== 's') {
    //sun
  } else if (key == 'P' ||  key== 'p') {
    //pulsing circle
  } else if (key == 'R' || key=='r') {
    //rotating circle
  } else if (key =='X' || key == 'x') {
    //exit
  } else if (key =='B' || key == 'b') {
    //background
  } else if (key =='C' || key == 'c') {
    //city
  }
}

void mouseClicked() {
  if (startButton.CheckClick()) {
    starting=true;
  } else if (tutorialButton.CheckClick()) {
    tutorial=true;
  } else if (loadFileButton.CheckClick()) {
    //Filter WAV and MP3 file
    filechooser.setFileFilter(extensionfilter);
    filechooser.setAcceptAllFileFilterUsed(false);
    returnVal= filechooser.showOpenDialog(filechooser);
    if (returnVal==JFileChooser.APPROVE_OPTION) {
      selection = filechooser.getSelectedFile();
      //loads audioFile selection in the player
      player.pause(); //previous file stops playing
      player = minim.loadFile(selection.getPath(), 2048);
      player.play(); //plays the selected file
      background(0);
      buttonSetup = false;
      songname = cp5.addTextlabel("songname")
        .setText("Playing:"+System.lineSeparator()+ selection.getName())
        .setPosition(60, 150)
        .setColorValue(0xffffffff)
        .setFont(createFont("Arial", 12))
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
  else if (exitButton.CheckClick() || quitButton.CheckClick()) {
    player.close();
    exit();
  } else if (cityButton.CheckClick()) {
    rcircle=false;
    pcircle= false;
    sun=false;
    city=true;
  } else if (sunButton.CheckClick()) {
    rcircle=false;
    pcircle= false;
    city=false;
    sun=true;
  } else if (pcircleButton.CheckClick()) {
    rcircle=false;
    sun=false;
    city=false;
    pcircle=true;
  } else if (rcircleButton.CheckClick()) {
    rcircle=true;
    sun=false;
    city=false;
    pcircle=false;
  } else if (saveButton.CheckClick()) {
    //open file dialog to save 
    //save as , save as random file
  } else if (backgrButton.CheckClick()) {
    backgr=true;
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
  if (colorCounter > 3) { 
    colorCounter = 1;
  }
  if (colorCounter==1) {
    trackFirstColor = video.pixels[middle];
    trackR1 = red(trackFirstColor);
    trackG1 = green(trackFirstColor);
    trackB1 = blue(trackFirstColor);
    colorCounter += 1;
    colorChosen1=true;
  } else if (colorCounter==2) {
    trackSecondColor = video.pixels[middle];
    trackR2 = red(trackSecondColor);
    trackG2 = green(trackSecondColor);
    trackB2 = blue(trackSecondColor);
    colorCounter += 1;
    colorChosen2=true;
  } else if (colorCounter==3) {
    trackThirdColor = video.pixels[middle];
    trackR3 = red(trackThirdColor);
    trackG3 = green(trackThirdColor);
    trackB3 = blue(trackThirdColor);
    colorCounter = 1;
    colorChosen3=true;
  }
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
void sliderVol() {
  //gets the current value of the slider, range 0 to 100
  float volume=cp5.getController("Volume").getValue();
  //sets decibel(range 14(loudest) to -80(quietest)) for the volume
  player.setGain(volume-50);
  if (volume==0) {
    player.mute();
  } else 
  player.unmute();
}



//background art for the main menue source: https://processing.org/examples/sinewave.html
void mainArt() {
  // Increment theta (try different values for 'angular velocity' here
  theta += 0.02;

  // For every x value, calculate a y value with sine function
  float x = theta;
  for (int i = 0; i < yvalues.length; i++) {
    yvalues[i] = sin(x)*amplitude;
    x+=dx;
  }
  noStroke();
  fill(255);
  // A simple way to draw the wave with an ellipse at each location
  for (int xval = 0; xval < yvalues.length; xval++) {
    ellipse(xval*xspacing, height/2+yvalues[xval], 16, 16);
  }
}

void playTutorial() {
  int passedTime = millis() - savedTime;
  tuto1.resize(width - width/3 - gap, height - 110);
  tuto2.resize(width - width/3 - gap, height - 110);
  image(tuto1, width/3-gap, gap);

  if (passedTime >= totalTime) { // after 20s, show tutorial02.png
    image(tuto2, width/3-gap, gap);
  }
}
/*void flowerArt() {
 theta += 0.02;
 // For every x value, calculate a y value with sine function
 int minSize = 55;
 float x = theta;
 for (int i=0; i<fft.specSize(); i+=4) {     
 stroke(currentColor); //colorinput here
 strokeWeight(2);
 yvalues[i] = sin(x)*amplitude;
 x+=dx;
 }
 
 noStroke();
 // A simple way to draw the wave with an ellipse at each location
 for (int xval = 0; xval < yvalues.length; xval++) {
 ellipse(xval*xspacing, height/2+yvalues[xval], 16, 16);
 }
 }
 
 
 float customNoise(float value) { 
 float retValue = pow(sin(value), 3); 
 return retValue;
 }
 */
void cityArt() {
  fill(fillBackground);
  rect(width/3 - gap, gap, width-width/3-gap, height - 100);
  pushMatrix();
  stroke(255);
  translate(width/3 - gap, 0);
  for (int i=0; i<fft.specSize(); i++) {
    float widthI = map(i, 0, fft.specSize(), 0, 200);  
    float s = abs(fft.getBand(i));
    fill(currentColor);
    rect(widthI*10, gap, 10, bottomYRect -gap -s*7);

    fill(fillBackground);
    ellipse(width/2, centerYRect - 150, 20*s/10, 20*s/10);
  }
  popMatrix();
}

//draws a sun with beams, reacts to frequency
void sunArt() {

  hint(ENABLE_STROKE_PERSPECTIVE) ;

  fill(fillBackground);
  rect(width/3 - gap, gap, width-width/3-gap, height - 100);

  for (int i = 0; i < fft.specSize(); i +=5) {
    for (float ang = 0; ang <= 360; ang += 5) { 
      radius = fft.getBand(i)*3.5; //Frequenzen bestimmen Länge der Strahlen
      float rad = radians(ang);
      x = centerXRect  + (radius * cos(rad));
      y = bottomYRect + (radius * sin(rad));

      strokeWeight(1);
      stroke(currentColor);
      line(centerXRect, bottomYRect, x, y);
    }
    //circle sun
    noStroke();
    fill(makeColorVariationDarker(currentColor));
    ellipse(centerXRect, bottomYRect, 100, 100);

    //transparent circles sun beam
    fill(makeColorVariationMild(currentColor));
    ellipse(centerXRect, bottomYRect, radius*2, radius*2);
  }
}

//draws circles that reacts to freq
void pulsingCircleArt() {
  noStroke();

  //strokeWeight(0.5);
  fill(fillBackground);
  rect(width/3 - gap, gap, width - width/3 - gap, height - 100);

  for (int i = 0; i < fft.specSize(); i +=2 ) {
    radius = fft.getBand(i)*1.5; //an dieser Stelle Frequenzen HÖR AUF EINSPEISEN ZU SCHREIBE MAN EY FUCK

    fill(makeColorChangeAlpha(currentColor, 0.1), 15);
    ellipse(centerXRect, centerYRect, radius*1.3, radius*1.3);

    //biggest circle
    fill(makeColorInvert(makeColorChangeAlpha(currentColor, 0.15)), 15);
    ellipse(centerXRect, centerYRect, radius/1.7, radius/1.7);

    fill(makeColorChangeAlpha(currentColor, 0.85), 35);
    ;
    ellipse(centerXRect, centerYRect, radius/3, radius/3);

    //smallest
    fill(makeColorChangeAlpha(currentColor, 0.95), 70);
    ellipse(centerXRect, centerYRect, radius/4, radius/4);

    //biggest circle
    //fill(makeColorChangeAlpha(currentColor, 0.15), 15);
    //ellipse(centerXRect, centerYRect, radius/1.7, radius/1.7);

    //fill(makeColorVariationSaturated(currentColor),50);
    //ellipse(centerXRect, centerYRect, radius/3, radius/3);

    //smallest
    fill(makeColorInvert(makeColorChangeAlpha(currentColor, 0.3)), 33);
    ellipse(centerXRect, centerYRect, radius/4, radius/4);
  }
}


void rotatingCircleArt() {
  fill(fillBackground);
  rect(width/3 - gap, gap, width - width/3 - gap, height - 100);

  int minSize = 130; //circle size
  //prevents other objects from being translated or rotated
  pushMatrix();
  translate(centerXRect, centerYRect);
  rotate(radians(map(player.position()*10, 0, player.length(), 0, 360)));
  for (int i=0; i<fft.specSize(); i+=4) {     
    stroke(currentColor); //colorinput here
    strokeWeight(2);
    //i=lines, 0= i's lower bound current range, fft.specSize()=i's upper bound current range
    //0=i's lower target range, 2*PI = i's upper target range
    float r = map(i, 0, fft.specSize(), 0, 2 * PI);
    //frequency 
    float s = abs(fft.getBand(i))*10;
    ellipse(0, 0, s/5 + minSize, s/5 + minSize);
    line(sin(r) * (minSize), cos(r) * (minSize), sin(r) * (s + minSize), cos(r) * (s + minSize));
  }
  popMatrix();
}

color makeColorVariationSaturated(color c) {
  float redValue = red(c);
  float greenValue = green(c);
  float blueValue = blue(c);
  color saturatedColor;

  if (redValue == max(redValue, greenValue, blueValue)) {
    saturatedColor = color(195, 0, 0, 125);
  } else if (greenValue == max(redValue, greenValue, blueValue)) {
    saturatedColor = color(0, 195, 0, 125);
  } else {
    saturatedColor = color(0, 0, 195, 125);
  }
  return saturatedColor;
}

color makeColorInvert(color c) {
  return c/2;
}

color makeColorVariationMild(color c) {
  color mildColor = color(red(c), green(c), blue(c), 30);
  return mildColor;
}

color makeColorVariationDarker(color c) {
  float alpha = 0.75;
  float redValue = red(c)*alpha;
  float greenValue = green(c)*alpha;
  float blueValue = blue(c)*alpha;
  color darkColor = color(redValue, greenValue, blueValue, 195);


  return darkColor;
}

color makeColorVariationHalfTransparent(color c) {
  return color(red(c), green(c), blue(c), 120);
}

color makeColorRandomAroundMain(color c) {
  float redValue = red(c);
  float greenValue = green(c);
  float blueValue = blue(c);
  color mainColor;

  if (redValue == max(redValue, greenValue, blueValue)) {
    mainColor = color(redValue, greenValue-random(15), blueValue-random(15));
  } else if (greenValue == max(redValue, greenValue, blueValue)) {
    mainColor = color(redValue-random(22), greenValue, blueValue-random(22));
  } else {
    mainColor = color(redValue-random(22), greenValue-random(22), blueValue);
  }
  return mainColor;
}

color makeColorChangeAlpha(color c, float alpha) {
  color newColor = color(red(c)*alpha, green(c)*alpha, blue(c)*alpha);
  return newColor;
}

class Button {
  float _x;
  float _y;
  float _width;
  float _height;
  String _label;

  public Button(float x, float y, float w, float h, String l) {
    _x=x; 
    _y=y; 
    _width=w; 
    _height=h;
    _label = l;
  }

  public void drawButton() {
    stroke(0);
    strokeWeight(0.1);
    fill(220);
    rect(_x, _y, _width, _height);
    fill(0);
    textAlign(CENTER);
    text(_label, _x+(_width/2.0), _y+(_height/2.0)+6);
  }

  public boolean CheckClick() {
    return mouseX > _x && mouseX < (_x + _width) && mouseY > _y && mouseY < (_y + _height);
  }
}
