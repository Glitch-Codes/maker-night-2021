// Import required libraries
import processing.serial.*;
import ddf.minim.*;
import ddf.minim.analysis.*;
import cc.arduino.*;

// Create instance of each class
Minim minim;
AudioPlayer song;
BeatDetect beat;
BeatListener bl;
FFT fft;
Arduino arduino;

// Here is where we establish the variables we will use
boolean playSong, songLoaded = false;
float kick, snare, hihat;
float kickSize, snareSize, hihatSize;
int kickBand, snareBand, kickTrigger, snareTrigger;

// This runs once at startup
void setup() {
  // Sets a target framerate for the accelerated view (Not required but allows for better sampling of the audio FFT if a target is set)
  frameRate(120);
  
  // Sets the size of the window for our program
  size(1280, 600, P2D);

  // Opens a new instance of the Minim audioplayer
  minim = new Minim(this);
  
  arduino = new Arduino(this, Arduino.list()[0], 57600);
  arduino.pinMode(10, Arduino.OUTPUT);
  arduino.pinMode(11, Arduino.OUTPUT);
  arduino.pinMode(12, Arduino.OUTPUT);
  arduino.digitalWrite(10, Arduino.LOW);
  arduino.digitalWrite(11, Arduino.LOW);
  arduino.digitalWrite(12, Arduino.LOW);

  // Pick a global font to use, align it to the center of the text coords
  textAlign(CENTER);
  kickSize = 16;
  snareSize = 16;
  hihatSize = 16;
}

// This loops until program is closed
void draw() {
  // Sets the background to black 
  background(0);
  
  // This is where we draw the labels to each "button"
  fill(255);
  textSize(16);
  text("Play Song", width - 200, 10, 100, 50);
  text("Stop Song", width - 100, 10, 100, 50);
  text("Thrones", width - 200, 60, 100, 50);
  text("Deadchunk", width - 200, 120, 100, 50);
  
  // This is where we draw the wireframe layout of each channel
  fill(0);
 
  // Kick
  stroke(255, 0, 0);
  rect(360, 220, 120, 60);

  // Snare
  stroke(0, 255, 0);
  rect(550, 220, 120, 60);

  // HiHat
  stroke(0, 0, 255);
  rect(740, 220, 120, 60);

  // Reset stroke to black
  stroke(0);

  // This is where we draw the text for each audio channel
  fill(255);
  textSize(kickSize);
  text("Kick", 420, 260);
  kickSize = constrain(kickSize * 0.95, 16, 32);
  
  fill(255);
  textSize(snareSize);
  text("Snare", 610, 260);
  snareSize = constrain(snareSize * 0.95, 16, 32);
  
  fill(255);
  textSize(hihatSize);
  text("HiHat", 800, 260);
  hihatSize = constrain(hihatSize * 0.95, 16, 32);

  // This is where we load songs to play
  if (mouseInRect(width - 200, 60, 100, 50) && mousePressed && playSong == false)
  {
    song = minim.loadFile("data/Thrones.mp3", 2048);
    kickBand = 4;
    kickTrigger = 140;
    snareBand = 9;
    snareTrigger = 120;
    songLoaded = true;
    fill(255, 0, 0);
    rect(width - 200, 60, 100, 50);
  } else if (mouseInRect(width - 200, 120, 100, 50) && mousePressed && playSong == false)
  {
    song = minim.loadFile("data/Deadchunk.mp3", 2048);
    kickBand = 4;
    kickTrigger = 140;
    snareBand = 9;
    snareTrigger = 120;
    songLoaded = true;
    fill(255, 0, 0);
    rect(width - 200, 120, 100, 50);
  }
  
  // This is where we create the audio player buttons 
  if (mouseInRect(width - 100, 10, 100, 50) && mousePressed && playSong == true)
  {
    rect(width - 100, 10, 100, 50);
    song.close();
    playSong = false;
    songLoaded = false;
    arduino.digitalWrite(10, Arduino.LOW);
    arduino.digitalWrite(11, Arduino.LOW);
    arduino.digitalWrite(12, Arduino.LOW);
  } else if (mouseInRect(width - 200, 10, 100, 50) && mousePressed && playSong == false && songLoaded == true)
  {
    rect(width - 200, 10, 100, 50);
    song.setVolume(50);
    song.play();
    beat = new BeatDetect(song.bufferSize(), song.sampleRate());
    fft = new FFT(song.bufferSize(), song.sampleRate());
    fft.linAverages(70);
    beat.setSensitivity(40);
    bl = new BeatListener(beat, song);
    playSong = true;
  }
  
  // Here is where all the audio processing starts
  if (playSong == true)
  {
    fft.forward(song.mix);
    textSize(16);
    for (int i = 0; i < 80; i++)
    {
      float b = fft.getBand(i);
      if (b > 120) fill(255, 0, 0);
      else fill(255);
      rect(i*18, height - b, 15, b);
      text(i, i*18, height - b);
    }
    
    if (fft.getBand(kickBand) > kickTrigger)
    {
      kickSize = 32; 
      arduino.digitalWrite(10, Arduino.HIGH);
    }
    if (fft.getBand(snareBand) > snareTrigger)
    {
      snareSize = 32; 
      arduino.digitalWrite(11, Arduino.HIGH);
    }
    if(beat.isHat())
    {
      hihatSize = 32; 
      arduino.digitalWrite(12, Arduino.HIGH);
    }
  }
  arduino.digitalWrite(10, Arduino.LOW);
  arduino.digitalWrite(11, Arduino.LOW);
  arduino.digitalWrite(12, Arduino.LOW);
}

boolean mouseInRect(int x, int y, int rectWidth, int rectHeight)
{
  if(mouseX > x && mouseX < x + rectWidth && mouseY > y && mouseY < y + rectHeight) return true;
  else return false;
}
