import processing.net.*;

//Network variables
int controlling = 1;
Server _server;
Server _server1;
Server _server2;

String score = "0 : 0";
int[] _score = new int[]{0,0};

int players = 0;

//einstellungen
int gr = 150;

//Game variables
int[] yS = new int[]{200,200};
int[] ballPos = new int[] {400,250};
int[] moving = new int[] {0,0};
int[] ballVel = new int[]{0,0};
int time = -1;
int framesPassed = 0;

void setup(){
   size(800,500);
   yS = new int[] {250 - gr/2,250 - gr/2};
   frameRate(25);
   _server = new Server(this,12044);
   _server1 = new Server(this,12045);
   _server2 = new Server(this,12046);
}

void Serv2Data(){
    if(_server2.available() != null){
        byte[] data = new byte[3];
        _server2.available().readBytes(data);
        yS[int(data[0])] = int(data[1]) + int(data[2]);
    }
}

void draw(){
    
    if(_server.available() != null){
       byte[] dat = _server.available().readBytes();
       if(players==2){_server.write(new byte[] {byte(-1)});return;}
       _server.write(new byte[] {byte(players)});
       players++;
       if(players == 2){
          _server.write(new byte[]{byte(2)});
          time = 3; 
       }
    }
    
    gameLogic();
  
    //drawing scene
    background(0);
    //rect(width/2-5,0,10,500);
    
    rect(50,yS[0],10,gr);
    rect(width-50,yS[1],10,gr);
    
    fill(255);
    circle(ballPos[0],ballPos[1],10);
    
    //Markierungen ball
    fill(255,0,0);
    circle(ballPos[0],ballPos[1]+5,2);
    fill(0,0,255);
    circle(ballPos[0],ballPos[1]-5,2);
    fill(255,255,0);
    circle(ballPos[0]+5,ballPos[1],2);
    fill(0,255,0);
    circle(ballPos[0]-5,ballPos[1],2);
    
    //Markierungen Spieler R
    fill(0,255,0);
    circle(width-50,yS[1],5);
    circle(width-50,yS[1]+gr/2,5);
    circle(width-50,yS[1]+gr,5);
    
    //Markierungen Spieler R
    fill(0,255,0);
    circle(60,yS[0],5);
    circle(60,yS[0]+gr/2,5);
    circle(60,yS[0]+gr,5);
    
    fill(0,255,255);
    text("SERVER",730,20);
    
    fill(255);
    
    text(score,400,30);
    
    if(time > -1){
      framesPassed++;
      textSize(45);
      text(time,395,250);
      if(framesPassed >= 25){
         framesPassed = 0;
         time--;
         if(time == -1){
            ballVel = newBallVel();
         }
      }
      textSize(11);
    }
}

int[] newBallVel(){
   int rXV = round(random(6,10));
   int rYV = round(random(6,10));
   int rXM = round(random(-1,1));
   int rYM = round(random(-1,1));
   
   if(rXM == 0 || rYM == 0){
      return newBallVel(); 
   }
   
   return new int[]{rXV * rXM, rYV * rYM};
}

void gameLogic(){
    ballPos[0] += ballVel[0];
    ballPos[1] += ballVel[1];
    
    if(ballPos[0] <= 50){
       _score[1] += 1;
       score = _score[0] + " : " + _score[1];
       ballVel[0] = 0;
       ballVel[1] = 0;
       ballPos[0] = 400;
       ballPos[1] = 250;
       _server.write(new byte[]{byte(2)});
       time = 3;
    }
    
      if(ballPos[0] >= width-40){
       _score[0] += 1;
       score = _score[0] + " : " + _score[1];
       ballVel[0] = 0;
       ballVel[1] = 0;
       ballPos[0] = 400;
       ballPos[1] = 250;
       _server.write(new byte[]{byte(2)});
       time = 3;
    }
    
    if(keyPressed){
       if(key == 'e'){        
          _server.write(new byte[]{byte(2)});
          time = 3;
       }
    }
    
    if(ballPos[1] >= height - 10 || ballPos[1] <= 10){
       ballVel[1] *= -1; 
    }
    
    if(ballPos[0] + 5 >= width-50){
      if(ballPos[1] + 5 <= yS[1] + gr && ballPos[1] - 5 >= yS[1]){
           ballVel[0] *= -1;
           _server.write(new byte[]{3});
           if(moving[1] == 1){ballVel[0] *= 1.2;}
      }
    }
    if(ballPos[0] - 5 <= 60){
      if(ballPos[1] + 5 <= yS[0] + gr && ballPos[1] - 5 >= yS[0]){
           ballVel[0] *= -1; 
            _server.write(new byte[]{3});
           if(moving[0] == 1){ballVel[0] *= 1.2;}
      } 
    }
    
    moving = new int[]{0,0};
    
    thread("Serv2Data");
    
    if(_server1.available() != null){
        byte[] data = new byte[3];
        _server1.available().readBytes(data);
        if(int(data[1]) + int(data[2]) != yS[int(data[0])]){
            moving[int(data[0])] = 1;
        }
        yS[int(data[0])] = int(data[1]) + int(data[2]);
    }
    
    int yS00 = yS[0];
    int yS01 = 0;
    if(yS00 > 255){
        yS01 = yS[0] - 255;
        yS00 = 255;
    }
    
    int yS10 = yS[1];
    int yS11 = 0;
    if(yS10 > 255){
        yS11 = yS[1] - 255;
        yS10 = 255;
    }
    
    int bX = ballPos[0];
    int bX1 = 0;
    int bX2 = 0;
    if(bX > 255){
        bX1 = ballPos[0] - 255;
        bX = 255;
        if(bX1 > 255){
           bX2 = bX1 - 255;
           bX1 = 255;
        }
    }
    
    int bY = ballPos[1];
    int bY1 = 0;
    if(bY > 255){
        bY1 = ballPos[1] - 255;
        bY = 255;
    }
    
    byte[] data = new byte[] {byte(yS00),byte(yS01),byte(yS10),byte(yS11),byte(bX),byte(bX1),byte(bX2),byte(bY),byte(bY1),byte(_score[0]),byte(_score[1])};
    _server1.write(data);
    _server2.write(data);
}
