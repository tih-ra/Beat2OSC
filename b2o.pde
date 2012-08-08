/**
 * Frequency Energy 
 * by Damien Di Fede.
 *  
 * This sketch demonstrates how to use the BeatDetect object in FREQ_ENERGY mode.
 * You can use <code>isKick</code>, <code>isSnare</code>, </code>isHat</code>, 
 * <code>isRange</code>, and <code>isOnset(int)</code> to track whatever kind 
 * of beats you are looking to track, they will report true or false based on 
 * the state of the analysis. To "tick" the analysis you must call <code>detect</code> 
 * with successive buffers of audio. You can do this inside of <code>draw</code>, 
 * but you are likely to miss some audio buffers if you do this. The sketch implements 
 * an <code>AudioListener</code> called <code>BeatListener</code> so that it can call 
 * <code>detect</code> on every buffer of audio processed by the system without repeating 
 * a buffer or missing one.
 * 
 * This sketch plays an entire song so it may be a little slow to load.
 */

import ddf.minim.*;
import ddf.minim.analysis.*;
import oscP5.*;
import netP5.*;


Minim minim;
AudioInput song;
BeatDetect beat;
BeatListener bl;

OscP5 oscP5;
NetAddress myRemoteLocation;

float kickSize, snareSize, hatSize;
float kickSizeMsg, snareSizeMsg, hatSizeMsg;

void setup()
{
  size(512, 200);
  smooth();
  
  oscP5 = new OscP5(this, 9000);
  
  minim = new Minim(this);
  
  song = minim.getLineIn(Minim.STEREO, 1024, 44100.0, 8);
  //song.play();
  // a beat detection object that is FREQ_ENERGY mode that 
  // expects buffers the length of song's buffer size
  // and samples captured at songs's sample rate
  beat = new BeatDetect(song.bufferSize(), song.sampleRate());
  // set the sensitivity to 300 milliseconds
  // After a beat has been detected, the algorithm will wait for 300 milliseconds 
  // before allowing another beat to be reported. You can use this to dampen the 
  // algorithm if it is giving too many false-positives. The default value is 10, 
  // which is essentially no damping. If you try to set the sensitivity to a negative value, 
  // an error will be reported and it will be set to 10 instead. 
  beat.setSensitivity(300);  
  kickSize = snareSize = hatSize = 16;
  kickSizeMsg = snareSizeMsg = hatSizeMsg = 0;
  // make a new beat listener, so that we won't miss any buffers for the analysis
  bl = new BeatListener(beat, song);  
  textFont(createFont("SanSerif", 16));
  textAlign(CENTER);
  
  myRemoteLocation = new NetAddress("127.0.0.1",9000);
}

void draw()
{
  background(0);
  fill(255);
  if ( beat.isKick() ) { kickSize = 32; kickSizeMsg = 100; }
  if ( beat.isSnare() ) { snareSize = 32; snareSizeMsg = 100; }
  if ( beat.isHat() ) { hatSize = 32; hatSizeMsg = 100; }
  textSize(kickSize);
  text("KICK", width/4, height/2);
  textSize(snareSize);
  text("SNARE", width/2, height/2);
  textSize(hatSize);
  text("HAT", 3*width/4, height/2);
  kickSize = constrain(kickSize * 0.95, 16, 32);
  snareSize = constrain(snareSize * 0.95, 16, 32);
  hatSize = constrain(hatSize * 0.95, 16, 32);
  
  kickSizeMsg = constrain(kickSizeMsg * 0.95, 0.95, 100);
  snareSizeMsg = constrain(snareSizeMsg * 0.95, 0.95, 100);
  hatSizeMsg = constrain(hatSizeMsg * 0.95, 0.95, 100);
  
  OscMessage kickMessage = new OscMessage("/kick");
  OscMessage snareMessage = new OscMessage("/snare");
  OscMessage hatMessage = new OscMessage("/hat");
  
  kickMessage.add(kickSizeMsg / 100);
  snareMessage.add(snareSizeMsg / 100);
  hatMessage.add(hatSizeMsg / 100);
  
  oscP5.send(kickMessage, myRemoteLocation);
  oscP5.send(snareMessage, myRemoteLocation);
  oscP5.send(hatMessage, myRemoteLocation);
}

void stop()
{
  // always close Minim audio classes when you are finished with them
  song.close();
  // always stop Minim before exiting
  minim.stop();
  // this closes the sketch
  super.stop();
}
