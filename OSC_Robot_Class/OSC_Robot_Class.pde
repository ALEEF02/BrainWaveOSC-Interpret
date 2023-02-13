/*
Don't run this unless there's data being fed through from BrainWaveOSC
  - Anthony, circa Feb 2023
*/

// Import the libraries and dependencies
import oscP5.*;
import java.awt.*;

OscP5 oscP5;
Robot brain;
float currentAttention = 0; // The current attention value from BrainWaveOSC, to be referred to as BWOSC from here
float lastAttention = 100;
float currentMed = 0; // The current meditation values from BWOSC
float lastMed = 100;
float threshold = 70.0;
float thresholdMed = 30.0;
boolean threshReach = false; 
boolean difReach = false; 

// The setup function runs first when you hit the play button
void setup(){
  oscP5 = new OscP5(this, 7771); // Start listening for incoming messages at port 7771 
  
  try { // Try and create a new robot named brain
    brain = new Robot();
  } 
  catch (AWTException e) { // If there is an error, print it out to the console
    e.printStackTrace();
  }
}

// The draw function runs over and over again until you close the application
void draw() {
  
  if (currentAttention > threshold || (currentAttention - lastAttention) > 25) { // If our current attention is large OR we've just spiked our attention. These are two, not entirely independent events.
    println(currentAttention - lastAttention);
    float setOff = currentAttention; // Note down the attention value when we 'set off' this if statement
    if (currentAttention > threshold) {
      println("Threshold exceeded!");
      threshReach = true; // 2023 Anthony here. I don't know why threshReach or difReach are here. They seem to serve 0 purpose, but I'll leave them in for now.
      while (currentAttention > threshold) { // While our attention remains high, continue to press left-click, which is Torb's long-range
        println("Pressing Left Click. A: " + currentAttention);
        brain.mousePress(java.awt.event.MouseEvent.BUTTON1_DOWN_MASK);
      }
    } else {
      println("Difference exceeded!");
      difReach = true;
      while (currentAttention >= setOff) { // While our attention remains above the attention when we spiked, continue to press left-click, which is Torb's long-range
        println("Pressing Left Click. A: " + currentAttention);
        brain.mousePress(java.awt.event.MouseEvent.BUTTON1_DOWN_MASK);
      }
    }
    
	// Release and go back into the main loop
    brain.mouseRelease(java.awt.event.MouseEvent.BUTTON1_DOWN_MASK);
    println("Releasing Left Click. A: " + currentAttention);
    threshReach = false;
    difReach = false;
  }
  
  if (currentMed < thresholdMed || (lastMed - currentMed) > 25) { // If our current meditation is small OR we've just floored our meditation. These are two, not entirely independent events.
    println(currentMed - lastMed);
    float setOff = currentMed; // Note down the meditation value when we 'set off' this if statement
    if (currentMed < thresholdMed) { // If our meditation DROPS below the threshold. Imagine this as like 'scrambling your brain', per se, where you're just thinking about a bunch of random things. This is NOT attention!
      println("Threshold exceeded!");
      threshReach = true;
      while (currentMed < thresholdMed) { // While our meditation remains low, continue to press right-click, which is Torb's short-range. This makes sense with brain scrambling, as if you're frightened by someone up close this is much easier to achieve
        println("Pressing Right Click. M: " + currentMed);
        brain.mousePress(java.awt.event.MouseEvent.BUTTON3_DOWN_MASK);
      }
    } else {
      println("Difference exceeded!");
      difReach = true;
      while (currentMed <= setOff) { // While our meditation remains below the meditation when we dipped, continue to press right-click, which is Torb's short-range.
        println("Pressing Right Click. M: " + currentMed);
        brain.mousePress(java.awt.event.MouseEvent.BUTTON3_DOWN_MASK);
      }
    }
    
	// Release and go back into the main loop
    brain.mouseRelease(java.awt.event.MouseEvent.BUTTON3_DOWN_MASK);
    println("Releasing Right Click. M: " + currentMed);
    threshReach = false;
    difReach = false;
  }
  
}

void oscEvent(OscMessage message) {
  // Print the address and typetag of the message to the console
  // println("OSC Message received! The address pattern is " + theMessage.addrPattern() + ". The typetag is: " + theMessage.typetag());

  // Check for Attention messages only
  if (message.checkAddrPattern("/attention") == true) {
    if (currentAttention != 0) { // Make sure the value is valid
      lastAttention = currentAttention;
    }
    currentAttention = message.get(0).floatValue();
    println("A: " + currentAttention);
  }
  
  // Check for Meditation messages
  if (message.checkAddrPattern("/meditation") == true) {
    if (currentMed != 0) { // Make sure the value is valid
      lastMed = currentMed;
    }
    currentMed = message.get(0).floatValue();
    println("M: " + currentMed);
  }
}
