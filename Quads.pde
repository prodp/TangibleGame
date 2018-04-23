
ArrayList<PVector[]> getBestQuad(ArrayList<PVector> lines, PImage img_sobel)
{
  //--- On crée le quadgraph
  QuadGraph graph = new QuadGraph();
  graph.build(lines, img_sobel.width, img_sobel.height);
  //--- On récupère les cycles d'après les intersections de lignes
  List<int[]> cycles = graph.findCycles();
  // On garde uniquement les cycles de taille 4
  List<int[]> quads = new ArrayList<int[]>();
  for (int[] c : cycles)
    if (c.length == 4)
      quads.add(c);

  //--- On crée la liste des quads finaux, chaque étant un PVector des intersections
  List<PVector[]> final_quads = new ArrayList<PVector[]>();
  List<PVector[]> final_lines = new ArrayList<PVector[]>();
  for (int[] quad : quads)
  {
    PVector l1 = lines.get(quad[0]);
    PVector l2 = lines.get(quad[1]);
    PVector l3 = lines.get(quad[2]);
    PVector l4 = lines.get(quad[3]);
    
    // (intersection() is a simplified version of the
    // intersections() method you wrote last week, that simply
    // return the coordinates of the intersection between 2 lines) 
    PVector c12 = intersection(l1, l2);
    PVector c23 = intersection(l2, l3);
    PVector c34 = intersection(l3, l4);  
    PVector c41 = intersection(l4, l1);
    
    // On applique les critères pour garder uniquement les quads valides
    if (graph.isConvex(c12, c23, c34, c41) && 
        graph.validArea(c12, c23, c34, c41, MAX_AREA, MIN_AREA) &&
        graph.nonFlatQuad(c12, c23, c34, c41)) 
        {
          PVector[] q = {c12, c23, c34, c41};
          final_quads.add(q);
          PVector[] l = {l1, l2, l3, l4};
          final_lines.add(l);
        }
  }
  
  //--- On garde uniquement le quad le plus grand
  if (final_quads.size() > 0)
  {
    PVector[] bestQuad = final_quads.get(0);
    PVector[] bestQuadLines = final_lines.get(0);
    float bestQuadArea = graph.area(bestQuad[0], bestQuad[1], bestQuad[2], bestQuad[3]);
    for (int i = 1 ; i < final_quads.size() ; ++i)
    {
      PVector[] q = final_quads.get(i);
      float qArea = graph.area(q[0], q[1], q[2], q[3]);
      if (qArea > bestQuadArea)
      {
        bestQuad = q;
        bestQuadArea = qArea;
        bestQuadLines = final_lines.get(i);
      }
    }
    
    ArrayList<PVector[]> res = new ArrayList<PVector[]>();
    res.add(bestQuad);
    res.add(bestQuadLines);
    return res;
  }
  return null;
}

void display_quad(ArrayList<PVector[]> qs)
{
  for (PVector[] q : qs)
  {
    Random random = new Random();
    fill(color(min(255, random.nextInt(300)),
                min(255, random.nextInt(300)),
                min(255, random.nextInt(300)), 50));
    
    quad(q[0].x, q[0].y, q[1].x, q[1].y, q[2].x, q[2].y, q[3].x, q[3].y);
  }
}