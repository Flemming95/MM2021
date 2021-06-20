import processing.video.*;

Capture video;

//TODO Idee: Statt feste Farben zu verwenden, am Anfang des Programm-Ablaufs bzw im Menue den User
//selbst eine feste oder variable Anzahl an Farben definieren lassen. Somit koennte man
//das ganze besser auf User-Spezifische licht/kamera/farb-verhaeltnisse anpassen und generell
//die usabiity deutlich verbessern. 
color trackRedColor;
color trackFirstColor, trackSecondColor, trackThirdColor;
//Threshhold for accepting what is considered the right color
float threshold = 80;

//The rectangle in the center, for defining colors
int centerRectangleX, centerRectangleY;
int centerRectSize = 75;


//The middle of the video screen
int middle;
int centerX;
int centerY;

//To place rectangles with the available colors
int color1PreviewX, color2PreviewX, color3PreviewX;
int colorPreviewY;
int previewRectSize = 25;
//To count what color to select next
int colorCounter = 1;

//Booleans to track if colors have been chosen
boolean colorChosen1 = false;
boolean colorChosen2 = false;
boolean colorChosen3 = false;





void setup() {
  size(640, 360);
  String[] cameras = Capture.list();
  printArray(cameras);
  //TODO: Currently uses the first available camera. Maybe make this selectable in the menu, for people running multiple cameras? 
  video = new Capture(this, cameras[0]);
  video.start();
  //redColor is old, I'll leave it in for now
  trackRedColor = color(255,0,0);
  //Middle Pixel of the camera screen
  middle = (video.width/2) + (video.height/2) * video.width;
  //Center of the video frame
  centerX = width/2;
  centerY = height/2;
  //Coordinates for the color displaying rectangles
  color3PreviewX = width-25;
  color2PreviewX = color3PreviewX-25;
  color1PreviewX = color2PreviewX-25;
  colorPreviewY = 25;
  
}

void captureEvent(Capture video) {
  video.read();
}

void draw() {
   video.loadPixels();
   image(video, 0, 0);
   //Updates current mouse position to use it for clicks
   update(mouseX, mouseY);
   
   //Average color values, later used to find the center of the found colors 
   float avgX = 0;
   float avgY = 0;
   int count = 0;
   
  //Rectangle to mark the center. Need to make this transparent and preferably have it declared somewhere else or under a condition 
  strokeWeight(4.0);
  stroke(0);
  rect(centerX, centerY, centerRectSize, centerRectSize);
  //tint(255,5);
   
  
  // Loop to walk through all pixels
  for (int x = 0; x < video.width; x++) {
    for (int y = 0; y < video.height; y++) {
      int loc = x + y * video.width;
      // Track current color
      color currentColor = video.pixels[loc];
      float r1 = red(currentColor);
      float r2 = red(trackRedColor);
      float g1 = green(currentColor);
      float g2 = green(trackRedColor);
      float b1 = blue(currentColor);
      float b2 = blue(trackRedColor);
      
      // Use euclidean distance to compare colors
      float d = dist(r1, g1, b1, r2, g2, b2);
      
      //If the calculated color is within the threshhold, we accept it.
      if (d < threshold) {
        avgX += x;
        avgY += y;
        count++;
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

       
/**
* Default reaction on mouse clicks. Based on the current colorCounter, colors 1-3 will be chosen. 
*/
void mousePressed() {
  if (colorCounter > 3){ colorCounter = 1; }
  if (colorCounter==1){
    trackFirstColor = video.pixels[middle];
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
