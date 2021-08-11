/****************************************/
/* Stop-motion Station                  */
/* Abdulrahman Y. idlbi, Karakeeb       */
/* adlogi@karakeeb.xyz                  */
/****************************************/

import processing.video.*;
import processing.sound.*;

Capture cam;
SoundFile shutterSound;
PImage shutterImg;

PImage[] pgArr = {};
int status = 0;          // 0: recording, 1: playing, 2: deleting
int index;
int playFrameCount;      // frameCount when playing starts
int ANIMATION_RATE = 4;  // settign the frame rate for the animation

void setup() {
  //size(640, 480);
  fullScreen();
  
  String[] cameras = Capture.list();
  imageMode(CENTER);
  shutterImg = loadImage("photo-camera.png");
  shutterSound = new SoundFile(this, "camera-shutter-click-01.mp3");

  if (cameras == null) {
    println("Failed to retrieve the list of available cameras, will try the default...");
    cam = new Capture(this, 640, 480);
  } else if (cameras.length == 0) {
    println("There are no cameras available for capture.");
    exit();
  } else {
    println("Available cameras:");
    printArray(cameras);

    cam = new Capture(this, cameras[0]);
    //cam = new Capture(this, 640, 480, "Built-in iSight", 30);
    // "name=FaceTime HD Camera (Built-in),size=1280x720,fps=30"
    
    cam.start();
  }
  println(sketchPath());
  println(System.getProperty("os.name"));
}

void draw() {
  switch (status) {
    case 0:  // RECORDING
      if (cam.available() == true) {
        cam.read();
      }
      
      pushMatrix();
      scale(-1,1);
      tint(255, 255);
      image(cam, -width / 2, height / 2, width, height);
      popMatrix();
      
      // Show the last captured frame
      if (pgArr.length > 0) {
        pushMatrix();
        scale(-1,1);
        tint(255, 100);
        image(pgArr[pgArr.length - 1], -width / 2, height / 2, width, height);
        popMatrix();
      }
      break;
    case 1:  // PLAYING
      if (index < pgArr.length) {
        pushMatrix();
        scale(-1,1);
        tint(255, 255);
        image(pgArr[index], -width / 2, height / 2, width, height);
        popMatrix();
        if (frameCount > playFrameCount + (index + 1) * (frameRate / ANIMATION_RATE)) {
          index++;
        }
      } else {
        status = 0;  // resume recording
      }
      break;
    case 2:
      if (pgArr.length > 0) {
        pushMatrix();
        scale(-1,1);
        tint(255, 0, 0, 255);
        image(pgArr[pgArr.length - 1], -width / 2, height / 2, width, height);
        popMatrix();
        rectMode(CENTER);
        fill(0);
        rect(width / 2, height / 2, 400, 150);
        noStroke();
        fill(#C00000);
        textAlign(CENTER);
        textSize(14);
        String msgEn[] = {
          "Are you sure you want to delete the last frame?",
          "Press \"Delete\" again to confirm.",
          "Press any other key to cancel."
        };
        String msgAr[] = {
          "هل تريد حذف الإطار الأخير؟",
          "اضغط مفتاح الحذف ثانيةً للتأكيد.",
          "اضغط أي مفتاح آخر لإلغاء الأمر."
        };
        //text(msgEn[0] + "\n\n" + msgEn[1] + "\n" + msgEn[2], width / 2, height / 2 - 20);
        text(msgAr[0] + "\n\n" + msgAr[1] + "\n" + msgAr[2], width / 2, height / 2 - 20);
      }
      break;
    default:
      break;
  }
}

void keyPressed() {
  switch (key) {
    case ' ':
      if (status == 2) {
        status = 0;
      } else if (status == 0) {
        pgArr = (PImage[])append(pgArr, cam.get());
        tint(255, 100);
        image(shutterImg, width / 2, height / 2);
        shutterSound.play();
      }
      break;
    case ENTER:
    case RETURN:
    case 'p':
    case 'P':
      if (status == 2) {
        status = 0;
      } else if (status == 0 && pgArr.length > 0) {
        index = 0;
        status = 1; // playing
        playFrameCount = frameCount;
      }
      break;
    case 'd':
    case DELETE:
    case 8: // Mac delete key
      if (status == 0 && pgArr.length > 0) {
        status = 2; // deleting
      } else if (status == 2) {
        pgArr = (PImage[])shorten(pgArr);
        status = 0;
      }
      break;
    case 's':
    case 'S':
      if (status == 2) {
        status = 0;
      } else if (status == 0 && pgArr.length > 0) {
        String dirName = "";
        String[] cmd = new String[2];
        
        if (System.getProperty("os.name").indexOf("Mac") > -1) {
          dirName = sketchPath() + "/" + nf(year(), 4) + nf(month(), 2) + nf(day(), 2) + nf(hour(), 2) + nf(minute(), 2) + nf(second(), 2) + "/";
          cmd[0] = "mkdir " + dirName;
          cmd[1] = sketchPath() + "/ffmpeg -y -framerate 4 -i " + dirName + "frame-%03d.png -c:v libx264 -r 30 -pix_fmt yuv420p " + dirName + "animation.mp4";
        } else if (System.getProperty("os.name").indexOf("Windows") > -1) {
          dirName = sketchPath() + "\\" + nf(year(), 4) + nf(month(), 2) + nf(day(), 2) + nf(hour(), 2) + nf(minute(), 2) + nf(second(), 2) + "\\";
          cmd[0] = "mkdir " + dirName;
          cmd[1] = "ffmpeg -y -framerate 4 -i " + dirName + "frame-%03d.png -c:v libx264 -r 30 -pix_fmt yuv420p " + dirName + "animation.mp4";
        }
        
        try {
          Process p = Runtime.getRuntime().exec(cmd[0]);
          
          PImage flipped = createImage(pgArr[0].width, pgArr[0].height, RGB);
          for (int i = 0; i < pgArr.length; i++) {
            for (int j = 0; j < flipped.pixels.length; j++) {
              int srcX = j % flipped.width;
              int dstX = flipped.width - srcX - 1;
              int y = j / flipped.width;
              flipped.pixels[y * flipped.width + dstX] = pgArr[i].pixels[j];
            }
            flipped.save(dirName + "frame-" + nf(i, 3) + ".png");
          }
          
          p = Runtime.getRuntime().exec(cmd[1]);
        } catch (IOException e) {
        }
      }
      break;
    case 'n':
    case'N':
      if (status == 2) {
        status = 0;
      } else if (status == 0) {
        pgArr = new PImage[0];
      }
      break;
    default:
      status = 0;
      break;
  }
}