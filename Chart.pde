public class Chart
{
  private int w;
  private int h;
  private int nbLines;
  private final int nbColumns;
  private int nbColumnsToDisplay;
  // arrayList car on devra utiliser remove et add
  private ArrayList<Integer> scores;
  private int blocksWidth[];
  private int blockHeight;
  private final int minScaleY;
  // Le score max représentable sur Y  (/!\ peut changer !)
  private int maxScaleY;
  
  public Chart(int w, int h, int nbColumns, int blockHeight, float scaleX, int minScaleY) {
    this.w = w;
    this.h = h;
    this.nbColumns = nbColumns;
    this.blockHeight = blockHeight;
    this.minScaleY = minScaleY;
    maxScaleY = minScaleY;
    scores = new ArrayList<Integer>();
    // Nombre de pixels en hauteur disponible pour dessiner les blocs
    // On a enlevé les espaces entre les blocs et la bordure
    nbLines = (h - 2 - 1) / (blockHeight + 1);
    // Nombre de pixels en largeur disponible pour dessiner les blocs
    // On a enlevé les espaces entre les blocs et la bordure
    updateScaleX(scaleX);
  }
  
  public void updateScaleX(float scale)
  {
    nbColumnsToDisplay = Math.round(40 + scale * 120);
    
    int nbPixelsW = w - 2 - 2 - (nbColumnsToDisplay-1);
    /* Ici la difficulté est que la largeur sera différente en fonction
       des colonnes, de manière à pouvoir étendre ou raccourcir le 
       graphe de manière fluide. Si en moyenne on dispose par exemple de
       2.7 pixels en largeur, alors il faudra répartir uniformément des 
       largeurs de 2 et des largeurs de 3
       Comment répartir de manière uniforme ? L'idée est d'utiliser la
       valeur moyenne (dans notre exemple : 2.7). Le premier bloc aura 
       la largeur dominante qui est 3. Ensuite comme 3 est plus grand
       que 2.7, on va ajouter 2, ce qui donne une moyenne de 2.5. Comme
       cette moyenne est < 2.7, on ajoute 3, etc... De cette manière la
       répartition sera la plus uniforme possible */
    float mean = (float)nbPixelsW / nbColumnsToDisplay; // 2.7 dans notre exemple
    int wmin = (int)Math.floor(mean); // 2
    int wmax = (int)Math.ceil(mean); // 3
    blocksWidth = new int[nbColumnsToDisplay];
    blocksWidth[0] = Math.round(mean); // 3 au premier tour
    float tmpMean = blocksWidth[0];
    for (int i = 1 ; i < blocksWidth.length ; ++i)
    {
      if (tmpMean <  mean)
        blocksWidth[i] = wmax;
      else
        blocksWidth[i] = wmin;
      tmpMean = (tmpMean * i + blocksWidth[i]) / (i + 1);
    }
  }
  
  public void update(int score)
  {
    if (scores.size() >= nbColumns)
      scores.remove(0);
    scores.add(score);
    if (score > maxScaleY)
      maxScaleY = score;
  }
  
  public void display(PGraphics pg)
  {
    // On calcule la position X de chaque colonne
    int tmp = 2; // on saute 2 pixels à partir de la gauche
    int posX[] = new int[nbColumnsToDisplay];
    for (int i = 0 ; i < nbColumnsToDisplay ; ++i)
    {
      posX[i] = tmp;
      tmp += blocksWidth[i] + 1; 
    }
    
    pg.fill(0, 0, 255);
    pg.noStroke();
    int maxExistingColumns = Math.min(scores.size(), nbColumnsToDisplay);
    for(int i = 0 ; i < maxExistingColumns ; ++i)
    {
      int firstIndex = 0;
      if (scores.size() > nbColumnsToDisplay)
        firstIndex = scores.size() - nbColumnsToDisplay;
      // On calcule le nombre de blocs à afficher pour cette colonne
      int nbBlocs = (int)Math.floor(((float)scores.get(firstIndex+i) / maxScaleY) * nbLines);

      for (int j = 0 ; j < nbBlocs ; ++j)
      {
        pg.rect(posX[i], h - 2 - (blockHeight + 1) * (j + 1), 
                blocksWidth[i], blockHeight);
      }
    }
  }
}