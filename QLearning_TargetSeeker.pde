import controlP5.*;

ControlP5 cp5;

//
int w = 50;
int columns, rows;
Cell[][] grid;

PVector target;
PVector agent;

float gamma = 0.8;
boolean reset = true;

PFont f, UI;

int showQ = -1; // +1 for showR

int QValueThreshhold = 10000;

int mover = 1; //1 is random, -1 is thinker

int counter = 0;

void setup() {
  size(950, 650);
  columns = (width-300)/w;
  rows = height/w;
  grid = new Cell[columns][rows];

  //printArray(PFont.list());
  f = createFont("AvenirNextCondensed-UltraLight", 9);
  UI = createFont("AvenirNextCondensed-UltraLight", 16);
  textAlign(CENTER, CENTER);

  //INITIALISATION
  for ( int i = 0; i < columns; i++) {
    for ( int j = 0; j < rows; j++) {
      grid[i][j] = new Cell(300+i*w, j*w, w);
    }
  }

  //SET TARGET AND SOURCE
  target = new PVector(int(columns/2), int(rows/2));
  grid[int(target.x)][int(target.y)].state = 2;

  //SET EDGE MOVES TO -1
  for ( int i = 0; i < columns; i++) {
    for ( int j = 0; j < rows; j++) {
      grid[i][j].moveR[4] = -1;
      if (j == 0) grid[i][j].moveR[3] = -1;
      else if (j == columns - 1) grid[i][j].moveR[1] = -1;
      if (i == 0) grid[i][j].moveR[2] = -1;
      else if (i == rows - 1) grid[i][j].moveR[0] = -1;
    }
  }

  //SET TARGET MOVES TO 100
  grid[int(target.x) - 1][int(target.y)].moveR[0] = 5000;
  grid[int(target.x)][int(target.y) - 1].moveR[1] = 5000;
  grid[int(target.x) + 1][int(target.y)].moveR[2] = 5000;
  grid[int(target.x)][int(target.y) + 1].moveR[3] = 5000;

  //SELF CONSUMING GOAL
  grid[int(target.x)][int(target.y)].moveR[4] = 5000;
}


//There are 2 ways to do it. One is to seperate the learners from the seekers
//Which means that the agent which builds up the memory does not actively seek the target
//It just builds intelligence, but lets the seeker use it

//Other is to let the same agent build and seek target
//We'll use the latter approach for now

//1. Look around, find the best possible move
//2. Calculate Q value for that move
//3. Move
//4. Repeat


void draw() {
  //If agent has reached the goal, place agent at a new random location
  if (reset == true) {
    counter++;
    float randomGen = random(0, 4);
    if (randomGen < 1) {
      agent = new PVector(int(random(0, columns-1)), 0);
    } else if (randomGen < 2) {
      agent = new PVector(0, int(random(0, rows-1)));
    } else if (randomGen < 3) {
      agent = new PVector(columns-1, int(random(0, rows-1)));
    } else {
      agent = new PVector(int(random(0, columns-1)), rows-1);
    }

    reset = false;
  }

  int move;
  do move = int(random(4));
  while (grid[int(agent.x)][int(agent.y)].moveR[move] == -1);

  if (mover == -1) {
    for (int i=0; i<5; i++) {
      if (grid[int(agent.x)][int(agent.y)].moveQ[i] > grid[int(agent.x)][int(agent.y)].moveQ[move])
        move = i;
    }
  }
  PVector futureAgent = new PVector(agent.x, agent.y);

  //STEP
  if (move == 0) futureAgent.x++;
  else if (move == 1) futureAgent.y++;
  else if (move == 2) futureAgent.x--;
  else if (move == 3) futureAgent.y--;

  //Calculate max Q value of the next state
  int maxQnextState = 0;
  for (int i=0; i<5; i++) {
    if (grid[int(futureAgent.x)][int(futureAgent.y)].moveQ[i] > maxQnextState)
      maxQnextState = grid[int(futureAgent.x)][int(futureAgent.y)].moveQ[i];
  }

  //Q-learning formulae
  grid[int(agent.x)][int(agent.y)].moveQ[move] = grid[int(agent.x)][int(agent.y)].moveR[move] + int(gamma*maxQnextState);
  agent = futureAgent;

  //RESET
  if ((target.x == agent.x) && (target.y == agent.y))
    reset = true;

  //colour the blocks
  grid[int(agent.x)][int(agent.y)].state = 1;
  grid[int(target.x)][int(target.y)].state = 2;

  for ( int i = 0; i < columns; i++) {
    for ( int j = 0; j < rows; j++) {
      grid[i][j].display();
    }
  }
  delay(20);
  //noLoop();
  grid[int(agent.x)][int(agent.y)].state = 0;
  text(counter, 10, 10);
}

void keyPressed() {
  // show R values vs. Q values
  if (key == 's') {
    showQ *= -1;
  }
  //step once
  if (key == 'a') {
    loop();
  }
  //Random vs thinking agent
  if (key == 'd') {
    mover *= -1;
  }
}

void mousePressed() {
  for (int i=1; i<columns-1; i++) {
    for (int j=1; j<rows-1; j++) {
      if (((mouseX < grid[i][j].x+w) && (mouseX > grid[i][j].x)) && ((mouseY < grid[i][j].y+w) && (mouseY > grid[i][j].y))) {

        if (grid[i][j].state == 0) {

          grid[i][j].state = 3;

          for (int k=0; k<5; k++) {
            grid[i][j].moveR[k] = 0;
            grid[i][j].moveQ[k] = 0;
          }
          grid[i][j].moveR[4] = -1;

          grid[i - 1][j].moveR[0] = -1;
          grid[i - 1][j].moveQ[0] = 0;

          grid[i][j - 1].moveR[1] = -1;
          grid[i][j - 1].moveQ[1] = 0;

          grid[i + 1][j].moveR[2] = -1;
          grid[i + 1][j].moveQ[2] = 0;

          grid[i][j + 1].moveR[3] = -1;
          grid[i][j + 1].moveQ[3] = 0;
        } else if (grid[i][j].state == 3) {
          grid[i][j].state = 0;
          grid[i - 1][j].moveR[0] = 0;
          grid[i - 1][j].moveQ[0] = 0;

          grid[i][j - 1].moveR[1] = 0;
          grid[i][j - 1].moveQ[1] = 0;

          grid[i + 1][j].moveR[2] = 0;
          grid[i + 1][j].moveQ[2] = 0;

          grid[i][j + 1].moveR[3] = 0;
          grid[i][j + 1].moveQ[3] = 0;
        }
      }
    }
  }
}