class Player {
  int x, y, r, dx, dy, speed, lives, score; 

  boolean firing, recovering, invicible;
  boolean left, right, up, down;
  
  long firingTimer, firingDelay, recoveryTimer, invincibleTimer, invincibleTimeDiff;
  
  int invicibleLength = 6000; 
  int powerLevel, power;
  int[] requiredPower = {1,2,3,4,5};

  color color1, color2, color3;

  Player(){
    x = width/2;
    y = height /2;
    r = 5;
    speed = 5;
    lives = 3;
    color1 = color(255);
    color2 = color(255, 0, 0);
    color3 = color(180,250,0);
    
    firingTimer = System.nanoTime();
    firingDelay = 200;
  }

  boolean isDead(){ return lives <= 0; }
  
  void setLeft(boolean left) { this.left = left; }
  void setRight(boolean right) { this.right = right; }
  void setUp(boolean up) { this.up = up; }
  void setDown(boolean down) { this.down = down; }

  void addScore(int i ) { score +=i; }

  void loseLife(){
    lives--;
    recovering = true;
    recoveryTimer = System.nanoTime();
  }

  void invincible(){
    invicible = true;
    invincibleTimer = System.nanoTime();
  }
 
  void gainLife() {
    lives++;
  }

  void increasePower(int i) {
    power +=i;
    if(powerLevel == 4){
      if(power > requiredPower[powerLevel])
        power = requiredPower[powerLevel];
      return;
    }
    if(power >= requiredPower[powerLevel]){
      power -= requiredPower[powerLevel];
      powerLevel++;
    }
  }
  
  void update(){
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

    if(firing){
      long elapsed = (System.nanoTime() - firingTimer)/1000000;
      if(elapsed > firingDelay){
        if(!shoot.isPlaying()){ shoot.rewind(); shoot.play(); }
        firingTimer = System.nanoTime();
        if(powerLevel < 2){
          if(TheGame.bulletPowerTimer != 0)  //During bullet power up
            TheGame.bullets.add(new Bullet(270, x,y,3,3));
          else
            TheGame.bullets.add(new Bullet(270, x,y,2,1));
        }else if(powerLevel < 4) {
          if(TheGame.bulletPowerTimer != 0){
            TheGame.bullets.add(new Bullet(270, x+5,y,3,3));
            TheGame.bullets.add(new Bullet(270, x-5,y,3,3));
          }else {
            TheGame.bullets.add(new Bullet(270, x+5,y,2,1));
            TheGame.bullets.add(new Bullet(270, x-5,y,2,1));
          }
        }else{
          if(TheGame.bulletPowerTimer != 0){
            TheGame.bullets.add(new Bullet(270, x+5,y,3,3));
            TheGame.bullets.add(new Bullet(277, x-5,y,3,3));
            TheGame.bullets.add(new Bullet(263, x+5,y,3,3));
          }else{
            TheGame.bullets.add(new Bullet(270, x+5,y,2,1));
            TheGame.bullets.add(new Bullet(277, x-5,y,2,1));
            TheGame.bullets.add(new Bullet(263, x+5,y,2,1));
          }
        }
      }
    }
    if(recovering){
      long elapsed = (System.nanoTime() - recoveryTimer)/1000000;
      if(elapsed > 2000){
        recovering =false;
        recoveryTimer = 0;
      }
    }
    if(invicible){
      invincibleTimeDiff = (System.nanoTime() - invincibleTimer)/1000000;
      if(invincibleTimeDiff > invicibleLength){
        invicible =false;
        invincibleTimer = 0;
      }
    }
  }
  
  void drawPlayer(){
    color c = recovering ? color2: (invicible ? color3: color1);
    fill(c);
    strokeWeight(2);
    stroke(darker(c));
    ellipse(x-r*0.5, y-r*0.5, 3*r, 3*r);
  }
  
  color darker(color c) {
    return color(red(c)*0.5, green(c)*0.5, blue(c)*0.5);
  }
}