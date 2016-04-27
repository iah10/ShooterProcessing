class Bullet 
{
  /**** INSTANCE FILEDS ****/

  private double x;
  private double y;
  private int type;
  private int r;

  private double rad;
  private double speed;
  private int power;
  private double dx;
  private double dy;

  private color color1;
  private color color2;
  /**********************/

  
  public Bullet(double angle, int x, int y,int radius, int power,int tpye)
  {
    this.x = x;
    this.y = y;
    type = tpye;
    r = radius;

    rad = Math.toRadians(angle);
    this.power = power;
    speed= 10;
    dx = Math.cos(rad)*speed;
    dy = Math.sin(rad)*speed;
    
    color1 = color(0, 255, 255); //yellow
    color2 = color(0);

  }

  /**----------------------------------------------functions---------------------------------------------------------**/

  public double getX() { return x; }
  public double getY() { return y; }
  public double getR() { return r; }
  public int getType() { return type; }
  public int getPower() { return power; }

  public void setR(int r) { this.r =r; }
  public void setPower(int pow){ power = pow; }
  
  public boolean update()
  {
    x += dx;
    y += dy;

    if( x < -r || x > width + r || y < -r  || y > height + r)
      return true;
    return false;

  }
 
  public void drawBullet()
  {
    if(type != 0)  //type zero is for the enemy of the last level
    {
      fill(color1);
      ellipse((int)(x-r), (int)(y-r), 2*r, 2*r);
    }
    else
    {
      fill(color2);
      rect((int)(x-r), (int)(y-r), 2*r, 2*r);
    }
  }
}