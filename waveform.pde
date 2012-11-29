// This class is a very simple implementation of AudioListener. By implementing this interface, 
// you can add instances of this class to any class in Minim that implements Recordable and receive
// buffers of samples in a callback fashion. In other words, every time that a Recordable object has 
// a new buffer of samples, it will send a copy to all of its AudioListeners. You can add an instance of 
// an AudioListener to a Recordable by using the addListener method of the Recordable. If you want to 
// remove a listener that you previously added, you call the removeListener method of Recordable, passing 
// the listener you want to remove.
//
// Although possible, it is not advised that you add the same listener to more than one Recordable. 
// Your listener will be called any time any of the Recordables you've added it have new samples. This 
// means that the stream of samples the listener sees will likely be interleaved buffers of samples from 
// all of the Recordables it is listening to, which is probably not what you want.
//
// You'll notice that the three methods of this class are synchronized. This is because the samples methods 
// will be called from a different thread than the one instances of this class will be created in. That thread 
// might try to send samples to an instance of this class while the instance is in the middle of drawing the 
// waveform, which would result in a waveform made up of samples from two different buffers. Synchronizing 
// all the methods means that while the main thread of execution is inside draw, the thread that calls 
// samples will block until draw is complete. Likewise, a call to draw will block if the sample thread is inside 
// one of the samples methods. Hope that's not too confusing!

class WaveformRenderer implements AudioListener {
  private float[] left;
  private float[] right;

  private audioTrack trackL, trackR;

  private boolean reading;
  private final float THOLD = 0.007f;

  public WaveformRenderer() {
    left = null; 
    right = null;
    reading = false;
  }

  public WaveformRenderer(audioTrack l, audioTrack r) {
    trackL = l;
    trackR = r;
    left = null; 
    right = null;
    reading = false;
  }


  synchronized void samples(float[] samp) {
    left = samp;

    // check if we're above noise threshold
    for (int i=0; (reading == false)&&(i<left.length); i++) {
      if (abs(left[i]) > THOLD) {
        reading = true;
      }
    }

    // if noise threshold has been broken, read in values
    for (int i=0; (reading == true)&&(i<left.length); i++) {
      trackL.addSample(left[i]);
    }
  }

  synchronized void samples(float[] sampL, float[] sampR) {
    left = sampL;
    right = sampR;

    // check if we're above noise threshold
    for (int i=0; (reading == false)&&(i<left.length); i++) {
      if (abs(left[i]) > THOLD) {
        reading = true;
      }
    }
    // check if we're above noise threshold
    for (int i=0; (reading == false)&&(i<right.length); i++) {
      if (abs(right[i]) > THOLD) {
        reading = true;
      }
    }

    // if noise threshold has been broken, read in values
    for (int i=0; (reading == true)&&(i<left.length); i++) {
      trackL.addSample(left[i]);
    }

    // if noise threshold has been broken, read in values
    for (int i=0; (reading == true)&&(i<right.length); i++) {
      trackR.addSample(right[i]);
    }
  }

  synchronized void draw() {
    // do nothing for now
    //   queues get filled elsewhere, just want to pass those numbers to main class.
    println(frameRate);
  }
}

