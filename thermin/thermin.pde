import beads.*;
import controlP5.*;

AudioContext ac;
ControlP5 p5;
Slider2D s;

WavePlayer[] wp;
WavePlayer[] beater;

Gain[] harmonicGains;
Gain[] beaterGains;

Glide[] harmonicGlides;
Glide[] beaterGlides;

Gain masterGain;

void setup() {
  size(400, 450);
  
  ac = new AudioContext();
  
  p5 = new ControlP5(this);
  
  s = p5.addSlider2D("theremin")
    .setPosition(50, 50)
    .setSize(300, 300)
    .setMinMax(110.0, 0.0, 880.0, 1.0)
    .setArrayValue(new float[] { 440.0, 0.5 });
  
  wp = new WavePlayer[10];
  beater = new WavePlayer[10];
  
  harmonicGains = new Gain[10];
  beaterGains = new Gain[10];
  
  harmonicGlides = new Glide[10];
  beaterGlides = new Glide[10];
  
  masterGain = new Gain(ac, 1, new Glide(ac, 0.5, 500));
  
  float harmonics = 440.0;
  float gain = 1.0;
  
  for (int i = 0; i < 10; i++) {
    
    if (i == 0) {
       harmonics = 440.0;
    } else {
      harmonics *= 2;
    }
    
    float beaterFrequency = harmonics * 1.01;
    
    harmonicGlides[i] = new Glide(ac, harmonics, 500);
    beaterGlides[i] = new Glide(ac, beaterFrequency, 500);
    
    wp[i] = new WavePlayer(ac, harmonicGlides[i], Buffer.SINE);
    beater[i] = new WavePlayer(ac, beaterGlides[i], Buffer.SINE);
    
    if (i == 0) {
      gain = 1.0;
    } else {
      gain /= 2;
    }
    
    harmonicGains[i] = new Gain(ac, 1, gain);
    beaterGains[i] = new Gain(ac, 1, gain);
    
    harmonicGains[i].addInput(wp[i]);
    beaterGains[i].addInput(beater[i]);
    
    masterGain.addInput(harmonicGains[i]);
    masterGain.addInput(beaterGains[i]);
  }
  
  ac.out.addInput(masterGain);
  
  ac.start();
}

void draw() {
  background(0);
  
  fill(255);
  textSize(15);
  text("Frequency: " + (s.getArrayValue()[0]) + " Hz", 50, 400);
  text("Gain: " + (s.getArrayValue()[1]), 50, 420);
}

public void theremin() {
  if (s == null) return;
  
  float x = s.getArrayValue()[0];
  float y = s.getArrayValue()[1];
  
  harmonicGlides[0].setValue(x);
  beaterGlides[0].setValue(x * 1.01);
  
  float harmonics = x;
  
  for (int i = 1; i < 10; i++) {
    
    if (i == 0) {
      harmonics = 440.0;
    } else {
      harmonics *= 2;
    }
    
    float beaterFrequency = harmonics * 1.01;
    
    harmonicGlides[i].setValue(harmonics);
    beaterGlides[i].setValue(beaterFrequency);
  }
  
  masterGain.setGain(y);
}
