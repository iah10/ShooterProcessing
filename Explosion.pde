class Explosion
{
  /**** INSTANCE FIELDS ****/
  private double x;
  private double y;
  private int r;
  private int maxRadius;
  /************************/

 
  public Explosion(double x, double y, int r, int maxRadius) 
  {
    this.x = x;
    this.y = y;
    this.r = r;
    this.maxRadius = maxRadius;
  }


  public boolean update()
  {
    r +=3;
    if(r >=maxRadius)
      return true;
    return false;
  }

  public void drawExplosion()
  {
    color c = color(255);
    fill(c);
    strokeWeight(2);
    noFill();
    ellipse((int)(x-r), (int)(y-r), 2*r, 2*r);
    fill(c);
    strokeWeight(1);
  }
}