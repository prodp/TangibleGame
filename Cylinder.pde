
public class Cylinder {
  private PShape cylinder;
  private final float cylinderBaseSize = 16;
  private final float cylinderHeight = 30;
  private final int cylinderResolution = 16;
  
  public Cylinder() {
    float angle;
    float[] x = new float[cylinderResolution + 1];
    float[] z = new float[cylinderResolution + 1];
    //get the x and y position on a circle for all the sides
    for(int i = 0; i < x.length; i++) {
      angle = (TWO_PI / cylinderResolution) * i;
      x[i] = sin(angle) * cylinderBaseSize;
      z[i] = cos(angle) * cylinderBaseSize;
    }
    
    //-------   Création du cylindre ouvert  --------
    stroke(0);
    PShape openCylinder = createShape();
    openCylinder.beginShape(QUAD_STRIP);
    //draw the border of the cylinder
    for(int i = 0; i < x.length; i++) {
      openCylinder.vertex(x[i], 0 , z[i]);
      openCylinder.vertex(x[i], -cylinderHeight, z[i]);
    }
    openCylinder.endShape();
    
    //-------   Création du cercle du bas   ---------
    PShape bottom;
    bottom = createShape();
    bottom.beginShape(TRIANGLE_FAN);
    bottom.vertex(0, 0, 0);
    for(int i = 0; i < x.length; i++) {
      bottom.vertex(x[i], 0 , z[i]);
    }
    bottom.endShape();    
    
    //-------   Création du cercle du haut   --------
    PShape top;
    top = createShape();
    top.beginShape(TRIANGLE_FAN);
    top.vertex(0, -cylinderHeight, 0);
    for(int i = 0; i < x.length; i++) {
      top.vertex(x[i], -cylinderHeight , z[i]);
    }
    top.endShape(); 
    
    //-------   Création du cylindre complet  -------
    cylinder = createShape(GROUP);
    cylinder.addChild(openCylinder);
    cylinder.addChild(bottom);
    cylinder.addChild(top);
    noStroke();
  }
  
  public PShape getCylinder()
  {
    return cylinder;
  }
  
  public float getBaseSize()
  {
    return cylinderBaseSize;
  }
}