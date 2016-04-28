class PowerUp {
  double x, y;
  int r, type;
  color color1, color2;

  PowerUp(double x, double y, int type) {
    this.x = x;
    this.y = y;
    this.type = type;

    switch (type) {
    case 1:  // 1-- +1 life
      color1 = color(255, 190, 200); // pink
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
    case 6:  //6--makes the player invincible against enemies
      color1 = color(0, 255, 255); //cyan
      r = 4;
      break;
    case 7:  //7--kills all the enemies
      color1 = darker(color(255, 0, 0));
      color2 = color(255, 255, 0);
      r =10;
      break;
    }
  }

  boolean update() {
    y+=2;
    if (y> height +r)
      return true;
    return false;
  }

  void drawPowerUp() {
    fill(color1);
    strokeWeight(2);
    stroke(type==7?color2:darker(color1));
    rect((int)x, (int)y, 2*r, 2*r);
    strokeWeight(1);
  }

  color darker(color c) {
    return color(red(c)*0.4, green(c)*0.4, blue(c)*0.4);
  }
}