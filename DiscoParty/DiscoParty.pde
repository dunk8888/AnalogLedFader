import processing.serial.*;

import ddf.minim.*;
import ddf.minim.analysis.*;

Minim minim;
AudioInput audioin;
AudioOutput audioout;  // Need to run soundflower for this to work...

BeatDetect beat;
BeatListener bl;
LedOutput led;

float kickSize, snareSize, hatSize;

int numberOfBoxes = 13;
int channelsPerBox = 6;
int numberOfChannels = numberOfBoxes*channelsPerBox;


int[] values;

float gammaValue = .7;

float globalBrightness = .1;

float globalColorAngle = PI/2;
float globalColorSpeed = .1;

void setup()
{
  frameRate(90);
  size(512, 200, P3D);
  
  minim = new Minim(this);
  audioin = minim.getLineIn(Minim.STEREO, 2048);
  
  // auto connect to the first arduino-like thing we find
  for(String p : Serial.list()) {
    if(p.startsWith("/dev/cu.usbmodem")) {
      led = new LedOutput(this, p, numberOfChannels);
    }
  }

  values = new int[numberOfChannels];
  
  // a beat detection object that is FREQ_ENERGY mode that 
  // expects buffers the length of song's buffer size
  // and samples captured at songs's sample rate
  beat = new BeatDetect(audioin.bufferSize(), audioin.sampleRate());
  
  // set the sensitivity to 300 milliseconds
  // After a beat has been detected, the algorithm will wait for 300 milliseconds 
  // before allowing another beat to be reported. You can use this to dampen the 
  // algorithm if it is giving too many false-positives. The default value is 10, 
  // which is essentially no damping. If you try to set the sensitivity to a negative value, 
  // an error will be reported and it will be set to 10 instead. 
  beat.setSensitivity(100);  
  kickSize = snareSize = hatSize = 16;
  
  // make a new beat listener, so that we won't miss any buffers for the analysis
  bl = new BeatListener(beat, audioin); 
  
  textFont(createFont("Helvetica", 16));
  textAlign(CENTER);
}


void draw()
{
  background(0);
//  fill(255);
//  if ( beat.isKick() ) kickSize = 32;
//  if ( beat.isSnare() ) snareSize = 32;
//  if ( beat.isHat() ) hatSize = 32;
//  textSize(kickSize);
//  text("KICK", width/4, height/2);
//  textSize(snareSize);
//  text("SNARE", width/2, height/2);
//  textSize(hatSize);
//  text("HAT", 3*width/4, height/2);
//  
//  for(int i = 0; i < numberOfChannels; i++) {
//    switch(i%3) {
//      case 0:
//        values[i] = (int)(globalBrightness*(hatSize-16+.2)*2045);
//        break;
//      case 1:
//        values[i] = (int)(globalBrightness*(kickSize-16)*2045);
//        break;
//      case 2:
//        values[i] = (int)(globalBrightness*(snareSize-16+.2)*2045);
//        break;
//      default:
//        values[i] = 0;
//        break;
//    }
//  }

  for(int i = 0; i < numberOfBoxes; i++) {
    int b = int(globalBrightness*(sin(globalColorAngle + 2*PI*(((float)i)/numberOfBoxes*3)) +1)*65535/2);
    
    for(int j = 0; j < channelsPerBox; j++) {
      values[i*channelsPerBox + j] = b;
    }
  }

  led.sendUpdate(values);
  
//  float fadePercent = .95;
//  kickSize = constrain(kickSize * fadePercent, 16, 32);
//  snareSize = constrain(snareSize * fadePercent, 16, 32);
//  hatSize = constrain(hatSize * fadePercent, 16, 32);
  
//  println(frameRate);

  globalColorAngle += globalColorSpeed;
}

void stop()
{
  // always close Minim audio classes when you are finished with them
  audioin.close();

  // always stop Minim before exiting
  minim.stop();
  // this closes the sketch
  super.stop();
}
