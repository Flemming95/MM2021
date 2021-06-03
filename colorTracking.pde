import processing.video.*;

Capture video;

color trackColor;
//Threshhold for accepting what is considered the right color
float threshold = 80;

void setup() {
  size(640, 360);
  String[] cameras = Capture.list();
  printArray(cameras);
  video = new Capture(this, cameras[0]);
  video.start();
  trackRedColor = color(255,0,0);
  
  
}

void captureEvent(Capture video) {
  video.read();
}

void draw() {
   video.loadPixels();
   image(video, 0, 0);
   
   float avgX = 0;
   float avgY = 0;
   int count = 0;
  
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
      
      if (d < threshold) {
        avgX += x;
        avgY += y;
        count++;
      }
    }
  }
  
  if (count > 0) {
    avgX = avgX / count;
    avgY = avgY / count;
    
    fill(trackColor);
    strokeWeight(4.0);
    stroke(0);
    ellipse(avgX, avgY, 16, 16);
  }
      
      
}
