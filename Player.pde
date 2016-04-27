class Player 
{
  /**** INSTANCE FILEDS ****/
  private int x;
  private int y;
  private int r;  // radius (the player is going to be a circle)

  private int dx;
  private int dy;
  private int speed; 

  private boolean firing;
  private long firingTimer;
  private long firingDelay;

  private boolean recovering;
  private long recoveryTimer;

  private boolean invicible;
  public long invincibleTimer;
  public long invincibleTimeDiff;
  public int invicibleLength = 6000;

  private boolean left;  
  private boolean right;
  private boolean up; 
  private boolean down; 

  private int lives;
  private int score;

  private int powerLevel;
  private int power;
  private int[] requiredPower = {1,2,3,4,5};

  private color color1;
  private color color2;
  private color color3;

  /**************************/

  /**
   * The Constructor
   */
  public Player()
  {
    x = width/2;
    y = height /2;
    r = 5;

    dx = 0;
    dy = 0;
    speed = 5;

    lives = 3;
    color1 = color(255);
    color2 = color(0, 255, 0);
    color3 = color(244,204,153);
    
    firing = false;
    firingTimer = System.nanoTime();
    firingDelay = 200;

    recovering = false;
    recoveryTimer = 0;

    score =0;

  }

  /**----------------------------------------------functions---------------------------------------------------------**/

  public int getX() { return x; }
  public int getY() { return y; }
  public int getR() { return r; }

  public int getLives() {  return lives; }
  public int getScore() { return score; }

  public int getPowerLevel() { return powerLevel; }
  public int getPower(){ return power; }
  public int getRequiredPower(){ return requiredPower[powerLevel]; }
 

  public boolean isDead(){ return lives <= 0; }
  public boolean isRecovering() {return recovering; }


  public void setLeft(boolean left) { this.left = left; }
  public void setRight(boolean right) { this.right = right; }
  public void setUp(boolean up) { this.up = up; }
  public void setDown(boolean down) { this.down = down; }
  public void setScore(int score) { this.score = score; }

  public void setFiring(boolean firing) {  this.firing = firing; }

  public void addScore(int i ) { score +=i; }

  public void loseLife()
  {
    lives--;
    recovering = true;
    recoveryTimer = System.nanoTime();
  }

  public void invincible()
  {
    invicible = true;
    invincibleTimer = System.nanoTime();
  }

 
  public void gainLife() {
    lives++;
  }

  
  public void increasePower(int i) 
  {
    power +=i;
    if(powerLevel == 4)
    {
      if(power > requiredPower[powerLevel])
        power = requiredPower[powerLevel];
      return;
    }
    if(power >= requiredPower[powerLevel])
    {
      power -= requiredPower[powerLevel];
      powerLevel++;
    }
  }

  
  public void update()
  {
    if(left)  dx = -speed;
    if(right) dx = speed;
    if(up)    dy = -speed;
    if(down)  dy = speed;

    x += dx;
    y += dy;

    if(x < r) x +=r;//left
    if(y < r) y += r;// up
    if(x > width -r)  x = width -r;  //right
    if(y > height -r) y = height -r;//down

    dx =0; 
    dy =0;

    if(firing)
    {
      long elapsed = (System.nanoTime() - firingTimer)/1000000;
      if(elapsed > firingDelay)
      {
        firingTimer = System.nanoTime();
        if(powerLevel < 2)
        {
          if(TheGame.bulletPowerTimer != 0)  //During bullet power up
            TheGame.bullets.add(new Bullet(270, x,y,3,3, 1));
          else
            TheGame.bullets.add(new Bullet(270, x,y,2,1,1));
        }
        else if(powerLevel < 4) 
        {
          if(TheGame.bulletPowerTimer != 0)  //During bullet power up
          {
            TheGame.bullets.add(new Bullet(270, x+5,y,3,3,1));
            TheGame.bullets.add(new Bullet(270, x-5,y,3,3,1));
          }
          else 
          {
            TheGame.bullets.add(new Bullet(270, x+5,y,2,1,1));
            TheGame.bullets.add(new Bullet(270, x-5,y,2,1,1));
          }
        }
        else
        {
          if(TheGame.bulletPowerTimer != 0)  //During bullet power up
          {
            TheGame.bullets.add(new Bullet(270, x+5,y,3,3,1));
            TheGame.bullets.add(new Bullet(277, x-5,y,3,3,1));
            TheGame.bullets.add(new Bullet(263, x+5,y,3,3,1));
          }
          else
          {
            TheGame.bullets.add(new Bullet(270, x+5,y,2,1,1));
            TheGame.bullets.add(new Bullet(277, x-5,y,2,1,1));
            TheGame.bullets.add(new Bullet(263, x+5,y,2,1,1));
          }
        }

      }
    }
    if(recovering)
    {
      long elapsed = (System.nanoTime() - recoveryTimer)/1000000;
      if(elapsed > 2000)
      {
        recovering =false;
        recoveryTimer = 0;
      }
    }
    if(invicible)
    {
      invincibleTimeDiff = (System.nanoTime() - invincibleTimer)/1000000;
      if(invincibleTimeDiff > invicibleLength)
      {
        invicible =false;
        invincibleTimer = 0;
      }
    }

  }

  
  public void drawPlayer()
  {
    color c = recovering ? color2: (invicible ? color3: color1);
    fill(c);
    ellipse(x-r, y-r, 2*r, 2*r);
    strokeWeight(3); //makes our lines 3 pixels wide
   fill(darker(c));
    ellipse(x-r, y-r, 2*r, 2*r);
    strokeWeight(1);
  }
  
  public color darker(color c) {
    float FACTOR = 0.7;
        return color(Math.max((int)(red(c)  *FACTOR), 0),
                         Math.max((int)(green(c)*FACTOR), 0),
                         Math.max((int)(blue(c) *FACTOR), 0));
    }

}