
PImage sobel(PImage img) {
  
  loadPixels();
  
  float[][] hKernel = {{ 0,  1,  0 },
                       { 0,  0,  0 },
                       { 0, -1,  0 }};
     
  float[][] vKernel = {{ 0,  0,  0 },
                       { 1,  0, -1 },
                       { 0,  0,  0 }};

  PImage result = createImage(img.width, img.height, ALPHA);
  
  // clear the image
  for (int i = 0; i < img.width * img.height; i++) 
  {
    result.pixels[i] = color(0);
  }
  
  float max=0;
  float[] buffer = new float[img.width * img.height];
  
  int N = 3;
  
  // ****** Pour chaque pixels (x, y) de l'images   ******
  for(int y = 1; y < img.height-1 ; ++y) // pour l'instant on saute les bords
  {   
    for (int x = 1 ; x < img.width-1 ; ++x)
    {
      // 1) Apply the vertical and horizontal kernels, and store the sum of intensities
      //    into two variables sum_h and sum_v.
  
      float sum_h = 0.f;
      float sum_v = 0.f;
      for (int y_decalage = - N/2 ; y_decalage <= N/2 ; ++y_decalage)
      {
        for (int x_decalage = - N/2 ; x_decalage <= N/2 ; ++x_decalage)
        {
          int x_final = adjust_pixel_edge(x+x_decalage, 0, img.width);
          int y_final = adjust_pixel_edge(y+y_decalage, 0, img.height);
          sum_h += img.get(x_final, y_final) * hKernel[x_decalage+N/2][y_decalage+N/2];
          sum_v += img.get(x_final, y_final) * vKernel[x_decalage+N/2][y_decalage+N/2];
        }
      }
      
      // 2) compute the compound sum as an euclidian distance
      float sum = sqrt(pow(sum_h, 2) + pow(sum_v, 2));
      
      // 3) store it into a buffer
      buffer[y*img.width + x] = sum;
      
      // 4) store the maximum value found
      if (sum > max)
      {
        max = sum;
      }
    }
  }
   
  for (int y = 2; y < img.height - 2; y++) { // Skip top and bottom edges 
    for (int x = 2; x < img.width - 2; x++) { // Skip left and right
      if (buffer[y * img.width + x] > (int)(max * 0.3f)) { // 30% of the max 
        result.pixels[y * img.width + x] = color(255);
      } else {
        result.pixels[y * img.width + x] = color(0);
      } 
    }
  }
  updatePixels();
  
  return result;
}

PImage convolute(PImage img) 
{       
  float[][] gaussianKernel = {{ 9 , 12, 9 },
                            { 12, 15, 12},
                            { 9 , 12, 9 }};
    float[][] gaussianKernel2 = { {1, 3, 6, 3, 1},
                                  {3, 9, 12, 9, 3},
                                  {6, 12, 15, 12, 6},
                                  {3, 9, 12, 9, 3},
                                  {1, 3, 6, 3, 1} };
                            
    float[][] kernel = gaussianKernel;
  
    PImage result = createImage(img.width, img.height, ALPHA);

    float weight = 1.f;
    // create a greyscale image (type: ALPHA) for output
    
    // kernel size N = 3
    int N = kernel.length;
        
    // Pour chaque pixels (x, y) de l'image
    for(int y = 0; y < img.height ; ++y) 
    {   
      for (int x = 0 ; x < img.width ; ++x)
      {
        float res = 0.f;
        // Pour chaque pixel du kernel, on multiplie par le pixel 
        // correspondant de l'image.
        for (int y_decalage = - N/2 ; y_decalage <= N/2 ; ++y_decalage)
        {
          for (int x_decalage = - N/2 ; x_decalage <= N/2 ; ++x_decalage)
          {
            int x_final = adjust_pixel_edge(x+x_decalage, 0, img.width);
            int y_final = adjust_pixel_edge(y+y_decalage, 0, img.height);
 
            // On somme toute les intensités
            res += img.get(x_final, y_final) * kernel[x_decalage+N/2][y_decalage+N/2];
          }
        }
        
        // On divise les intensités par le weight
        res /= weight;
        
        result.set(x, y, color((int)res));
      }
    }
    
    return result;
}

float sum_of_intensities(PImage img, int x, int y, float kernel[][])
{
  int N = kernel.length;
  float res = 0.f;
  for (int y_decalage = - N/2 ; y_decalage <= N/2 ; ++y_decalage)
  {
    for (int x_decalage = - N/2 ; x_decalage <= N/2 ; ++x_decalage)
    {
      res += img.get(x, y) * kernel[x_decalage+N/2][y_decalage+N/2];
    }
  }
  return res;
}

int adjust_pixel_edge(int pos_pixel, int min, int max)
{
  if (pos_pixel < min)
    pos_pixel = min;
  else if (pos_pixel > max)
    pos_pixel = max;
  return pos_pixel;
}