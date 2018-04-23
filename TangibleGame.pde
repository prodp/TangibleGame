import processing.video.*;

PImage img;
PImage imgUnmodified;

Capture cam;
Movie movie;

float rotationX = 0.0;
float rotationY = 0.0;
float rotationZ = 0.0;

float plateWidth = 250;
float plateLength = 250;
float plateHeight = 10;
float speed = 0.025;

float ballRadius = 10;
Mover ball = new Mover();

Cylinder cylinder;
ArrayList<PVector> cylinders = new ArrayList<PVector>();

final float FRAMERATE = 30;
enum Mode
{
 PLAY, 
 EDIT
};
Mode mode = Mode.PLAY;

int score;
int lastScore;

PGraphics pg_dataBar;
  int dataBarHeight = 100;
PGraphics pg_game;
PGraphics pg_video;
PGraphics pg_filtered;
PGraphics pg_mini;
  int miniMapHeight = dataBarHeight-10;
  int miniMapWidth = Math.round((plateWidth/plateLength) * miniMapHeight);
PGraphics pg_score;
PGraphics pg_chart;
Chart chart;
PGraphics pg_scrollbar;
  int scrollBarWidth;
  int scrollBarHeight;
HScrollbar scrollbar;
long start;
long current;

ArrayList<PVector> allLines;

void settings() 
{
   size(RES_GAME_X + RES_VIDEO_X, Math.max(RES_GAME_Y, 2*RES_VIDEO_Y), P3D); 
}

void setup() 
{
  if (CAM_ACTIVE)
  {
    String[] cameras = Capture.list();
    if (cameras.length == 0) 
    {
      println("There are no cameras available for capture.");
      exit();
    } 
    else 
    {
      println("Available cameras:");
      for (int i = 0; i < cameras.length; i++) 
      {
        println(cameras[i]);
      }
      cam = new Capture(this, cameras[4]);
      cam.start();
    }
  }
  else
  {
    movie = new Movie(this, "testvideo.mp4");
    movie.loop();
  }
  
   frameRate(FRAMERATE);
   
   start = System.nanoTime();
   current = start;
   
   cylinder = new Cylinder();
   score = 0;
   lastScore = 0;
   pg_game = createGraphics(RES_GAME_X, RES_GAME_Y-dataBarHeight, P3D);
   pg_video = createGraphics(RES_VIDEO_X, RES_VIDEO_Y, P2D);
   pg_filtered = createGraphics(RES_VIDEO_X, RES_VIDEO_Y, P2D);
   pg_dataBar = createGraphics(pg_game.width, 100, P2D);
   pg_mini = createGraphics(miniMapWidth, miniMapHeight, P2D);
   pg_score = createGraphics(80, dataBarHeight-10, P2D);
   pg_chart = createGraphics(pg_game.width - 5 - miniMapWidth - 15 - 80 - 15 -5, dataBarHeight-27, P2D);
   scrollBarWidth = pg_game.width - 5 - miniMapWidth - 15 - 80 - 15 - 5;
   scrollBarHeight = 12;
   pg_scrollbar = createGraphics(scrollBarWidth, scrollBarHeight);
   scrollbar = new HScrollbar(5 + miniMapWidth + 15 + 80 + 15, height - 17, 
                              scrollBarWidth, scrollBarHeight);
   chart = new Chart(pg_chart.width, pg_chart.height, 160, 3, scrollbar.getPos(), 100);
}

void draw() 
{
  if (CAM_ACTIVE)
  {
    if (cam.available() == true) 
    {
      cam.read();
    }

    img = cam.get();
  }
  else
  {
    if (movie.available() == true) 
    {
      movie.read();
    }
    img = movie.get();
  }
  imgUnmodified = img.copy();
  
  drawGame();   
  drawDataVisuBar();
  drawMini();
  drawScore();
  if (System.nanoTime() - current > 1e9 && mode != Mode.EDIT)
  {
    current = System.nanoTime();
    chart.update(score);
  }
  drawChart();
  scrollbar.update();
  scrollbar.display(pg_scrollbar);
  
  // analyser l'image
  ArrayList<PVector[]> bestQuad = process_image();
  // afficher l'image
  drawVideo(bestQuad);
  drawFilteredImage();
}

void keyPressed()
{
  if (key == CODED)
    if (keyCode == SHIFT)
    {
      mode = Mode.EDIT;
    }
}

void keyReleased()
{
  if (key == CODED)
    if (keyCode == SHIFT)
    {
      mode = Mode.PLAY;
      current = System.nanoTime();
    }
}

void mouseDragged()
{
  switch(mode)
  {
    case PLAY:
    if (pmouseY < pg_game.height)
    {
      if (pmouseY < mouseY)
        rotationX -= speed;
      else if (pmouseY > mouseY)
        rotationX += speed;
      if (pmouseX < mouseX)
        rotationZ += speed;
      else if (pmouseX > mouseX)
        rotationZ -= speed;
        
      if (rotationX >= PI/3)
        rotationX = PI/3;
      if (rotationX <= -PI/3)
        rotationX = -PI/3;
      if (rotationZ >= PI/3)
        rotationZ = PI/3;
      if (rotationZ <= -PI/3)
        rotationZ = -PI/3;
    }
      break;
    default:
      break;
  }
}

void mouseWheel(MouseEvent event){
  switch(mode)
  {
    case PLAY:
      if (event.getCount() > 0)
        speed = speed * 0.9;
      else if (event.getCount() < 0)
        speed = speed * 1.1;
      if (speed < 0.001)
        speed = 0.001;
      if (speed > 0.1)
        speed = 0.1;
      break;
    default:
      break;
  }
}

void mousePressed()
{
  switch(mode)
  {
    case EDIT:
      float x =map(mouseX-pg_game.width/2, -155, 155, -plateWidth/2, plateWidth/2);
      float z =map(mouseY-pg_game.height/2, -155, 155, -plateLength/2, plateLength/2);
      
      //PVector mapped = mapMouse(mouseX-width/2, mouseY-height/2);
      PVector d = new PVector(x - ball.location.x, 
                              0, 
                              z - ball.location.z);
      float d_size = sqrt(d.x*d.x + d.z*d.z);
                              
      if (mouseButton == LEFT && d_size > ballRadius + cylinder.getBaseSize() &&
          x >= -plateWidth/2 && x <= plateWidth/2 &&
          z >= -plateLength/2 && z <= plateLength/2)
      {
        cylinders.add(new PVector(x, 0, z));
      }
      else if (mouseButton == RIGHT)
      {
        for (int i = 0 ; i < cylinders.size() ; ++i)
        {
          PVector n = new PVector(cylinders.get(i).x - x, 
                                  0,
                                  cylinders.get(i).z - z);
          float n_size = sqrt(n.x*n.x + n.z*n.z);
          if (n_size < cylinder.getBaseSize())
          {
            cylinders.remove(i);
          }
        }
      }
      break;
    default:
      break;
  }
}