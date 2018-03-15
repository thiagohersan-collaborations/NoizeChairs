/**
 * This sketch demonstrates how to use the <code>position</code> method of a <code>Playable</code> class. 
 * The class used here is <code>AudioPlayer</code>, but you can also get the position of an <code>AudioSnippet</code>.
 * The position is the current position of the "playhead" in milliseconds. In other words, it's how much of the 
 * recording has been played. This sketch demonstrates how you could use the <code>position</code> method to 
 * visualize where in the recording playback is.
 *
 */

import ddf.minim.*;
import java.awt.*;

public final int ALTURARECT = 4;   // altura dos retangulos (em pixeis)
public final int ALTURA = 1024;    // altura do arquivo eps (em pixeis) (DEVE SER MULTIPLO DO VALOR ALTURARECT)
public final int LARGURA = 1024;   // largura do arquivo eps (em pixeis)

public final String AUDIOFILE = "groove.mp3";

// state machine to guide the program
public final int STATE_READ = 0;
public final int STATE_PRINT = 1;
public final int STATE_DONE = 2;
public int currState;

audioTrack leftTrack, rightTrack;

Minim minim;
AudioPlayer groove;
WaveformRenderer waveform;

// for eps file
FileOutputStream finalImage;
EpsGraphics2D g;


void setup() {
  size(LARGURA, ALTURA);
  frameRate(90);

  currState = STATE_READ;
  leftTrack = new audioTrack();
  rightTrack = new audioTrack();

  minim = new Minim(this);
  waveform = new WaveformRenderer(leftTrack, rightTrack);

  // open file
  groove = minim.loadFile(AUDIOFILE, 2048);

  println("buffer size: "+groove.bufferSize());
  println("sample rate: " + groove.sampleRate());
  println("total samples: " + (int)(groove.length()/1000.0*groove.sampleRate()));
  //println(groove.left.toArray().length);
  //println("samples per pixel: "+ (groove.length()/1000.0*groove.sampleRate())/width);

  try {
    // start eps file
    finalImage = new FileOutputStream(dataPath(AUDIOFILE.substring(0,AUDIOFILE.lastIndexOf('.')) + "." + ALTURARECT+ ".eps"));
    g = new EpsGraphics2D(AUDIOFILE, finalImage, 0, 0, width, height);
    g.setBackground(Color.BLACK);
    g.clearRect(0, 0, width, height);
    g.setColor(Color.WHITE);
  }
  catch (Exception e) {
    println("Erro: arquivo .eps não pode ser criado");
    exit();
  }

  groove.addListener(waveform);
  groove.play();

  background(0);
  smooth();
}

void draw() {

  // playing audio and then loading it into data structures
  if (currState == STATE_READ) {
    if (groove.isPlaying()) {
      // just filling up the buffers...
      background(0);
      float x = map(groove.position(), 0, groove.length(), 0, width);
      stroke(255, 0, 0);
      line(x, 30, x, 130);
    }

    // just stopped playing
    else {
      // init the audioTracks.
      //   for drawing wave lines, this should be the number of horizontal pixels (width)
      //   for rectangles this should be the number of rectangles we want (ALTURA/ALTURARECT)
      //leftTrack.initTrack(width);
      //rightTrack.initTrack(width);

      leftTrack.initTrack(ALTURA/ALTURARECT);
      rightTrack.initTrack(ALTURA/ALTURARECT);
      currState = STATE_PRINT;
    }
  }

  // draw stuff to screen and eps file
  else if (currState == STATE_PRINT) {
    // print stuff
    println("left queue is : "+leftTrack.getSize());
    println("right queue is : "+rightTrack.getSize());
    background(0);
    //leftTrack.drawWaveLines(160, 150, g);
    //rightTrack.drawWaveLines(460, 150, g);
    leftTrack.drawRectangles(width/2-2, ALTURARECT, 0, g);
    rightTrack.drawRectangles(width/2-2, ALTURARECT, width/2+4, g);

    try {
      g.flush();
      g.close();
      finalImage.close();
    }
    catch(Exception e) {
    }

    // done !
    currState = STATE_DONE;
  }
}

void stop() {
  // always close Minim audio classes when you are done with them
  groove.close();
  // always stop Minim before exiting.
  minim.stop();

  super.stop();
}

