import ddf.minim.*;

Minim minim;
static AudioPlayer shoot;
AudioPlayer explode;
AudioPlayer powerup;

Player player; 
static ArrayList<Bullet> bullets;
static ArrayList<Enemy> enemies;
static ArrayList<Explosion> explosions;
ArrayList<PowerUp> powerUps;
ArrayList<Text> texts; 

long waveStartTimer, waveStartTimerDiff;
int waveNumber, waveDelay = 2000;
boolean waveStart;      // whether to start creating enemies or not

long slowDownTimer, slowDownTimerDiff;
int slowDownLength = 6000;
boolean slow;

long ExplosionTimer, explosionTimerDiff;
int explosionLength = 1500;
boolean explodeIn;

static long bulletPowerTimer;
long bulletPowerTimerDiff;
int bulletPowerLength = 6000;

boolean running;
String s = "Congratulations!" + "\n" + "YOU WON :-)";

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
  
  minim = new Minim(this);
  shoot = minim.loadFile("Sounds/shoot.mp3");
  explode = minim.loadFile("Sounds/explode.mp3");
  powerup = minim.loadFile("Sounds/extralife.mp3");
}

void draw(){
  if (running) {
    update();
    drawState();
  } else {
    gameOver();
  }
}

void update() {
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

  if (waveStart && enemies.size()==0)
    createEneimies();

  player.update(); 

  for (int i=0; i< bullets.size(); i++)
    if ( bullets.get(i).update())
      bullets.remove(i);
  for (int i=0; i< enemies.size(); i++)
    enemies.get(i).update();
  for (int i = 0; i < powerUps.size(); i++) 
    if (powerUps.get(i).update())
      powerUps.remove(i);
  for (int i = 0; i < explosions.size(); i++) 
    if (explosions.get(i).update())
      explosions.remove(i);
  for (int i=0; i < texts.size(); i++)
    if (texts.get(i).update())
      texts.remove(i);
      
  //bullet-enemy collision
  for (int i = 0; i < bullets.size(); i++) {
    Bullet  b = bullets.get(i);
    double bx = b.x;
    double by = b.y;
    double br = b.r;

    for (int j=0; j < enemies.size(); j++){
      Enemy e = enemies.get(j);
      double ex = e.x;
      double ey = e.y;
      double er = e.r;
      double dist = dist((float)bx, (float)by, (float)ex, (float)ey);
      if (dist < br + er){
        e.hit(bullets.get(i).power);
        bullets.remove(i);
        break;
      }
    }
  }

  //check for dead enemies
  for (int j=0; j < enemies.size(); j++){
    Enemy e = enemies.get(j);
    if (e.dead){
      powerUp(e);
      player.addScore(e.rank + e.type);
      enemies.remove(j);
      e.explode();
      explosions.add(new Explosion(e.x, e.y, e.r, e.r+30));
    }
  }

  // check dead player
  if (player.isDead()) {
    running = false;
    s = "G A M E   O V E R   YOU LOSE   :-(";
  }

  /** Player Coordinates **/
  int px = player.x;
  int py = player.y;
  int pr = player.r;

  //check player-enemy collision
  if (!player.recovering){
    for (int i = 0; i < enemies.size(); i++) {
      Enemy e = enemies.get(i);
      double ex = e.x;
      double ey = e.y;
      double er = e.r;
      double dist = dist((float)px, (float)py, (float)ex, (float)ey);
      if (dist < pr + er && player.invincibleTimer ==0)
        player.loseLife();
      else if (dist < pr + er && player.invincibleTimer !=0)
        e.hit(2);
    }
  }

  //player-power-up collision
  for (int i = 0; i < powerUps.size(); i++) {
    PowerUp e = powerUps.get(i);
    double ex = e.x;
    double ey = e.y;
    double er = e.r;
    double dist = dist((float)px, (float)py, (float)(ex+er), (float)(ey+er));
    if (dist < pr + er){
      if(!powerup.isPlaying()){ powerup.rewind(); powerup.play(); }
      switch (e.type) {
      case 1:  // +life
        player.gainLife();
        texts.add(new Text(player.x-30, player.y-30, 200, "Extra Life"));
        break;
      case 2:  // +1 power
        player.increasePower(1);
        texts.add(new Text(player.x-30, player.y-30, 200, "Power"));
        break;
      case 3:  // +2 power
        player.increasePower(2);
        texts.add(new Text(player.x-30, player.y-30, 200, "Double Power"));
        break;
      case 4:  // Slow
        slowDownTimer = System.nanoTime();
        slow = true;
        for (int j = 0; j < enemies.size(); j++)
          enemies.get(j).setSlow(true);
        texts.add(new Text(player.x-30, player.y-30, 200, "Slow Down"));
        break;
      case 5:  //bullet power ups
        bulletPowerTimer = System.nanoTime();
        for (int j = 0; j < bullets.size(); j++){
          bullets.get(j).power = 3;
          bullets.get(j).r = 3;
        }
        texts.add(new Text(player.x-30, player.y-30, 200, "Bullet Power"));
        break;
      case 6: // invincible
        player.invincible();
        texts.add(new Text(player.x-30, player.y-30, 200, "Invincible"));
        break;
      case 7:  //kill all
        for (int j = 0; j < enemies.size(); j++)
          enemies.get(j).hit((int) enemies.get(j).health);
        ExplosionTimer = System.nanoTime();
        explodeIn = true;
        texts.add(new Text(player.x-30, player.y-30, 200, "Boom"));
        break;
      }
      powerUps.remove(i);
    }
  }
  
  // slow down update
  if (slowDownTimer !=0){
    slowDownTimerDiff = (System.nanoTime() - slowDownTimer)/1000000;
    if (slowDownTimerDiff > slowDownLength){
      slowDownTimer = 0;
      slow = false;
      for (int j = 0; j < enemies.size(); j++)
        enemies.get(j).setSlow(slow);
    }
  }

  // bulletPower update
  if (bulletPowerTimer !=0){
    bulletPowerTimerDiff = (System.nanoTime() - bulletPowerTimer)/1000000;
    if (bulletPowerTimerDiff > bulletPowerLength){
      bulletPowerTimer = 0;
      for (int j = 0; j < bullets.size(); j++){
        bullets.get(j).power = 1;
        bullets.get(j).r = 2;
      }
    }
  }

  //boom update
  if (explodeIn) {
    explosionTimerDiff = (System.nanoTime() - ExplosionTimer)/1000000;
    if (explosionTimerDiff > explosionLength){
      ExplosionTimer = 0;
      explodeIn = false;
    }
  }
}

void gameOver() {
  fill(color(0, 100, 255));
  rect(0, 0, width, height);
  fill(color(255));
  textFont(createFont("Century Gothic", 16, true));
  textAlign(CENTER, CENTER);
  text(s, width/2, height/2);
  text("Final Score: " + player.score, width/2, height/2 + 30);
}

void drawState() {
  //draw Background
  fill(color(0, 100, 255));
  rect(0, 0, width, height);

  //draw slow down and bullet and invincible  screen
  if (slowDownTimer != 0 && bulletPowerTimer != 0 && player.invincibleTimer != 0){
    drawS(bulletPowerTimerDiff, bulletPowerLength, color(153, 0, 204), color(255), "SUPER MODE");
  }
  //draw slow down and invincible screen
  else if (slowDownTimer != 0 && player.invincibleTimer != 0){
    drawS(slowDownTimerDiff, slowDownLength, color(155, 102, 153), color(255), "SLOW-DOWN  & Invinsible MODE");
  }
  //draw bullet and invincible screen
  else if (bulletPowerTimer != 0 && player.invincibleTimer != 0){
    drawS(bulletPowerTimerDiff, bulletPowerLength, color(255, 204, 0), color(255), "Invicible  & BULLET-POWER MODE");
  }
  //draw slow down and bullet power screen
  else if (bulletPowerTimer != 0 &&  slowDownTimer != 0){
    drawS(bulletPowerTimerDiff, bulletPowerLength, color(255), color(255), "SLOWDOWN  & BULLET-POWER MODE");
  }
  //draw slow down screen
  else if (slowDownTimer != 0){
    drawS(slowDownTimerDiff, slowDownLength, color(153, 0, 51), color(255), "SLOW-DOWN MODE");
  }
  //draw invincible mode
  else if (player.invincibleTimer != 0){
    drawS(player.invincibleTimeDiff, player.invicibleLength, color(51, 204, 204), color(255), "INVINCIBLE MODE");
  }
  //draw bullet power screen
  else if (bulletPowerTimer != 0){
    drawS(bulletPowerTimerDiff, bulletPowerLength, color(0, 100, 70), color(255), "BULLET-POWER MODE");
  }
  if (explodeIn){
    int alpha  = (int)(255*Math.sin(3.14 * explosionTimerDiff/ explosionLength));  //for transparency
    alpha = constrain(alpha, 0, 255);
    fill(color(255, 255, 255, alpha));
    textFont( createFont("Century Gothic", 28, true));
    String s = "!!!!  BoOoOoOoOoOoM  !!!!";
    textAlign(CENTER, CENTER);
    text(s, width/2, height /2 - 40);
  }

  player.drawPlayer();
  for (int i=0; i< bullets.size(); i++)
    bullets.get(i).drawBullet();
  for (int i=0; i< enemies.size(); i++)
    enemies.get(i).drawEnemy();
  for (int i = 0; i < powerUps.size(); i++)
    powerUps.get(i).drawPowerUp();
  for (int i = 0; i < explosions.size(); i++)
    explosions.get(i).drawExplosion();
  for (int i = 0; i < texts.size(); i++)
    texts.get(i).drawText();

  if (waveStartTimer != 0){
    textFont(createFont("Century Gothic", 18, true));
    String s = "-W A V E " + waveNumber + "  -";
    int alpha  = (int)(255*Math.sin(3.14 * waveStartTimerDiff / waveDelay));  //for transparency
    alpha = constrain(alpha, 0, 255);
    fill(color(255, alpha));
    textAlign(CENTER, TOP);
    text(s, width/2-10, 60);
  }

  for (int i =0; i < player.lives; i++) {
    fill(255, 20, 75);
    strokeWeight(2);
    stroke(darker(color(255, 20, 75)));
    ellipse(20+(20*i), 20, player.r*2, player.r*2);
  }

  //draw player-power;
  fill(255, 255, 0);
  stroke(darker(color(255, 255, 0)));
  for (int i=0; i< player.requiredPower[player.powerLevel]; i++)
    rect(20+8*i+i*4, 40, 8, 8);
  strokeWeight(1);

  //draw player score
  fill(255);
  textFont( createFont("Century Gothic", 14, true));
  textAlign(LEFT, TOP);
  text("Score: "+ player.score, width-100, 30);
  text("Level: "+ waveNumber, width-100, 50);

  //draw slow down meter
  if (slowDownTimer != 0) {
    drawMeter(color(255), 20, 60, 100, 8, (int) (100 - 100*slowDownTimerDiff / slowDownLength));
  }

  //draw bulletPower meter
  if (bulletPowerTimer != 0) {
    drawMeter(color(255, 255, 0), 20, 80, 100, 8, (int) (100 - 100*bulletPowerTimerDiff / bulletPowerLength));
  }

  //draw invincible meter
  if (player.invincibleTimer != 0) {
    drawMeter(color(0, 255, 255), 20, 100, 100, 8, (int) (100 - 100*player.invincibleTimeDiff / player.invicibleLength));
  }
}

void drawMeter(color c, int x, int y, int w1, int h1, int w2){
  noFill();
  stroke(c);
  rect(x, y, w1, h1);
  fill(c);
  rect(x, y, w2, h1);
}

void drawS(long a, int b, color c1, color c2, String str){
  int alpha  = (int)(255*Math.sin(3.14 * a/b));
  alpha = constrain(alpha, 0, 255);
  fill(color(red(c1), green(c1), blue(c1), alpha));
  rect(0, 0, width, height);
  textFont( createFont("Century Gothic", 18, true));
  String s = str;
  fill(color(red(c2), green(c2), blue(c2), alpha));
  textAlign(CENTER, CENTER);
  text(s, width/2, height /2);
}

void powerUp(Enemy e) {
  double rand = Math.random();
  if (rand < 0.005) //kills all enemies
    powerUps.add(new PowerUp(e.x, e.y, 7));
  else if (rand < 0.008) //+1 life
    powerUps.add(new PowerUp(e.x, e.y, 1));
  else if (rand < 0.020) //+3 power
    powerUps.add(new PowerUp(e.x, e.y, 3));
  else if (rand < 0.06 && waveNumber >=4) //+ bullet power
    powerUps.add(new PowerUp(e.x, e.y, 5));
  else if (rand < 0.1) //+1 power
    powerUps.add(new PowerUp(e.x, e.y, 2));
  else if (rand < 0.12) //slow down
    powerUps.add(new PowerUp(e.x, e.y, 4));
  else if (rand < 0.15 && waveNumber >=5) //player invincible against enemies
    powerUps.add(new PowerUp(e.x, e.y, 6));
}

color darker(color c) {
  return color(red(c)*0.4, green(c)*0.4, blue(c)*0.4);
}

void createEneimies() {
  enemies.clear();
  if (waveNumber ==1)
    for (int i=0; i< 5; i++)
      enemies.add(new Enemy(1, 1, slow));
  if (waveNumber ==2){
    for (int i=0; i< 8; i++)
      enemies.add(new Enemy(1, 1, slow));
  }
  if (waveNumber==3) {
    for (int i=0; i< 6; i++)
      enemies.add(new Enemy(1, 1, slow));
    enemies.add(new Enemy(1, 2, slow));
    enemies.add(new Enemy(1, 2, slow));
  }
  if (waveNumber==4) {
    for (int i=0; i< 4; i++)
      enemies.add(new Enemy(2, 1, slow));
    enemies.add(new Enemy(1, 4, slow));
  }
  if (waveNumber==5) {
    for (int i=0; i< 4; i++)    //4 fast
      enemies.add(new Enemy(4, 1, slow));
  }
  if (waveNumber==6) {
    enemies.add(new Enemy(1, 4, slow));
    enemies.add(new Enemy(1, 3, slow));
    enemies.add(new Enemy(2, 3, slow));
  }
  if (waveNumber==7) {
    for (int i=0; i< 4; i++){
      enemies.add(new Enemy(2, 1, slow));
      enemies.add(new Enemy(3, 1, slow));
    }
    enemies.add(new Enemy(1, 3, slow));
  }
  if (waveNumber==8) {
    enemies.add(new Enemy(1, 3, slow));
    enemies.add(new Enemy(2, 3, slow));
    enemies.add(new Enemy(3, 3, slow));
  }
  if (waveNumber==9) {
    enemies.add(new Enemy(1, 4, slow));
    enemies.add(new Enemy(2, 4, slow));
    enemies.add(new Enemy(3, 4, slow));
  }
  if (waveNumber==10)
    running=false;
}

void keyPressed() {
  if (key == 'z') {
    player.firing = true;
  } else {
    switch (keyCode) {
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

void keyReleased() {
  if (key == 'z') {
    player.firing = false;
  } else {
    switch (keyCode) {
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