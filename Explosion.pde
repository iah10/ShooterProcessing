class Explosion{
  float x, y;
  int r, maxRadius;
 
  Explosion(float x, float y, int r, int maxRadius) {
    this.x = x;
    this.y = y;
    this.r = r;
    this.maxRadius = maxRadius;
  }

  boolean update(){
    r +=3;
    if(r >=maxRadius)
      return true;
    return false;
  }

  void drawExplosion(){
    fill(color(255, 150));
    strokeWeight(2);
    ellipse((int)(x-r), (int)(y-r), 2*r, 2*r);
    strokeWeight(1);
  }
}