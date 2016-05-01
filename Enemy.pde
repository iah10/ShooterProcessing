class Enemy {
  float x, y, dx, dy, rad, speed;

  int r, health, type, rank;
  color color1;

  boolean ready, dead, hit, slow;
  long hitTimer;

  Enemy(int type, int rank, boolean slow){
    this.type = type;
    this.rank = rank;
    this.slow = slow;
    if (type==1){ //BLUE
      color1 = color(0, 0, 100, 128);
      if (rank ==1){ setEnemyStats(2, 5, 1); }
      if (rank ==2){ setEnemyStats(2, 10, 2); }
      if (rank ==3){ setEnemyStats(1.5, 20, 3); }
      if (rank ==4){ setEnemyStats(1.5, 30, 4); }
    }
    //stronger , faster 
    if (type==2){ //RED
      color1 = color(255, 0, 0, 128);
      if (rank ==1){ setEnemyStats(7, 5, 2); }
      if (rank ==2){ setEnemyStats(5, 10, 3); }
      if (rank ==3){ setEnemyStats(5, 20, 3); }
      if (rank ==4){ setEnemyStats(5, 30, 4); }
    }
    //slow, but hard to kill
    if (type==3){ //GREEN
      color1 = color(0, 255, 0, 128);
      if (rank ==1){ setEnemyStats(1.5, 5, 5); }
      if (rank ==2){ setEnemyStats(1.5, 10, 6); }
      if (rank ==3){ setEnemyStats(1.5, 25, 7); }
      if (rank ==4){ setEnemyStats(1.5, 45, 8); }
    }
    if (type==4) {
      if (rank==1) { //GRAY
        color1 = color(128);
        speed = 9;
        health = 2;
        r = 4;
      } else{
        color1 = color(255, 165, 0);
        speed = 12;
        health = 4;
        r = 4;
      }
    }
    x = random(1) * width/2 + width /4;
    y = -r;

    float angle = random(1) * 140 +20;
    rad = (float)Math.toRadians(angle);

    dx = cos((float)rad) * speed;
    dy = sin((float)rad) * speed;
  }

  void setEnemyStats(float speed, int r, int health){
    this.speed = speed;
    this.r = r;
    this.health = health;
  }

  void setSlow(boolean b) { 
    slow = b;
  }

  void hit(int power){
    if(!explode.isPlaying()){ explode.rewind(); explode.play(); }
    health-=power;
    if (health <=0)
      dead =true;
    hit = true;
    hitTimer = System.nanoTime();
  }
  
  void explode(){
    if (rank > 1){
      int amount =0;
      if (type == 1 || type==2) 
        amount = 3;
      if (type == 3) 
        amount = 4;

      for (int i=0; i < amount; i++)
        newEnemies();
    }
  }

  void newEnemies() {
    Enemy e = new Enemy(type, rank-1, slow);
    e.x= this.x;
    e.y = this.y;
    float angle = 0;

    if (!ready) //so that when a big enemy explodes, its children go downwards
      angle = random(1)*140 +20;
    else 
      angle = random(1) * 360;

    e.rad = (float)Math.toRadians(angle);
    TheGame.enemies.add(e);
  }

  void update(){
    if (slow){
      x += dx * 0.3;
      y += dy * 0.3;
    } else {
      x+= dx;
      y += dy;
    }
    if (!ready && x > r && x < width -r && y > r && y <height - r) ready = true;
    if (x < r && dx < 0) dx = -dx;
    if (y < r && dy < 0) dy = -dy;
    if (x > width -r && dx > 0) dx = -dx;
    if (y > height -r && dy > 0) dy = -dy;

    if(hit) {
      long elapsed = (System.nanoTime() - hitTimer)/1000000;
      if (elapsed > 50){
        hit = false;
        hitTimer=0;
      }
    }
  }
  
  void drawEnemy(){
    stroke(0, 25, 50);
    if (hit)
      fill(255); 
    else
      fill(color1);
    ellipse((int)x, (int)y, 2*r, 2*r);
  }
}