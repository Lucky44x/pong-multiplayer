import processing.sound.*;
import processing.net.*;
import java.io.FilenameFilter;

//Network variables
int controlling = -1;
Client _client1;
Client _client;

String score = "0 : 0";
int time = -1;
int framesPassed = 0;

rgb[] rgbs = new rgb[]{new rgb(255, 0, 0), new rgb(255, 255, 0), new rgb(0, 255, 0)};

//Game variables
int[] yS = new int[]{175, 175};
int[] ballPos = new int[] {400, 250};
SoundManager soundMan;

//_____________________ DIESE IP ZUR SERVER IP ÄNDERN _____________________\\
String ip = "094.199.211.100";
String ipa = "127.0.0.1";

//Das hier Ignorieren
class rgb {
  int v1;
  int v2;
  int v3;

  public rgb(int v1, int v2, int v3) {
    this.v1 = v1;
    this.v2 = v2;
    this.v3 = v3;
  }
}

void setup() {
  size(800, 500);
  frameRate(25);
  soundMan = new SoundManager();
  soundMan.loadFiles();
  _client1 = new Client(this, ip, 5204);
  _client1.write(new byte[]{1});
}

void draw() {
  if (_client1.available() > 0) {
    byte[] data = _client1.readBytes();

    if (int(data[0]) == 2) {
      time = 3;
      return;
    }
    else if(data[0] == 3){
       soundMan.playSound("blip-" + data[1]);
    }

    if (controlling == -1) {
      int id = int(data[0]);
      int port2 = 0;
      controlling = id;
      if (id > 1) {
        exit();
      }
      switch(id) {
        case(0):
        port2 = 12045;
        break;
        case(1):
        port2 = 12046;
        break;
        case(-1):
        exit();
        break;
      }
      _client = new Client(this, ip, port2);
    }
  }

  if (controlling == -1) {
    return;
  }

  gameLogic();

  //drawing scene
  background(0);

  //drawing gameElements
  if (controlling == 0) {
    fill(100);
  } else {
    fill(255);
  }
  rect(50, yS[0], 10, 150);

  if (controlling == 1) {
    fill(100);
  } else {
    fill(255);
  }
  rect(width-50, yS[1], 10, 150);

  fill(255);
  circle(ballPos[0], ballPos[1], 10);

  text(score, 400, 30);

  if (time > 0) {
    framesPassed++;
    textSize(45);

    fill(rgbs[time-1].v1, rgbs[time-1].v2, rgbs[time-1].v3);
    text(time, 395, 250);
    if (framesPassed >= 25) {
      framesPassed = 0;
      time--;
    }
    fill(255);
    textSize(11);
  }
}

void gameLogic() {

  if (_client.available() > 0) {
    byte[] data = _client.readBytes();

    if (controlling == 0) {
      yS[1] = int(data[2]) + int(data[3]);
    } else {
      yS[0] = int(data[0]) + int(data[1]);
    }
    ballPos[0] = int(data[4]) + int(data[5]) + int(data[6]);
    ballPos[1] = int(data[7]) + int(data[8]);
    score = int(data[9]) + " : " + int(data[10]);

    fill(0, 255, 0);
  }

  if (keyPressed) {
    switch(key) {
      case('w'):
      if (yS[controlling] > 5) {
        yS[controlling] -= 10;
      }
      sendMove();
      break;
      case('s'):
      if (yS[controlling] + 150 < height) {
        yS[controlling] += 10;
      }
      sendMove();
      break;
    }
  }
}

void sendMove() {

  int ySy = yS[controlling];
  int ySy1 = 0;
  if (ySy > 255) {
    ySy1 = yS[controlling] - 255;
    ySy = 255;
  }

  byte[] move = new byte[] {byte(controlling), byte(ySy), byte(ySy1)};
  _client.write(move);
}
