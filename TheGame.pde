/*------ INSATNACE FIELDS ------*/

boolean running;

Player player; 
static ArrayList<Bullet> bullets;
static ArrayList<Enemy> enemies;
public ArrayList<PowerUp> powerUps;
static ArrayList<Explosion> explosions;
public ArrayList<Text> texts; 

public  long waveStartTimer;
private long waveStartTimerDiff;  // to keep track of how much time has passed by
public  int waveNumber;
private boolean waveStart;      // whether to start creating enemies or not
private int waveDelay = 2000;

public  long slowDownTimer;      //for the slow down timer power up
private long slowDownTimerDiff;
private int slowDownLength = 6000;
private  boolean slow;

public  long ExplosionTimer;      //for the explosion
private long explosionTimerDiff;
private int explosionLength = 1500;
private  boolean explodeIn;

public  long fastTimer;      //for time level-6
private long fastTimerDiff;
private int fastLength = 15000;

static long bulletPowerTimer;
private long bulletPowerTimerDiff;
private int bulletPowerLength = 6000;

public String s = "Congratulations!" + "\n" + "YOU WON :-)";
/*------------------------------------------------------------------------*/


void setup() {
  running = true;
  player = new Player();
  bullets = new ArrayList<Bullet>();
  enemies = new ArrayList<Enemy>();
  powerUps = new ArrayList<PowerUp>();
  explosions = new ArrayList<Explosion>();
  texts = new ArrayList<Text>();
  frameRate(45);
  frame.requestFocus();
  size(400, 400);
}

void draw()
{
  if (running) 
  {
    update();
    drawState();
  } else {
    gameOver();
  }
}



public void update() {

  //new wave
  if (waveStartTimer ==0 && enemies.size() ==0) {
    waveNumber++;
    waveStart = false;
    waveStartTimer= System.nanoTime();
  } else {
    waveStartTimerDiff = (System.nanoTime() - waveStartTimer)/1000000;
    if (waveStartTimerDiff > waveDelay) {
      waveStart =true;
      waveStartTimer =0;
      waveStartTimerDiff =0;
    }
  }

  //create enemies
  if (waveStart && enemies.size()==0)
    createEneimies();

  //player update
  player.update(); 

  //bullets update
  for (int i=0; i< bullets.size(); i++)
    if ( bullets.get(i).update())
      bullets.remove(i);
  //enemies update
  for (int i=0; i< enemies.size(); i++)
    enemies.get(i).update();

  //power-up update
  for (int i = 0; i < powerUps.size(); i++) 
    if (powerUps.get(i).update())
      powerUps.remove(i);
  //explosion update 
  for (int i = 0; i < explosions.size(); i++) 
    if (explosions.get(i).update())
      explosions.remove(i);
  // text update
  for (int i=0; i < texts.size(); i++)
    if (texts.get(i).update())
      texts.remove(i);
  //bullet-enemy collision/player-bullet collision
  for (int i = 0; i < bullets.size(); i++) 
  {
    Bullet  b = bullets.get(i);
    double bx = b.getX();
    double by = b.getY();
    double br = b.getR();

    for (int j=0; j < enemies.size(); j++)
    {
      Enemy e = enemies.get(j);
      double ex = e.getX();
      double ey = e.getY();
      double er = e.getR();
      /** Check for collision by Pythagoras theorem **/
      double dx = bx -ex;
      double dy = by -ey;
      double dist = Math.sqrt(dx*dx + dy*dy);
      if (dist < br + er)
      {
        e.hit(bullets.get(i).getPower());
        bullets.remove(i);
        break;
      }
    }
  }

  //check for dead enemies
  for (int j=0; j < enemies.size(); j++)
  {
    Enemy e = enemies.get(j);
    if (e.isDead())
    {
      powerUp(e);
      player.addScore(e.getRank() + e.getType());
      enemies.remove(j);
      e.explode();
      explosions.add(new Explosion(e.getX(), e.getY(), e.getR(), e.getR()+30));
    }
  }

  // check dead player
  if (player.isDead()) 
  {
    running = false;
    s = "G A M E   O V E R   YOU LOSE   :-(";
  }

  /** Player Coordinates **/
  int px = player.getX();
  int py = player.getY();
  int pr = player.getR();

  //check player-enemy collision
  if (!player.isRecovering())
  {
    for (int i = 0; i < enemies.size(); i++) 
    {
      Enemy e = enemies.get(i);
      double ex = e.getX();
      double ey = e.getY();
      double er = e.getR();
      /** Check for collision by Pythagoras theorem **/
      double dx = px -ex;
      double dy = py - ey;
      double dist = Math.sqrt(dx*dx + dy*dy);
      if (dist < pr + er && player.invincibleTimer ==0)
        player.loseLife();
      else if (dist < pr + er && player.invincibleTimer !=0)
        e.hit(2);
    }
  }

  //player-power-up collision
  for (int i = 0; i < powerUps.size(); i++) 
  {
    PowerUp e = powerUps.get(i);
    double ex = e.getX();
    double ey = e.getY();
    double er = e.getR();
    /** Check for collision by Pythagoras theorem **/
    double dx = px -ex;
    double dy = py - ey;
    double dist = Math.sqrt(dx*dx + dy*dy);
    //collected power-up
    if (dist < pr + er)
    {
      switch (e.getType()) 
      {
      case 1:  // +life
        player.gainLife();
        texts.add(new Text(player.getX(), player.getY(), 200, "Extra Life"));
        break;
      case 2:  // +1 power
        player.increasePower(1);
        texts.add(new Text(player.getX(), player.getY(), 200, "Power"));
        break;
      case 3:  // +2 power
        player.increasePower(2);
        texts.add(new Text(player.getX(), player.getY(), 200, "Double Power"));
        break;
      case 4:  // Freeze
        slowDownTimer = System.nanoTime();
        slow = true;
        for (int j = 0; j < enemies.size(); j++)
          enemies.get(j).setSlow(true);
        texts.add(new Text(player.getX(), player.getY(), 200, "Slow Down"));
        break;
      case 5:  //bullet power ups
        bulletPowerTimer = System.nanoTime();
        for (int j = 0; j < bullets.size(); j++)
        {
          if (bullets.get(j).getType() != 0)
          {
            bullets.get(j).setPower(3);
            bullets.get(j).setR(3);
          }
        }
        texts.add(new Text(player.getX(), player.getY(), 200, "Bullet Power"));
        break;
      case 6: // invincible
        player.invincible();
        texts.add(new Text(player.getX(), player.getY(), 200, "Invincible"));
        break;
      case 7:  //kill all
        for (int j = 0; j < enemies.size(); j++)
          enemies.get(j).hit((int) enemies.get(j).getHealth());
        ExplosionTimer = System.nanoTime();
        explodeIn = true;
        texts.add(new Text(player.getX(), player.getY(), 200, "Boom"));
        break;
      }
      powerUps.remove(i);
    }
  }
  // slow down update
  if (slowDownTimer !=0)
  {
    slowDownTimerDiff = (System.nanoTime() - slowDownTimer)/1000000;
    if (slowDownTimerDiff > slowDownLength)
    {
      slowDownTimer = 0;
      slow = false;
      for (int j = 0; j < enemies.size(); j++)
        enemies.get(j).setSlow(slow);
    }
  }

  // bulletPower update
  if (bulletPowerTimer !=0)
  {
    bulletPowerTimerDiff = (System.nanoTime() - bulletPowerTimer)/1000000;
    if (bulletPowerTimerDiff > bulletPowerLength)
    {
      bulletPowerTimer = 0;
      for (int j = 0; j < bullets.size(); j++)
      {
        bullets.get(j).setPower(1);
        bullets.get(j).setR(2);
      }
    }
  }

  //boom update
  if (explodeIn) 
  {
    explosionTimerDiff = (System.nanoTime() - ExplosionTimer)/1000000;
    if (explosionTimerDiff > explosionLength)
    {
      ExplosionTimer = 0;
      explodeIn = false;
    }
  }

  //fast update - level 6
  if (fastTimer != 0)
  {
    fastTimerDiff = (System.nanoTime() - fastTimer)/1000000;
    if (fastTimerDiff > fastLength && enemies.size() !=0)
    {
      fastTimer=0;
      player.loseLife();
      waveNumber--;
      enemies.clear();
    }
  }
}

void gameOver() 
{
  fill(color(0, 100, 255));
  rect(0, 0, width, height);
  fill(color(255));
  textFont(createFont("Century Gothic", 16, true));
  //int length = (int) g.getFontMetrics().getStringBounds(TheGame.s, g).getWidth();
  text(s, (width/*-length*/)/2, height/2);
  text("Final Score: " + player.getScore(), (width/*-length*/)/2, height/2 + 30);
}

void drawState() 
{
  //draw Background
  fill(color(0, 100, 255));
  rect(0, 0, width, height);

  //draw slow down and bullet and invincible  screen
  if (slowDownTimer != 0 && bulletPowerTimer != 0 && player.invincibleTimer != 0)
  {
    int alpha  = (int)(255*Math.sin(3.14 * bulletPowerTimerDiff/ bulletPowerLength));  //for transparency
    if (alpha > 255) alpha = 255;
    if (alpha <0) alpha = 0;
    fill(color(153, 0, 204, alpha));
    rect(0, 0, width, height);
    textFont( createFont("Century Gothic", 18, true));
    String s = "SUPER MODE";
    //int length = (int)g.getFontMetrics().getStringBounds(s, g).getWidth();   //get the length of the screen in pixels
    fill(color(255, 255, 255, alpha));
    text(s, width/2 /*-length/2*/, height /2);
  }

  //draw slow down and invincible screen
  else if (slowDownTimer != 0 && player.invincibleTimer != 0)
  {
    int alpha  = (int)(255*Math.sin(3.14 * slowDownTimerDiff/ slowDownLength));  //for transparency
    if (alpha > 255) alpha = 255;
    if (alpha <0) alpha = 0;
    fill(color(155, 102, 153, alpha));
    rect(0, 0, width, height);
    textFont( createFont("Century Gothic", 18, true));
    String s = "SLOW-DOWN  & Invinsible MODE";
    //int length = (int)g.getFontMetrics().getStringBounds(s, g).getWidth();   //get the length of the screen in pixels
    fill(color(255, 255, 255, alpha));
    text(s, width/2 /*-length/2*/, height /2);
  }
  //draw slow down and invincible screen
  else if (bulletPowerTimer != 0 && player.invincibleTimer != 0)
  {
    int alpha  = (int)(255*Math.sin(3.14 * bulletPowerTimerDiff/ bulletPowerLength));  //for transparency
    if (alpha > 255) alpha = 255;
    if (alpha <0) alpha = 0;
    fill(color(255, 204, 0, alpha));
    rect(0, 0, width, height);
    textFont(createFont("Century Gothic", 18, true));
    String s = "Invicible  & BULLET-POWER MODE";
    //int length = (int)g.getFontMetrics().getStringBounds(s, g).getWidth();   //get the length of the screen in pixels
    fill(color(255, 255, 255, alpha));
    text(s, width/2 /*-length/2*/, height /2);
  }
  //draw slow down and bullet power screen
  else if (bulletPowerTimer != 0 &&  slowDownTimer != 0)
  {
    int alpha  = (int)(255*Math.sin(3.14 * bulletPowerTimerDiff/ bulletPowerLength));  //for transparency
    if (alpha > 255) alpha = 255;
    if (alpha <0) alpha = 0;
    fill(color(255, 255, 255, alpha));
    rect(0, 0, width, height);
    textFont( createFont("Century Gothic", 18, true));
    String s = "SLOWDOWN  & BULLET-POWER MODE";
    //int length = (int)g.getFontMetrics().getStringBounds(s, g).getWidth();   //get the length of the screen in pixels
    fill(color(255, 255, 255, alpha));
    text(s, width/2/*-length/2*/, height /2);
  }

  //draw slow down screen
  else if (slowDownTimer != 0)
  {
    int alpha  = (int)(255*Math.sin(3.14 * slowDownTimerDiff/ slowDownLength));  //for transparency
    if (alpha > 255) alpha = 255;
    if (alpha <0) alpha = 0;
    fill(color(153, 0, 51, alpha));
    rect(0, 0, width, height);
    textFont( createFont("Century Gothic", 18, true));
    String s = "SLOW-DOWN MODE";
    //int length = (int)g.getFontMetrics().getStringBounds(s, g).getWidth();   //get the length of the screen in pixels
    fill(color(255, 255, 255, alpha));
    text(s, width/2/*-length/2*/, height /2);
  }

  //draw slow down screen
  else if (fastTimer != 0)
  {
    int alpha  = (int)(255*Math.sin(3.14 * fastTimerDiff/fastLength));  //for transparency
    if (alpha > 255) alpha = 255;
    if (alpha <0) alpha = 0;
    fill(color(153, 0, 51, alpha));
    rect(0, 0, width, height);
    textFont( createFont("Century Gothic", 18, true));
    String s = "TIMED-LEVEL";
    //int length = (int)g.getFontMetrics().getStringBounds(s, g).getWidth();   //get the length of the screen in pixels
    fill(color(200, 155, 35, alpha));
    text(s, width/2 /*-length/2*/, height /2);
  }

  //draw invincible mode
  else if (player.invincibleTimer != 0)
  {
    int alpha  = (int)(255*Math.sin(3.14 * player.invincibleTimeDiff/ player.invicibleLength));  //for transparency
    if (alpha > 255) alpha = 255;
    if (alpha <0) alpha = 0;
    fill(color(51, 204, 204, alpha));
    rect(0, 0, width, height);
    textFont( createFont("Century Gothic", 18, true));
    String s = "INVINCIBLE MODE";
    //int length = (int)g.getFontMetrics().getStringBounds(s, g).getWidth();   //get the length of the screen in pixels
    fill(color(255, 255, 255, alpha));
    text(s, width/2 /*-length/2*/, height /2);
  }

  //draw bullet power screen
  else if (bulletPowerTimer != 0)
  {
    int alpha  = (int)(255*Math.sin(3.14 * bulletPowerTimerDiff/ bulletPowerLength));  //for transparency
    if (alpha > 255) alpha = 255;
    if (alpha <0) alpha = 0;
    fill(color(0, 100, 70, alpha));
    rect(0, 0, width, height);
    textFont( createFont("Century Gothic", 18, true));
    String s = "BULLET-POWER MODE";
    //int length = (int)g.getFontMetrics().getStringBounds(s, g).getWidth();   //get the length of the screen in pixels
    fill(color(255, 255, 255, alpha));
    text(s, width/2 /*-length/2*/, height /2);
  }
  if (explodeIn)
  {
    int alpha  = (int)(255*Math.sin(3.14 * explosionTimerDiff/ explosionLength));  //for transparency
    if (alpha > 255) alpha = 255;
    if (alpha <0) alpha = 0;
    fill(color(255, 255, 255, alpha));
    textFont( createFont("Century Gothic", 28, true));
    String s = "!!!!  BoOoOoOoOoOoM  !!!!";
    //int length = (int)g.getFontMetrics().getStringBounds(s, g).getWidth();   //get the length of the screen in pixels
    text(s, width/2/*-length/2*/, height /2 - 40);
  }

  //draw player
  player.drawPlayer();

  //draw bullets
  for (int i=0; i< bullets.size(); i++)
    bullets.get(i).drawBullet();

  //draw enemies
  for (int i=0; i< enemies.size(); i++)
    enemies.get(i).drawEnemy();

  //draw power-ups
  for (int i = 0; i < powerUps.size(); i++)
    powerUps.get(i).drawPowerUp();

  //draw explosions
  for (int i = 0; i < explosions.size(); i++)
    explosions.get(i).drawExplosion();

  //draw texts
  for (int i = 0; i < texts.size(); i++)
    texts.get(i).drawText();

  //draw wave number
  if (waveStartTimer != 0)
  {
    textFont(createFont("Century Gothic", 18, true));
    String s = "-W A V E " + waveNumber + "  -";
    //int length = (int)g.getFontMetrics().getStringBounds(s, g).getWidth();   //get the length of the screen in pixels
    int alpha  = (int)(255*Math.sin(3.14 * waveStartTimerDiff / waveDelay));  //for transparency
    if (alpha > 255) alpha = 255;
    if (alpha <0) alpha = 0;
    fill(color(255, 255, 255, alpha));
    text(s, width/2/*-length/2*/-10, 60);
  }

  //draw player lives 
  for (int i =0; i < player.getLives(); i++) 
  {
    fill(255);
    ellipse(20+(20*i), 20, player.getR()*2, player.getR()*2);
    strokeWeight(3);
    fill(darker(color(255)));
    ellipse(20+(20*i), 20, player.getR()*2, player.getR()*2);
    strokeWeight(1);
  }

  //draw player-power;
  fill(255, 255, 0);
  rect(20, 40, player.getPower()*8, 8);
  fill(darker(color(255, 255, 0)));
  strokeWeight(2);
  for (int i=0; i< player.getRequiredPower(); i++)
    rect(20+8*i, 40, 8, 8);
  rect(20, 40, player.getPower()*8, 8);
  strokeWeight(1);

  //draw player score
  fill(255);
  textFont( createFont("Century Gothic", 14, true));
  text("Score: "+ player.getScore(), width-100, 30);


  //draw level number
  text("Level: "+ waveNumber, width-100, 50);

  //draw slow down meter
  if (slowDownTimer != 0) 
  {
    fill(255);
    rect(20, 60, 100, 8);
    rect(20, 60, (int) (100 - 100*slowDownTimerDiff / slowDownLength), 8);
  }

  //draw slow down meter
  if (bulletPowerTimer != 0) 
  {
    fill(255, 255, 0);
    rect(20, 80, 100, 8);
    rect(20, 80, (int) (100 - 100*bulletPowerTimerDiff / bulletPowerLength), 8);
  }

  //fast down meter
  if (fastTimer != 0) 
  {
    fill(255);
    textFont( createFont("Century Gothic", 14, true));
    text("Time: ", width-105, 65);
    fill(255, 0, 255);
    rect(width-105, 69, 100, 8);
    rect(width-105, 69, (int) (100 - 100*fastTimerDiff / fastLength), 8);
  }

  //draw invincible meter
  if (player.invincibleTimer != 0) 
  {
    fill(0, 255, 255);
    rect(20, 100, 100, 8);
    rect(20, 100, (int) (100 - 100*player.invincibleTimeDiff / player.invicibleLength), 8);
  }
}

private void powerUp(Enemy e) 
{
  //chance for power-up
  double rand = Math.random();
  if (rand < 0.005) 
    powerUps.add(new PowerUp(e.getX(), e.getY(), 7));
  else if (rand < 0.008) 
    powerUps.add(new PowerUp(e.getX(), e.getY(), 1));
  else if (rand < 0.020)
    powerUps.add(new PowerUp(e.getX(), e.getY(), 3));
  else if (rand < 0.06 && waveNumber >=4)
    powerUps.add(new PowerUp(e.getX(), e.getY(), 5));
  else if (rand < 0.1) 
    powerUps.add(new PowerUp(e.getX(), e.getY(), 2));
  else if (rand < 0.12) 
    powerUps.add(new PowerUp(e.getX(), e.getY(), 4));
  else if (rand < 0.15 && waveNumber >=5)//invisible starting level 5
    powerUps.add(new PowerUp(e.getX(), e.getY(), 6));
}

public color darker(color c) {
  float FACTOR = 0.7;
  return color(Math.max((int)(red(c)  *FACTOR), 0), 
    Math.max((int)(green(c)*FACTOR), 0), 
    Math.max((int)(blue(c) *FACTOR), 0));
}

/**
 * Create new enemies(the game has 8 levels)
 */
private void createEneimies() 
{
  enemies.clear();
  if (waveNumber ==1)
    for (int i=0; i< 5; i++)
      enemies.add(new Enemy(1, 1, slow));
  if (waveNumber ==2)
  {
    for (int i=0; i< 8; i++)
      enemies.add(new Enemy(1, 1, slow));
  }
  if (waveNumber==3) 
  {
    for (int i=0; i< 6; i++)
      enemies.add(new Enemy(1, 1, slow));
    enemies.add(new Enemy(1, 2, slow));
    enemies.add(new Enemy(1, 2, slow));
  }
  if (waveNumber==4) 
  {
    for (int i=0; i< 4; i++)
      enemies.add(new Enemy(2, 1, slow));
    enemies.add(new Enemy(1, 4, slow));
  }
  if (waveNumber==5) 
  {
    for (int i=0; i< 4; i++)    //4 fast
      enemies.add(new Enemy(4, 1, slow));
  }
  if (waveNumber==6) 
  {
    enemies.add(new Enemy(4, 2, slow));  //very fast
    fastTimer = System.nanoTime();
  }
  if (waveNumber==7) 
  {
    fastTimer=0;
    enemies.add(new Enemy(1, 4, slow));
    enemies.add(new Enemy(1, 3, slow));
    enemies.add(new Enemy(2, 3, slow));
  }
  if (waveNumber==8) 
  {
    for (int i=0; i< 4; i++)
    {
      enemies.add(new Enemy(2, 1, slow));
      enemies.add(new Enemy(3, 1, slow));
    }
    enemies.add(new Enemy(1, 3, slow));
  }
  if (waveNumber==9) 
  {
    enemies.add(new Enemy(1, 3, slow));
    enemies.add(new Enemy(2, 3, slow));
    enemies.add(new Enemy(3, 3, slow));
  }
  if (waveNumber==10) 
  {
    enemies.add(new Enemy(1, 4, slow));
    enemies.add(new Enemy(2, 4, slow));
    enemies.add(new Enemy(3, 4, slow));
  }
  if (waveNumber==11)
    running=false;
}

public void keyPressed() 
{
  if (key == 'z') {
    player.setFiring(true);
  } else {
    switch (keyCode) 
    {
    case LEFT:
      player.setLeft(true);
      break;
    case RIGHT: 
      player.setRight(true);
      break;
    case UP:
      player.setUp(true);
      break;
    case DOWN:
      player.setDown(true);
      break;
    }
  }
}


public void keyReleased() 
{
  if (key == 'z') {
    player.setFiring(false);
  } else {

    switch (keyCode) 
    {
    case LEFT:
      player.setLeft(false);
      break;
    case RIGHT:
      player.setRight(false);
      break;
    case UP:
      player.setUp(false);
      break;
    case DOWN:
      player.setDown(false);
      break;
    }
  }
}