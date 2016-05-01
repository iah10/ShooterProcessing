class Bullet {
  float x, y;
  int r;
  float rad, speed;
  int power;
  float dx, dy;

  color color1;
  
  Bullet(float angle, int x, int y,int radius, int power){
    this.x = x;
    this.y = y;
    r = radius;
    x-=r;
    y-=r;

    rad = (float)Math.toRadians(angle);
    this.power = power;
    speed= 10;
    dx = cos(rad)*speed;
    dy = sin(rad)*speed;
    
    color1 = color(255, 255, 0);
  }
  
  boolean update(){
    x += dx;
    y += dy;

    if( x < -r || x > width + r || y < -r  || y > height + r)
      return true;
    return false;
  }
 
  void drawBullet(){
    noStroke();
    fill(color1);
    ellipse((int)x, (int)y, 2*r, 2*r);
  }
}