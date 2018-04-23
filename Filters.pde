
public enum Filter{
  HUE,
  BRIGHTNESS,
  SATURATION, 
  IF_NOT_X_THEN_Y,
  INTENSITY;
}

void filter_image(PImage image, float min, float max, Filter filter) {
  float value = 0;
  switch(filter)
  {
     case HUE:
       for (int i = 0 ; i < image.width * image.height ; ++i)
       {
         value = hue(image.pixels[i]);
         if (value < min || value > max)
           image.pixels[i] = color(0);
       }
       break;
     case BRIGHTNESS:
       for (int i = 0 ; i < image.width * image.height ; ++i)
       {
         value = brightness(image.pixels[i]);
         if (value < min || value > max)
           image.pixels[i] = color(0);
       }
       break;
     case SATURATION:
       for (int i = 0 ; i < image.width * image.height ; ++i)
       {
         value = saturation(image.pixels[i]);
         if (value < min || value > max)
           image.pixels[i] = color(0);
       }
       break;
     case IF_NOT_X_THEN_Y:
       for (int i = 0 ; i < image.width * image.height ; ++i)
       {
         value = image.pixels[i];
         if (value != color(min))
           image.pixels[i] = color(max);
       }
       break;
     case INTENSITY:
       for (int i = 0 ; i < image.width * image.height ; ++i)
       {
         value =  (3 * red(img.pixels[i]) + 12 * green(img.pixels[i]) + 1 * blue(img.pixels[i])) / 16;
         if (value < min || value > max)
           image.pixels[i] = color(0);
       }
       break;
     default:
       break;
  }
}
  