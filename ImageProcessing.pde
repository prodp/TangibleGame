ArrayList<PVector[]> process_image()
{
  //--- On filtre le hue, la saturation, et la brightness
  filter_image(img, MIN_HUE, MAX_HUE, Filter.HUE);  // le vert est officiellement entre 81 et 140
  filter_image(img, MIN_BRIGHTNESS, MAX_BRIGHTNESS, Filter.BRIGHTNESS);  
  filter_image(img, MIN_SATURATION, MAX_SATURATION, Filter.SATURATION);
  filter_image(img, 0, 255, Filter.IF_NOT_X_THEN_Y);
  //--- On floute l'image
  PImage blurred_image = convolute(img);
  
  //--- On filtre l'intensité
  filter_image(blurred_image, MIN_INTENSITY, MAX_INTENSITY, Filter.INTENSITY);
  
  //--- On applique sobel
  PImage img_sobel = sobel(blurred_image);
  
  //--- On applique hough et on récupère les lignes
  ArrayList<PVector> lines = hough(img_sobel, BEST_LINE_NB);
  allLines = new ArrayList<PVector>();
  for(int i = 0 ; i < lines.size() ; ++i)
  {
     allLines.add(lines.get(i));
  }
  //println(lines.size());
   
  //--- On récupère le meilleur quad
  ArrayList<PVector[]> bestQuad = getBestQuad(lines, img_sobel);
  if (bestQuad != null)
  {
    // On trie le quad
    List<PVector> sortedCorners = sortCorners(Arrays.asList(bestQuad.get(0)));
    // On calcule les angles
    TwoDThreeD tmp = new TwoDThreeD(RES_VIDEO_X, RES_VIDEO_Y);
    PVector angles = tmp.get3DRotations(sortedCorners);
    /*println("affichage des angles : ");
    println(Math.toDegrees(angles.x));
    println(Math.toDegrees(angles.y));
    println(Math.toDegrees(angles.z));*/
    
    rotationX = -angles.x*2/3 - PI/8;
    //rotationY = angles.z*2/3;
    rotationZ = -angles.y*2/3 -PI/16;
    
    return bestQuad;
  }
  else
  {
    return null; 
  }
}