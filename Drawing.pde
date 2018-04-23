
void drawGame()
{
  pg_game.beginDraw();
  
  pg_game.pushMatrix();
  pg_game.camera(pg_game.width/2, 0, (pg_game.height/2.0) / tan(PI * 45.0 / 180.0), 
                  pg_game.width/2, pg_game.height/2, 0, 
                  0, 1, 0);
  pg_game.noStroke();
  pg_game.background(200);
  pg_game.lights();
  pg_game.directionalLight(100, 100, 100, -1, 1, 0);
  pg_game.translate(pg_game.width/2, pg_game.height/2, 0);
  pg_game.fill(100, 255, 100);
  
  switch(mode)
  {
    case PLAY:
      pg_game.rotateX(rotationX);
      pg_game.rotateY(rotationY);
      pg_game.rotateZ(rotationZ);
      ball.update();
      break;
    case EDIT:
      pg_game.rotateX((PI * 45.0 / 180.0) -PI/2);
      break;
    default:
      break;
  }
  
  pg_game.box(plateWidth, plateHeight, plateLength);
      
  pg_game.translate(0,-5 -ballRadius, 0); // on met la boule à hauteur du plateau
  pg_game.pushMatrix();
  pg_game.translate(ball.location.x, ball.location.y, ball.location.z);  // on place la boule au bon endroit
  pg_game.fill(100, 100, 100);
  pg_game.sphere(ballRadius);
  pg_game.popMatrix();
      
  pg_game.translate(0, ballRadius, 0);  // On revient à hauteur du plateau EXACT
      
  for(int i = 0 ; i < cylinders.size() ; ++i)
  {
    pg_game.pushMatrix();
    pg_game.translate(cylinders.get(i).x, 0, cylinders.get(i).z);
    pg_game.shape(cylinder.getCylinder());
    pg_game.popMatrix();
  }
  pg_game.popMatrix();
  drawStats();
  
  pg_game.endDraw();
  image(pg_game, 0, 0); 
}

void drawStats()
{
  pg_game.textSize(48);
  switch(mode)
  {
    case EDIT:
      pg_game.pushMatrix();
      //pg_game.rotateX(PI * 45.0 / 180.0);
      pg_game.fill(0);
      pg_game.text("Clic gauche : placer un obstacle", -100, -190, -500);
      pg_game.text("Clic droit : enlever l'obstacle", -100, -130, -500);
      pg_game.popMatrix();
      break;
    case PLAY:
      pg_game.pushMatrix();
      //pg_game.rotateX(PI * 45.0 / 180.0);
      pg_game.fill(0);
      pg_game.text("Vitesse de rotation du plateau : " + int(speed*1000), -100, -160, -500);
      pg_game.popMatrix();
      break;
    default:
      break;
  }
}

void drawDataVisuBar()
{
  pg_dataBar.beginDraw();
  pg_dataBar.background(230, 230, 230);
  pg_dataBar.endDraw();
  image(pg_dataBar, 0, height-dataBarHeight);
}

void drawMini()
{
  pg_mini.beginDraw();
  
  pg_mini.noStroke();
  pg_mini.fill(150, 255, 150);
  pg_mini.rect(0, 0, miniMapWidth, miniMapHeight); 
  int x = Math.round((ball.location.x + plateWidth/2) * miniMapWidth / plateWidth);
  int y = Math.round((ball.location.z + plateLength/2) * miniMapHeight / plateLength);
  int diameter = Math.round((2*ballRadius * miniMapHeight / plateLength));
  pg_mini.fill(100, 100, 100);
  pg_mini.ellipse(x, y, diameter, diameter);
  
  pg_mini.fill(255);
  for (int i = 0 ; i < cylinders.size() ; ++i)
  {
    int xc = Math.round((cylinders.get(i).x + plateWidth/2) * miniMapWidth / plateWidth);
    int yc = Math.round((cylinders.get(i).z + plateLength/2) * miniMapHeight / plateLength);
    int diameterc = Math.round((cylinder.getBaseSize()*2 * miniMapHeight / plateLength));
    pg_mini.ellipse(xc, yc, diameterc, diameterc);
  }
  
  pg_mini.endDraw();
  image(pg_mini, 5, height-dataBarHeight+5);
}

void drawScore()
{
  pg_score.beginDraw();
  pg_score.background(255);
  pg_score.fill(230);
  pg_score.noStroke();
  pg_score.rect(2, 2, pg_score.width-4, pg_score.height-4);
  pg_score.textSize(10);
  pg_score.fill(0);
  pg_score.text("Total score", 10, 15);
  pg_score.text(score, 10, 28);
  pg_score.text("Velocity", 10, 43);
  pg_score.text(ball.velocity.mag(), 7, 56);
  pg_score.text("Last score", 10, 71);
  pg_score.text(lastScore, 10, 84);
  
  pg_score.endDraw();
  image(pg_score, pg_mini.width + 20, height-dataBarHeight+5);
}

void drawChart()
{
  pg_chart.beginDraw();
  pg_chart.background(240);
  chart.updateScaleX(scrollbar.getPos());
  chart.display(pg_chart);
  pg_chart.endDraw();
  image(pg_chart, 5 + miniMapWidth + 15 + 80 + 15, height-dataBarHeight+5);
}

void drawFilteredImage()
{
  pg_filtered.beginDraw();
  pg_filtered.background(240);
  pg_filtered.image(img, 0, 0);
  PVector[] linesAsArray = new PVector[allLines.size()]; 
  for (int i = 0 ; i < allLines.size() ; ++i)
  {
    linesAsArray[i] = allLines.get(i);
  }
  display_lines(img, linesAsArray , pg_filtered);
  pg_filtered.endDraw();
  image(pg_filtered, RES_GAME_X, RES_VIDEO_Y);
}

void drawLinesAndInter(ArrayList<PVector[]> bestQuad)
{
  if (bestQuad != null && bestQuad.size() >= 2)
  {
    PVector[] q_inter = bestQuad.get(0);
    PVector[] q_lines = bestQuad.get(1);
    
    //--- On affiche les lignes
    pg_video.beginDraw();
    pg_video.fill(255, 128, 0);
    display_lines(img, q_lines, pg_video);
    
    //--- On affiche les intersections
    pg_video.ellipse(q_inter[0].x, q_inter[0].y, 10, 10);
    pg_video.ellipse(q_inter[1].x, q_inter[1].y, 10, 10);
    pg_video.ellipse(q_inter[2].x, q_inter[2].y, 10, 10);
    pg_video.ellipse(q_inter[3].x, q_inter[3].y, 10, 10);
      
    pg_video.endDraw();
    image(pg_video, RES_GAME_X, 0);
  }
}

void drawVideo(ArrayList<PVector[]> bestQuad)
{
  pg_video.beginDraw();
  //pg_video.loadPixels();
  //if (imgUnmodified.width != 0)
  //  imgUnmodified.resize(RES_VIDEO_GAME_X, imgUnmodified.height*RES_VIDEO_GAME_X/imgUnmodified.width);
  pg_video.image(imgUnmodified, 0, 0);
  drawLinesAndInter(bestQuad);
  pg_video.endDraw();
  //pg_video.updatePixels();
  //loadPixels();
  image(pg_video, RES_GAME_X, 0);
  //updatePixels();
}

/*
void drawCamera()
{
  updatePixels();
  if (img.width != 0)
    img.resize(RES_VIDEO_GAME_X, img.height*RES_VIDEO_GAME_X/img.width);
  image(img, RES_VIDEO_GAME_X, 0);
  loadPixels();
  
  pg_video.beginDraw();
  if (img.width != 0)
    img.resize(RES_VIDEO_GAME_X, img.height*RES_VIDEO_GAME_X/img.width);
  pg_video.image(img, RES_VIDEO_GAME_X, 0);
  pg_video.endDraw();
  image(pg_video, RES_VIDEO_GAME_X, 0);
}*/