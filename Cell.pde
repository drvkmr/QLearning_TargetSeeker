class Cell {
  int x, y;
  int w;
  int state; // 0 is blank, 1 is agent, 2 is target, 3 is blocked

  //ENVIRONMENT RESTRICTIONS
  int[] moveR;

  //MEMORY (Q - MATRIX)
  int[] moveQ;

  Cell (int x_, int y_, int w_) {
    x = x_;
    y = y_;
    w = w_;
    state = 0;

    moveR = new int[5];
    moveQ = new int[5];

    //0 = right, 1 = down, 2 = left, 3 = up
    for (int i=0; i<5; i++) {
      moveR[i] = 0;
      moveQ[i] = 0;
    }
  }

  void display() {
    textFont(f);
    if (state == 0) fill(255);
    else if (state == 1)
      if(mover == -1) fill(200, 255, 200);
      else fill(200,200,255);
    else if (state == 2) fill(255, 200, 200);
    else if (state == 3) fill(200, 200, 200);
    else fill(0, 255, 0);

    stroke(200);
    rect(x, y, w, w);
    fill(0);
    //if (((mouseX < x+w) && (mouseX > x)) && ((mouseY < y+w) && (mouseY > y))) {
      pushMatrix();
      translate(x+w/6, y+w/6);
      fill(0);
      if (showQ == 1) {
        text(moveQ[3], w/3, 0);
        text(moveQ[2], 0, w/3);
        text(moveQ[1], w/3, w*2/3);
        text(moveQ[0], w*2/3, w/3);
        text(moveQ[4], w/3, w/3);
      }
      else {
        text(moveR[3], w/3, 0);
        text(moveR[2], 0, w/3);
        text(moveR[1], w/3, w*2/3);
        text(moveR[0], w*2/3, w/3);
        text(moveR[4], w/3, w/3);
      }
      popMatrix();
    //}
  }
}