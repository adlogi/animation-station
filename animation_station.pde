/****************************************/
/* Stop-motion Station                  */
/* Abdulrahman Y. idlbi, Karakeeb       */
/* adlogi@karakeeb.xyz                  */
/****************************************/

import processing.video.*;
import processing.sound.*;

/////////////////////////////////////////////////////////////////////////////////////////////////////////////
// IMPORTANT!!! SET YOUR CONSTANTS FOR THE PROGRAM:                                                        //
//                                                                                                         //
int ANIMATION_RATE = 4;      // The frame rate for the animation, on screen and for the saved MP4 file.    //
int FAINT_TIME_SLOW = 100;   // The fainting time for dispalyed icons (slow: new, save, and play icons).   //
int FAINT_TIME_FAST = 80;    // The fainting time for dispalyed icons (fast: capture and delete icons).    //
//                                                                                                         //
//                                                                                                         //
/////////////////////////////////////////////////////////////////////////////////////////////////////////////

Capture cam;
PImage shutterImg, trashImg, playImg, saveImg, newImg, logoImg, currentImg;
int currentOpacity;
//SoundFile shutterSound, trashSound;

PImage[] pgArr = {};
int status = 0;          // 0: recording, 1: playing, 2: deleting, 3: help
boolean FLIP = false;    // flip image before saving
int index;
int playFrameCount;      // frameCount when playing starts

PFont font1;
String helpText, helpTextEn, helpTextAr;

void setup() {
  //size(640, 480);
  fullScreen();
  
  font1 = createFont("AppleSDGothicNeo-Bold", 14, true);
  
  String[] cameras = Capture.list();
  imageMode(CENTER);
  shutterImg = loadImage("capture.png");
  //shutterSound = new SoundFile(this, "camera-shutter-click-01.mp3");
  trashImg = loadImage("delete.png");
  //trashSound = new SoundFile(this, "trash_can.mp3");
  playImg = loadImage("play.png");
  saveImg = loadImage("save.png");
  newImg = loadImage("new.png");
  logoImg = loadImage("logo.png");
  currentImg = newImg;
  currentOpacity = FAINT_TIME_SLOW;

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
  println("Sketch path: " + sketchPath());
  println("Operating System: " + System.getProperty("os.name"));
  
  helpTextEn = "Press:\n" +
    "• 'Space' to capture a new frame.\n" +
    "• 'Enter' or 'P' to play the current animation.\n" +
    "• 'Delete' or 'D' to delete the last frame.\n" +
    "• 'S' to save the current animation to disk.\n" +
    "• 'N' to start creating a new animation.\n" +
    "• 'H' to show/hide this screen.";
  helpTextAr = "اضغط:\n" +
    "• مفتاح 'المسافة' لالتقاط صورة جديدة.\n" +
    "• مفتاح 'الإدخال' أو 'P' لتشغيل الأنيميشن الحالي.\n" +
    "• مفتاح 'المسح' أو 'D' لحذف الصورة الأخيرة.\n" +
    "• مفتاح 'S' لحفظ الأنيميشن الحالي.\n" +
    "• مفتاح 'N' لتسجيل أنيميشن جديد.\n" +
    "• مفتاح 'H' لإظهار وإخفاء شاشة المساعدة هذه.";
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
        //tint(255, 100);
        //image(playImg, width / 2, height / 2);
        currentOpacity = FAINT_TIME_SLOW;
        currentImg = playImg;
      } else {
        status = 0;  // resume recording
      }
      break;
    case 3:
      
      rectMode(CENTER);
      fill(255);
      textFont(font1);
      //helpText = helpTextEn;
      helpText = helpTextAr;
      //textAlign(LEFT, CENTER);  // for LTR text
      textAlign(RIGHT, CENTER);  // for RTL text
      rect(width / 2, height / 2, textWidth(helpText) + 50, 200);
      fill(0);
      //text(helpText, width / 2 - textWidth(helpText) / 2, height / 2);  // for LTR text
      text(helpText, width / 2 + textWidth(helpText) / 2, height / 2);  // for RTL text 
      break;
    default:
      break;
  }
  if (currentImg != null) {
    if (currentOpacity > 0) {
      tint(255, currentOpacity);
      image(currentImg, width / 2, height / 2);
      currentOpacity -= 4;
    } else {
      currentOpacity = FAINT_TIME_SLOW;
      currentImg = null;
    }
  }
  tint(255, 255);
  image(logoImg, 60, 60);
}

void keyPressed() {
  switch (key) {
    case ' ':
      if (status == 0) {
        pgArr = (PImage[])append(pgArr, cam.get());
        //tint(255, 100);
        //image(shutterImg, width / 2, height / 2);
        currentOpacity = FAINT_TIME_FAST;
        currentImg = shutterImg;
        //shutterSound.play();
      }
      break;
    case ENTER:
    case RETURN:
    case 'p':
    case 'P':
      if (status == 0 && pgArr.length > 0) {
        index = 0;
        status = 1; // playing
        playFrameCount = frameCount;
        //tint(255, 100);
        //image(playImg, width / 2, height / 2);
      }
      break;
    case 'd':
    case 'D':
    case DELETE:
    case 8: // Mac delete key
      if (status == 0 && pgArr.length > 0) {
        pgArr = (PImage[])shorten(pgArr);
        //tint(255, 100);
        //image(trashImg, width / 2, height / 2);
        currentOpacity = FAINT_TIME_FAST;
        currentImg = trashImg;
        //trashSound.play();
      }
      break;
    case 's':
    case 'S':
      if (status == 0 && pgArr.length > 0) {
        
        String dirName = "";
        String ffmpegCmd = new String();
        String ffmpegVer = "4.2.1"; // tested: 3.4.1; most recent: 4.2.1
        
        if (System.getProperty("os.name").indexOf("Mac") > -1) {
          dirName = sketchPath() + "/animations/" + nf(year(), 4) + nf(month(), 2) + nf(day(), 2) + nf(hour(), 2) + nf(minute(), 2) + nf(second(), 2) + "/";
          ffmpegCmd = sketchPath() + "/ffmpeg-" + ffmpegVer + "/mac/ffmpeg -y -framerate " + ANIMATION_RATE + " -i " + dirName + "frame-%03d.png -c:v libx264 -r 30 -pix_fmt yuv420p " + dirName + "animation.mp4";
        } else if (System.getProperty("os.name").indexOf("Windows") > -1) {
          dirName = sketchPath() + "\\animations\\" + nf(year(), 4) + nf(month(), 2) + nf(day(), 2) + nf(hour(), 2) + nf(minute(), 2) + nf(second(), 2) + "\\";
          ffmpegCmd = sketchPath() + "\\ffmpeg-" + ffmpegVer + "\\win64\\" + "ffmpeg -y -framerate " + ANIMATION_RATE + " -i " + dirName + "frame-%03d.png -c:v libx264 -r 30 -pix_fmt yuv420p " + dirName + "animation.mp4";
        }
        println("Animation directory: " + dirName);
        println("FFmpeg command: " + ffmpegCmd);
        
        File dir = new File(dirName);
        try {
          if (dir.mkdirs()) {
            
            if (FLIP) {
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
            } else {
              for (int i = 0; i < pgArr.length; i++) {
                pgArr[i].save(dirName + "frame-" + nf(i, 3) + ".png");
              }
            }
            
            Process p = Runtime.getRuntime().exec(ffmpegCmd);
            //image(saveImg, width / 2, height / 2);
            currentOpacity = FAINT_TIME_SLOW;
            currentImg = saveImg;
          } else {
            print("Couldn't create the directory " + dirName);
          }
        } catch (Exception e) {
          e.printStackTrace();
        }
      }
      break;
    case 'n':
    case'N':
      if (status == 0) {
        pgArr = new PImage[0];
        //image(newImg, width / 2, height / 2);
        currentOpacity = FAINT_TIME_SLOW;
        currentImg = newImg;
      }
      break;
    case 'h':
    case 'H':
      if (status == 0) {
        status = 3;
      } else if (status == 3) {
        status = 0;
      }
      //println("hello from keyPressed #3");
      break;
    default:
      status = 0;
      break;
  }
}
