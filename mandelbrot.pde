 static final int W = 800, H = 600;
 static final int BAILOUT_VAL = 4;
 
 static final int STEP_H = 10, STEP_W = 10;
 static final float ZOOM_STEP = .9f;
 
 double offsetW = 0, offsetH = 0; // In pixels
 double zoom = 1;
 int zoomFactor = 0;
 int n = 50;
 
 void setup()
 {
   size(800, 600);
   noLoop();
 }
 
 void draw()
 {
   clear();
   drawMB();
 }
 
 void keyPressed()
 {
   double stepX = STEP_W * zoom;
   double stepY = STEP_H * zoom;
   
   switch(keyCode)
   {
     case UP:
     case 87:
       offsetH += stepY;
       break;
     case DOWN:
     case 83:
       offsetH -= stepY;
       break;
     case LEFT:
     case 65:
       offsetW += stepX;
       break;
     case RIGHT:
     case 68:
       offsetW -= stepX;
       break;
     case 77: //M
       n++;
       break;
     case 78: //N
       if(--n < 0) n = 0;
       break;
     case 82: //R
       zoom = 1;
       offsetW = 0;
       offsetH = 0;
       n = 50;
   }
   redraw();
 }
 
 //void keyReleased()
 //{
 //  switch(keyCode)
 //  {
 //    case UP:
 //    case DOWN:
 //    case LEFT:
 //    case RIGHT:
 //      redraw();
 //      print("redrawing...");
 //  }
 //}
 
 void mouseWheel(MouseEvent event)
 {
   int count = event.getCount();
   zoom *= pow(ZOOM_STEP, -count);
   zoomFactor += count/abs(count);
   redraw();
 }
 
 void drawMB()
 {
   loadPixels();
   for(int y = 0; y < H; y++)
   {
     for(int x = 0; x < W; x++)
     {
       double re = mapToReal(x);
       double im = mapToImag(y);
       int steps = getBailoutSteps(re, im, n);
       
       int c = (int) (steps/(float) n * 255);
       if(c < 0) c = 0;
       color pixCol = color(c, c, c);
       pixels[y * width + x] = pixCol;
     }
   }
   updatePixels();
 }
 
 double mapToReal(int pixelX)
 {
   return mapDimension(pixelX, offsetW, W, 3.5, 2.5);
 }
 
 double mapToImag(int pixelY)
 {
   return mapDimension(pixelY, offsetH, H, 2, 1);
 }
 
 double mapDimension(int pxLength, double offset, int windowDimen, double a, double b)
 {
   double zoomedOffset = offset * zoom;
   double offsetDiff = offset - zoomedOffset;
   double px = (pxLength + offset) * zoom + offsetDiff;
   return px/(double) windowDimen * a - b;
 }
 
 int getBailoutSteps(double reC, double imC, int n)
 {
   double reZ = 0.0, imZ = 0.0;
   for(int i = 0; i < n; i++)
   {
     double newReZ = reZ*reZ - imZ*imZ;
     double newImZ = 2 * reZ * imZ;
     reZ = newReZ;
     imZ = newImZ;
     
     reZ += reC;
     imZ += imC;
     
     if((reZ*reZ + imZ*imZ) > BAILOUT_VAL) return i;
   }
   return -1;
 }