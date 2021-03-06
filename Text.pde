class Text {
  float x, y;
  int time;
  long start;
  String s;
  PFont century;
  
  Text(float x, float y, String s) {
    this.x = x;
    this.y = y;
    this.time = 300;
    this.s = s;
    start = System.nanoTime();
    century = createFont("Century Gothic", 12, true);
  }

  boolean update(){
    long elapsed = (System.nanoTime() - start)/1000000;
    if (elapsed > time)
      return true;
    return false;
  }

  void drawText(){
    textFont(century);
    long elapsed = (System.nanoTime() - start)/1000000;
    int alpha = (int)(255*sin(3.14 *elapsed/time));
    alpha = constrain(alpha, 0, 255);
    fill(color(255, alpha));
    text(s, (int)x, (int) y);
  }
}