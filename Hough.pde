import java.util.*;

ArrayList<PVector> hough(PImage edgeImg, int nLines) {
  float discretizationStepsPhi = 0.06f;
  float discretizationStepsR = 2.5f;
  
  // dimensions of the accumulator
  int phiDim = (int) (Math.PI / discretizationStepsPhi);
  int rDim = (int) (((edgeImg.width + edgeImg.height) * 2 + 1) / discretizationStepsR);
  
  // our accumulator (with a 1 pix margin around)
  int[] accumulator = new int[(phiDim + 2) * (rDim + 2)];
  
  
  //----------------------------------------------------------
  // pre-computation of the sin and cos values
  //----------------------------------------------------------
  
    float[] tabSin = new float[phiDim];
    float[] tabCos = new float[phiDim];
    float ang = 0;
    float inverseR = 1.f / discretizationStepsR;
    for (int accPhi = 0; accPhi < phiDim; ang += discretizationStepsPhi, accPhi++) 
    {
      // we can also pre-multiply by (1/discretizationStepsR) since we need it in the Hough loop 
      tabSin[accPhi] = (float) (Math.sin(ang) * inverseR);
      tabCos[accPhi] = (float) (Math.cos(ang) * inverseR);
    }
    
  
  //----------------------------------------------------------
  // Fill the accumulator: on edge points (ie, white pixels of the edge image), 
  // store all possible (r, phi) pairs describing lines going through the point.
  //----------------------------------------------------------
  
  for (int y = 0; y < edgeImg.height; y++) 
  {
    for (int x = 0; x < edgeImg.width; x++) 
    {
      // Are we on an edge?
      if (brightness(edgeImg.pixels[y * edgeImg.width + x]) != 0) 
      {
        for (int accPhi = 0 ; accPhi < phiDim ; ++accPhi)
        {
          // ...determine here all the lines (r, phi) passing through
          // pixel (x,y), convert (r,phi) to coordinates in the
          // accumulator, and increment accordingly the accumulator.
          // Be careful: r may be negative, so you may want to center onto
          // the accumulator with something like: r += (rDim - 1) / 2
        
          int r_acc_max = rDim+2;
          float r = x * tabCos[accPhi] + y * tabSin[accPhi];
          int r_acc = (int) (r + (rDim -1) / 2); 
          accumulator[(accPhi+1) * (r_acc_max) + r_acc+2] += 1;        // +2 marche mieux que +1 ?!?!
        }
      } 
    }
  }
  
  //----------------------------------------------------------
  // Create the list of the n best candidates
  //----------------------------------------------------------
  
  ArrayList<Integer> bestCandidates = new ArrayList<Integer>();
  
  // size of the region we search for a local maximum
  int neighbourhood = 10;
  
  for (int accR = 0; accR < rDim; accR++) 
  {
    for (int accPhi = 0; accPhi < phiDim; accPhi++) 
    {
      // compute current index in the accumulator
      int idx = (accPhi + 1) * (rDim + 2) + accR + 1;
      
      if (accumulator[idx] > MIN_VOTES) 
      {
        boolean bestCandidate=true;
        
        // iterate over the neighbourhood
        for(int dPhi=-neighbourhood/2; dPhi < neighbourhood/2+1; dPhi++) 
        { 
          // check we are not outside the image
          if( accPhi+dPhi < 0 || accPhi+dPhi >= phiDim) continue;
          
          for(int dR=-neighbourhood/2; dR < neighbourhood/2 +1; dR++) 
          {
            // check we are not outside the image
            if(accR+dR < 0 || accR+dR >= rDim) continue;
            
            int neighbourIdx = (accPhi + dPhi + 1) * (rDim + 2) + accR + dR + 1;
            
            if(accumulator[idx] < accumulator[neighbourIdx]) 
            { 
              // the current idx is not a local maximum! 
              bestCandidate=false;
              break;
            } 
          }
          if(!bestCandidate) break;
        }
        if(bestCandidate) 
        {
          // the current idx *is* a local maximum 
          bestCandidates.add(idx);
        }
      }
    }
  }
  
  Collections.sort(bestCandidates, new HoughComparator(accumulator));
  
  int index = nLines < bestCandidates.size() ? nLines : bestCandidates.size();
  ArrayList<Integer> bestN = new ArrayList<Integer>(bestCandidates.subList(0, index));
  
  //----------------------------------------------------------
  // Create an array of lines
  //----------------------------------------------------------
  ArrayList<PVector> lines = new ArrayList<PVector>();
  for (int i = 0; i < bestN.size(); i++) 
  {
    int idx = bestN.get(i);
    if (accumulator[idx] > MIN_VOTES) 
    {
      // first, compute back the (r, phi) polar coordinates:
      int accPhi = (int) (idx / (rDim + 2)) - 1;
      int accR = idx - (accPhi + 1) * (rDim + 2) - 1;
      float r = (accR - (rDim - 1) * 0.5f) * discretizationStepsR;
      float phi = accPhi * discretizationStepsPhi;
      lines.add(new PVector(r, phi));
    }
  }
  
  displayAccumulator(rDim, phiDim, accumulator);
  //----------------------------------------------------------
  // Compute intersections
  //----------------------------------------------------------
  
  getIntersections(lines);
  
  return lines;
}

//**********************************************************//
//  Create a comparator
//**********************************************************//

class HoughComparator implements java.util.Comparator<Integer> 
{
  int[] accumulator;
  public HoughComparator(int[] accumulator) 
  {
    this.accumulator = accumulator;
  }
  
  @Override
  public int compare(Integer l1, Integer l2) 
  {
    if (accumulator[l1] > accumulator[l2]
        || (accumulator[l1] == accumulator[l2] && l1 < l2)) 
    {
      return -1;
    }
    return 1;
  } 
}

//**********************************************************//
//  Display the content of the accumulator
//**********************************************************//

void displayAccumulator(int rDim, int phiDim, int[] accumulator)
{
  PImage houghImg = createImage(rDim + 2, phiDim + 2, ALPHA);
  houghImg.loadPixels();
  for (int i = 0; i < accumulator.length; i++) 
  {
      houghImg.pixels[i] = color(min(255, accumulator[i]));
  }
  houghImg.updatePixels();
}

//**********************************************************//
//  Computes the intersections
//**********************************************************//

ArrayList<PVector> getIntersections(List<PVector> lines) 
{
    ArrayList<PVector> intersections = new ArrayList<PVector>();
    for (int i = 0; i < lines.size() - 1; i++) 
    {
        PVector line1 = lines.get(i);
        for (int j = i + 1; j < lines.size(); j++) 
        {
            PVector line2 = lines.get(j);
            // compute the intersection and add it to ’intersections’
            float sinPhi_1 = sin(line1.y);
            float sinPhi_2 = sin(line2.y);
            float cosPhi_1 = cos(line1.y);
            float cosPhi_2 = cos(line2.y);
            float d = cosPhi_2 * sinPhi_1 - cosPhi_1 * sinPhi_2;
            float x = (line2.x * sinPhi_1 - line1.x * sinPhi_2) / d;
            float y = (-line2.x * cosPhi_1 + line1.x * cosPhi_2) / d;
            intersections.add(new PVector(x, y));
        }
    }
    return intersections;
}

PVector intersection(PVector l1, PVector l2)
{
  float d = cos(l2.y) * sin(l1.y) - cos(l1.y) * sin(l2.y);
  float x = (l2.x * sin(l1.y) - l1.x * sin(l2.y)) / d;
  float y = (-l2.x * cos(l1.y) + l1.x * cos(l2.y)) / d;
  return new PVector(x, y);
}

//**********************************************************//
//  Display lines
//**********************************************************//

void display_lines(PImage edgeImg, PVector[] lines, PGraphics obj)
{
  for (PVector l : lines)
  {
    float r = l.x;
    float phi = l.y;
    // Cartesian equation of a line: y = ax + b
    // in polar, y = (-cos(phi)/sin(phi))x + (r/sin(phi))
    // => y = 0 : x = r / cos(phi)
    // => x = 0 : y = r / sin(phi)
    // compute the intersection of this line with the 4 borders of the image
    int x0 = 0;
    int y0 = (int) (r / sin(phi));
    int x1 = (int) (r / cos(phi));
    int y1 = 0;
    int x2 = edgeImg.width;
    int y2 = (int) (-cos(phi) / sin(phi) * x2 + r / sin(phi));
    int y3 = edgeImg.height;
    int x3 = (int) (-(y3 - r / sin(phi)) * (sin(phi) / cos(phi)));
        
    ArrayList<PVector> res = new ArrayList<PVector>();
    
    if (y0 >= 0 && y0 <= edgeImg.height && x0 >= 0 && x0 <= edgeImg.width)
      res.add(new PVector(x0, y0));
    if (x1 >= 0 && x1 <= edgeImg.width && y1 >= 0 && y1 <= edgeImg.height)
      res.add(new PVector(x1, y1));
    if (y2 >= 0 && y2 <= edgeImg.height && x2 >= 0 && x2 <= edgeImg.width)
      res.add(new PVector(x2, y2));
    if (x3 >= 0 && x3 <= edgeImg.width && y3 >= 0 && y3 <= edgeImg.height)
      res.add(new PVector(x3, y3));
      
    if (res.size() == 2)
    {
      obj.stroke(204,102,0);
      obj.line(res.get(0).x, res.get(0).y, res.get(1).x, res.get(1).y);
    }
    else if (SHOW_INTERSECTION_ERROR)
    {
       println("Erreur, l'intersection des lignes avec les bords de l'image" +
         " donne " + res.size() + " résultat(s) au lieu de 2"); 
       println("Les 4 intersections sont : "); 
       println("  (" + x0 + ", " + y0 + ")");
       println("  (" + x1 + ", " + y1 + ")");
       println("  (" + x2 + ", " + y2 + ")");
       println("  (" + x3 + ", " + y3 + ")");
    }
  }
}