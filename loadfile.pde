import ddf.minim.*;
import ddf.minim.analysis.*;
import javax.swing.*;
import javax.swing.filechooser.FileNameExtensionFilter;

Minim minim;
AudioPlayer player;
Button loadFileButton;
Button pauseButton;
Button playButton;
File selection;
File audiofile;
int returnVal;
JFileChooser filechooser= new JFileChooser();
String extensionDescription;
String[] extension;
FileNameExtensionFilter extensionfilter;
FFT fft;
float freq;

void setup(){
  size(300, 300,P3D);
  minim = new Minim(this);
  //https://github.com/anars/blank-audio/blob/master/1-minute-of-silence.mp3
  player = minim.loadFile("silent.mp3",2048);
  loadFileButton = new Button(100.0,100.0,110.0,20.0, "Choose an audiofile.");
  pauseButton = new Button(170.0,150.0,20.0,20.0, "Pause");
  playButton = new Button(100.0,150.0,20.0,20.0, "Play");
  extensionfilter=new FileNameExtensionFilter(".mp3 or .wav", "mp3", "wav");
 
  // create an FFT object that has a time-domain buffer 
  // the same size as jingle's sample buffer
  // note that this needs to be a power of two 
  // and that it means the size of the spectrum will be half as large.
  fft = new FFT( player.bufferSize(), player.sampleRate() );
  
  }
 
 void draw(){
  background(0);
  stroke(255);
  
  // perform a forward FFT on the samples in player's mix buffer,
  // which contains the mix of both the left and right channels of the file
  /*fft.forward( player.mix );
  //specSize: size of the spectrum created by fft
  for(int i = 0; i < fft.specSize(); i++){
  line( i, height, i, height - fft.getBand(i)*8 );
  }
  */
  loadFileButton.drawButton(); //<>//
  pauseButton.drawButton();
  playButton.drawButton();
}
 
  void mouseClicked(){
    if(loadFileButton.CheckClick()){
        //Filter WAV and MP3 file
        filechooser.setFileFilter(extensionfilter);
          returnVal= filechooser.showOpenDialog(new JComponent(){
        });
        if(returnVal==JFileChooser.APPROVE_OPTION){
          selection = filechooser.getSelectedFile();
          //lädt AudioFile selection in den Player ein
          player.pause();
          player = minim.loadFile(selection.getPath(),2048);
          //player.setVolume(20.0);
          player.play();
          frequencyfilter();
        }
     }
     if(pauseButton.CheckClick()){
       player.pause();
     }
     if(playButton.CheckClick()){
       if(selection!=null)
       player.play();  
     }
    } 
 
     
    void frequencyfilter(){
      fft.forward( player.mix );
    //specSize: size of the spectrum created by fft
    for(int i = 0; i < fft.specSize(); i++){
     //frequency band at i
     freq=fft.getBand(i);
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
    noFill();
    rect(_x,_y,_width,_height);
    textAlign(CENTER);
    text(_label,_x+(_width/2.0),_y+(_height/2.0)+6);
  }
  
  public boolean CheckClick() {
    return mouseX > _x && mouseX < (_x + _width) && mouseY > _y && mouseY < (_y + _height);
  }
}
