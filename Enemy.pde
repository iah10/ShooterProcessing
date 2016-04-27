class Enemy 
{
  /**** INSTANCE FIELDS ****/
  protected double x;
  protected double y;
  private int r;

  protected double dx;
  protected double dy;
  protected double rad;
  protected double speed;

  protected int health;
  private int type;
  private int rank;

  private color color1;
  private color color1Darker;
  private color darkerWhite = color(193, 205, 193);

  private boolean ready;
  protected boolean dead;
  protected boolean hit;
  protected long hitTimer;

  protected boolean slow;
  /************************/


  public Enemy(int type, int rank, boolean slow)
  {
    this.type = type;
    this.rank = rank;
    this.slow = slow;
    if (type==1)
    {
      //BLUE;
      color1 = color(0, 0, 100, 128);
      color1Darker =   color(25, 25, 112);
      if (rank ==1)
      {
        speed = 2;
        r = 5;
        health = 1;
      }
      if (rank ==2)
      {
        speed=2;
        r=10;
        health= 2;
      }
      if (rank ==3)
      {
        speed=1.5;
        r=20;
        health= 3;
      }
      if (rank ==4)
      {
        speed=1.5;
        r=30;
        health= 4;
      }
    }
    //stronger , faster 
    if (type==2)
    {
      //RED;
      color1 = color(255, 0, 0, 128);
      if (rank ==1)
      {
        speed=8;
        r=5;
        health =2;
      }
      if (rank ==2)
      {
        speed=5;
        r=10;
        health= 3;
      }
      if (rank ==3)
      {
        speed=5;
        r=20;
        health= 3;
      }
      if (rank ==4)
      {
        speed=5;
        r=30;
        health= 4;
      }
    }
    //slow, but hard to kill
    if (type==3)
    {
      //GREEN;
      color1 = color(0, 255, 0, 128);
      if (rank ==1)
      {
        speed=1.5;
        r=5;
        health =5;
      }
      if (rank ==2)
      {
        speed=1.5;
        r=10;
        health= 6;
      }
      if (rank ==3)
      {
        speed=1.5;
        r=25;
        health= 7;
      }
      if (rank ==4)
      {
        speed=1.5;
        r=45;
        health= 8;
      }
    }
    if (type==4) 
    {
      if (rank==1) {
        //gray
        color1 = color(200, 200, 200);
        speed = 15;
        health = 2;
        r = 4;
      } else
      {
        color1 = color(255, 165, 0);
        speed = 20;
        health = 4;
        r = 4;
      }
    }
    x = random(1) * width/2 + width /4;
    y = -r;

    double angle = random(1) * 140 +20;
    rad = Math.toRadians(angle);

    dx = cos((float)rad) * speed;
    dy = sin((float)rad) * speed;
  }

  public double getX() { 
    return x;
  }
  public double getY() { 
    return y;
  }
  public int getR() { 
    return r;
  }
  public int getType() { 
    return type;
  }
  public int getRank() { 
    return rank;
  }
  public boolean getSlow() { 
    return slow;
  }
  public boolean isDead() { 
    return dead;
  } 
  public double getHealth() { 
    return health;
  }

  public void setSlow(boolean b) { 
    slow = b;
  }


  
  public void hit(int power)
  {
    health-=power;
    if (health <=0)
      dead =true;
    hit = true;
    hitTimer = System.nanoTime();
  }

  
  public void explode()
  {
    if (rank > 1)
    {
      int amount =0;
      if (type == 1 || type==2) 
        amount = 3;
      if (type == 3) 
        amount = 4;

      for (int i=0; i < amount; i++)
        newEnemies();
    }
  }

  public void newEnemies() 
  {
    Enemy e = new Enemy(getType(), getRank()-1, getSlow());
    e.x= this.x;
    e.y = this.y;
    double angle = 0;

    if (!ready)
      angle = Math.random()*140 +20;
    else 
    angle = Math.random() * 360;

    e.rad = Math.toRadians(angle);
    TheGame.enemies.add(e);
  }


  public void update()
  {
    if (slow)
    {
      x += dx * 0.3;
      y += dy * 0.3;
    } else 
    {
      x+= dx;
      y += dy;
    }
    if (!ready && x > r && x < width -r && y > r && y <height - r) 
      ready = true;
    if (x < r && dx < 0) dx = -dx;
    if (y < r && dy < 0) dy = -dy;
    if (x > width -r && dx > 0) dx = -dx;
    if (y > height -r && dy > 0) dy = -dy;

    if (hit) 
    {
      long elapsed = (System.nanoTime() - hitTimer)/1000000;
      if (elapsed > 50)
      {
        hit = false;
        hitTimer=0;
      }
    }
  }

  
  public void drawEnemy()
  {
    if (hit) {
      fill(255); 
      ellipse((int)(x-r), (int)(y-r), 2*r, 2*r);
      strokeWeight(3);
      fill(darkerWhite);
      ellipse((int)(x-r), (int)(y-r), 2*r, 2*r);
      strokeWeight(1);
    } else {
      fill(color1);
      ellipse((int)(x-r), (int)(y-r), 2*r, 2*r);
      strokeWeight(3);
      fill(color1Darker);
      ellipse((int)(x-r), (int)(y-r), 2*r, 2*r);
      strokeWeight(1);
    }
  }
}