class Text 
{
  /**** INSTANCE FIELDS ****/
  private double x;
  private double y;
  private long time;
  private String s;
  private long start;
  private PFont century;
  /************************/

  
  public Text(double x, double y, long time, String s) 
  {
    this.x = x;
    this.y = y;
    this.time = time;
    this.s = s;
    start = System.nanoTime();
    century = createFont("Century Gothic", 12, true);
  }

  public boolean update()
  {
    long elapsed = (System.nanoTime() - start)/1000000;
    if (elapsed > time)
      return true;
    return false;
  }

  
  public void drawText()
  {
    textFont(century);
    long elapsed = (System.nanoTime() - start)/1000000;
    int alpha = (int)(255*Math.sin(3.14 *elapsed/time));
    if (alpha >=255 || alpha <= 0) alpha = 254;
    fill(color(255, 255, 255, alpha));
    text(s, (int)x, (int) y);
  }
}