import ddf.minim.*;
import ddf.minim.analysis.*;
import javax.swing.*;
import javax.swing.filechooser.FileNameExtensionFilter;

Minim minim;
AudioPlayer player;
Button loadFileButton;
File selection;
int returnVal;
JFileChooser filechooser= new JFileChooser();
String extensionDescription;
String[] extension;
FileNameExtensionFilter extensionfilter;
FFT fft;

void setup(){
  size(300, 300,P3D);
  minim = new Minim(this);
  loadFileButton = new Button(100.0,100.0,110.0,20.0,"Laden Sie bitte eine Audio-Datei hoch.");
  extensionfilter=new FileNameExtensionFilter("WAV oder MP3-Datei auswählen", "mp3", "wav");;
  }
 
 void draw(){
  loadFileButton.drawButton(); //<>//
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
          player = minim.loadFile(selection.getPath());
          player.setVolume(20.0);
          player.play();
          frequencyfilter();
        }
     }
    } 
 
     
    void frequencyfilter(){
      
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
