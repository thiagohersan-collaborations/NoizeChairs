// to keep audio track info
class audioTrack {

  // envelope points (x,y) coordinates
  private ArrayList<PVector> envelopeMin, envelopeMax;
  // raw track values and a display track with less values
  private ArrayList<Float> rawTrack, dispTrack;

  // inits a new track with empty values
  audioTrack() {
    rawTrack = new ArrayList<Float>();
    dispTrack = new ArrayList<Float>();
    envelopeMin = new ArrayList<PVector>();
    envelopeMax = new ArrayList<PVector>();
  }

  // init the display track and the envelopes
  public void initTrack(int w) {
    // generates a new set of values based on w, the number of samples to display
    this.initDispTrack_avg(w);
    // calculate the max/min envelopes
    this.calcEnvelope();
  }



  // add a sample to the raw track
  public void addSample(float f) {
    rawTrack.add(new Float(f));
  }

  // get size of raw track in samples
  public int getSize() {
    return rawTrack.size();
  }

  // draw wave lines to screen
  //   needs an y-offset and amplitude factor
  public void drawWaveLines(float yoff, float amp) {
    // for each sample, just draw a line from its previous neighbor
    noFill();
    stroke(255);
    for (int i=1; i<dispTrack.size(); i++) {
      line(i-1, dispTrack.get(i-1).floatValue()*amp+yoff, i, dispTrack.get(i).floatValue()*amp+yoff);
    }

    // draw bezier curves from min envelope values
    fill(255, 0, 0);
    stroke(255, 0, 0);
    for (int i=1; i<envelopeMin.size(); i++) {
      PVector pv0 = envelopeMin.get(i-1);
      PVector pv1 = envelopeMin.get(i);
      ellipse(pv0.x, pv0.y*amp+yoff, 2, 2);
      bezier(pv0.x, pv0.y*amp+yoff, (pv0.x+pv1.x)/2, (pv0.y*amp+yoff), (pv0.x+pv1.x)/2, (pv1.y*amp+yoff), pv1.x, pv1.y*amp+yoff);
    }

    // draw bezier curves from max envelope values
    fill(0, 0, 255);
    stroke(0, 0, 255);
    for (int i=1; i<envelopeMax.size(); i++) {
      PVector pv0 = envelopeMax.get(i-1);
      PVector pv1 = envelopeMax.get(i);
      ellipse(pv0.x, pv0.y*amp+yoff, 2, 2);
      bezier(pv0.x, pv0.y*amp+yoff, (pv0.x+pv1.x)/2, (pv0.y*amp+yoff), (pv0.x+pv1.x)/2, (pv1.y*amp+yoff), pv1.x, pv1.y*amp+yoff);
    }
  }

  // draw waves to screen and to eps file
  //   needs an y-offset and amplitude factor
  public void drawWaveLines(float yoff, float amp, EpsGraphics2D g) {
    // draw waves by drawing a line between adjacent sample points
    noFill();
    stroke(255);
    g.setColor(Color.WHITE);
    for (int i=1; i<dispTrack.size(); i++) {
      line(i-1, dispTrack.get(i-1).floatValue()*amp+yoff, i, dispTrack.get(i).floatValue()*amp+yoff);
      g.drawLine(i-1, (int)(dispTrack.get(i-1).floatValue()*amp+yoff), i, (int)(dispTrack.get(i).floatValue()*amp+yoff));
    }

    // draw min envelope beziers
    fill(255, 0, 0);
    stroke(255, 0, 0);
    g.setColor(Color.RED);
    for (int i=1; i<envelopeMin.size(); i++) {
      PVector pv0 = envelopeMin.get(i-1);
      PVector pv1 = envelopeMin.get(i);
      ellipse(pv0.x, pv0.y*amp+yoff, 2, 2);
      bezier(pv0.x, pv0.y*amp+yoff, (pv0.x+pv1.x)/2, (pv0.y*amp+yoff), (pv0.x+pv1.x)/2, (pv1.y*amp+yoff), pv1.x, pv1.y*amp+yoff);
      // eps
      g.drawBezier(pv0.x, pv0.y*amp+yoff, (pv0.x+pv1.x)/2f, (pv0.y*amp+yoff), (pv0.x+pv1.x)/2f, (pv1.y*amp+yoff), pv1.x, pv1.y*amp+yoff);
    }

    // draw max envelope beziers
    fill(0, 0, 255);
    stroke(0, 0, 255);
    g.setColor(Color.BLUE);
    for (int i=1; i<envelopeMax.size(); i++) {
      PVector pv0 = envelopeMax.get(i-1);
      PVector pv1 = envelopeMax.get(i);
      ellipse(pv0.x, pv0.y*amp+yoff, 2, 2);
      bezier(pv0.x, pv0.y*amp+yoff, (pv0.x+pv1.x)/2, (pv0.y*amp+yoff), (pv0.x+pv1.x)/2, (pv1.y*amp+yoff), pv1.x, pv1.y*amp+yoff);
      // eps
      g.drawBezier(pv0.x, pv0.y*amp+yoff, (pv0.x+pv1.x)/2f, (pv0.y*amp+yoff), (pv0.x+pv1.x)/2f, (pv1.y*amp+yoff), pv1.x, pv1.y*amp+yoff);
    }
  }

  // draw rectangles on screen
  //   needs rect width and height and an x-offset
  public void drawRectangles(float rw, float rh, float xoff, EpsGraphics2D g) {
    // draw dispTrack lines
    for (int i=0; i<dispTrack.size(); i++) {
      int   rectColorP = (int)map(dispTrack.get(i).floatValue(), -1f, 1f, 0, 255);
      float rectColorJ = map(rectColorP, 0, 255, 0f, 1f);
      fill(rectColorP);
      noStroke();
      rectMode(CORNER);
      rect(xoff, i*rh, rw, rh);
      // eps
      g.setColor(new Color(rectColorJ, rectColorJ, rectColorJ));
      g.fillRect((int)xoff, i*(int)rh, (int)rw, (int)rh+1);
    }
  }


  ////////////////////////
  // this function just resamples the raw data picking w elements equally spaced
  private void initDispTrack_resample(int w) {
    dispTrack.clear();
    float maxVal = 0;
    for (int i=0; i<w; i++) {
      dispTrack.add(rawTrack.get(i*rawTrack.size()/w));
      float tf = rawTrack.get(i*rawTrack.size()/w).floatValue();
      if (abs(tf) > abs(maxVal)) {
        maxVal = abs(tf);
      }
    }

    // rescale track
    this.scaleTrack(maxVal);
  }

  // this function calculates the avg value for each interval
  private void initDispTrack_avg(int w) {
    dispTrack.clear();
    float maxVal = 0;
    for (int i=0; i<w; i++) {
      float sum = 0f;
      float spp = rawTrack.size()/w;  // samples per pixel

      // sum up spp values
      for (int j=0; j<spp; j++) {
        sum += rawTrack.get(i*(int)spp + j).floatValue();
      }

      // add avg
      dispTrack.add(new Float(sum/spp));
      float tf = sum/spp;
      if (abs(tf) > abs(maxVal)) {
        maxVal = abs(tf);
      }
    }

    // rescale track    
    this.scaleTrack(maxVal);
  }

  // this function returns the max value for each interval
  private void initDispTrack_max(int w) {
    dispTrack.clear();
    float maxVal = 0;  // overall max value
    for (int i=0; i<w; i++) {
      float maxv = 0f;  // local max value
      float spp = rawTrack.size()/w;  // samples per pixel

      // find max in these spp values
      for (int j=0; j<spp; j++) {
        float tf = rawTrack.get(i*(int)spp + j).floatValue();
        if (abs(tf) > abs(maxv)) {
          maxv = tf;
        }
      }

      // add maxv
      dispTrack.add(new Float(maxv));
      float tf = maxv;
      if (abs(tf) > abs(maxVal)) {
        maxVal = abs(tf);
      }
    }

    // rescale track    
    this.scaleTrack(maxVal);
  }

  // scales all values in dispTrack by s
  private void scaleTrack(float s) {
    for (int i=0; i<dispTrack.size(); i++) {
      dispTrack.set(i, new Float(dispTrack.get(i).floatValue() / s));
    }
  }

  // calculate the envelope points
  private void calcEnvelope() {
    boolean goingUp = false;
    PVector oldV = new PVector(-2, -2, -2);

    for (int i=0; i<dispTrack.size(); i++) {
      float tf = dispTrack.get(i).floatValue();

      // if going up, but this one is less than last value, then last value was a peak
      if ((tf <= oldV.y) && (goingUp == true)) {
        PVector pv = new PVector(oldV.x, oldV.y);
        envelopeMin.add(pv);
      }
      // if not going up (going down), and this value greater than last value, last value was a valley
      else if ((tf > oldV.y) && (oldV.y > -2) && (goingUp == false)) {
        PVector pv = new PVector(oldV.x, oldV.y);
        envelopeMax.add(pv);
      }
      goingUp = (tf > oldV.y);
      oldV.x = i;
      oldV.y = tf;
    }
  }
}

