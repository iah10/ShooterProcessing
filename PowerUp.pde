class PowerUp
{
  /**** INSTANCE FIELDS ****/
  private double x;
  private double y;
  private int r;

  private int type;

  private color color1;
  private color color2;
  /************************/

  public PowerUp(double x, double y, int type) 
  {
    this.x = x;
    this.y = y;
    this.type = type;

    switch (type) 
    {
    case 1:  // 1-- +1 life
      color1 = color(255, 192, 203); // pink
      r=5;
      break;
    case 2:  //2 -- +1 power
      color1 = color(255, 255, 0); //yellow 
      r=3;
      break;
    case 3: //3 -- +3 power
      color1 = color(255, 255, 0); //yellow 
      r=5;
      break;
    case 4: // 4--slow down time
      color1 = color(255);
      r=3;
      break;
    case 5: // 5--powers the bullet
      color1 = color(0, 255, 0); //green
      r=4;
      break;
    case 6:  //6--makes the enemy invincible against bullets and enemies
      color1 = color(0, 255, 255); //cyan
      r = 4;
      break;
    case 7:  //7--kills all the enemies except the monsters
      color1 = darker(color(255, 0 , 0));
      color2 = color(255, 255, 0);
      r =10;
      break;
    }

  }

  public double getX() { return x; }
  public double getY() { return y; }
  public int getR() { return r; }
  public int getType() { return type; }

  
  public boolean update()
  {
    y+=2;
    if(y> height +r)
      return true;
    return false;
  }

  
  public void drawPowerUp()
  {
    fill(color1);
    rect((int)(x-r), (int)(y-r), 2*r, 2*r);
    strokeWeight(3);
    if(getType() == 7)
      fill(color2);
    else
      fill(darker(color1));
    rect((int)(x-r), (int)(y-r), 2*r, 2*r);
    strokeWeight(1);
  }
  
  public color darker(color c) {
    float FACTOR = 0.7;
        return color(Math.max((int)(red(c)  *FACTOR), 0),
                         Math.max((int)(green(c)*FACTOR), 0),
                         Math.max((int)(blue(c) *FACTOR), 0));
    }
}