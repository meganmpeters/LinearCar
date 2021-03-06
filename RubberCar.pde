//Birds are cool, owl bet!
Table data;
float maxValue;
float minValue;
float average;

int plotMarginLeft = 40;
int plotMarginRight = 40;
int plotMarginBottom = 20;
int plotMarginTop = 20;
int axisHeight = 20;
float selectedSum = 0;
float selectedAvg = 0;
float mean;

int plotLeft, plotRight, plotWidth;
int plotTop, plotBottom, plotHeight;
int plotMiddle;
int axisTop, axisBottom;

ArrayList<float[]> dataPoints;

// array that coincides with data points to indicate if points are selected
ArrayList<Boolean> pointSelected;
int numSelected = 0;

PFont plotFont;
int selectedColumn = 0;// MPG column in cars.csv


// dragging selection stuff
float[] dragStart;
float[] dragEnd;
boolean dragging = false;

// Color configurations
color notSelectedColor = color(14, 21, 141, 100);
color selectedColor = color(255, 0, 0, 80);

void setup() {
  size(800, 150);
  data = loadTable("cars.csv", "header");
  
  // layout the plot boundaries
  plotLeft = plotMarginLeft;
  plotRight = width - plotMarginRight;
  plotWidth = plotRight - plotLeft;
  plotTop = plotMarginTop;
  plotBottom = height - plotMarginBottom - axisHeight;
  plotHeight = plotBottom - plotTop;
  plotMiddle = plotTop + (plotHeight / 2);
  
  // layout the axis boundaries
  axisTop = plotBottom;
  axisBottom = axisTop + axisHeight;
  axisHeight = axisBottom - axisTop;
    
  // setup the plot font
  plotFont = createFont("Arial", 12);
  textFont(plotFont);
  
  findMinMax(selectedColumn);
  println("data minimum = " + minValue + " data maximum = " + maxValue + " average = " + average);
  
    // calculate the data points for the values
  calculateDataPoints(selectedColumn);
  
}

void draw() {
  background(200);  
  // show the plot area as a white rectangle
  fill(255);
  rectMode(CORNERS);
  noStroke();
  rect(plotLeft, plotTop, plotRight, plotBottom);
  
  
  drawAxes(selectedColumn);
  
  // draw data points
  stroke(255,90);
  strokeWeight(3);
  drawDataPoints(selectedColumn);
  
  //show Column at top for navagation
  frame.setTitle(data.getColumnTitle(selectedColumn)+ " ");
  
  
  for (int i = 0; i < data.getRowCount(); i++) {
     // get the current point
     float[] point = dataPoints.get(i);
     
     // set the point line color based on whether it is selected or not
     if (pointSelected.get(i)) {
       stroke(selectedColor);  
     } else {
       stroke(notSelectedColor);
     }
     
     ellipse(point[0], point[1], 6, 6);
  }
  
  // draw the drag rectangle if we are currently dragging
  if (dragging) {
    stroke(0);
    rectMode(CORNERS);
    rect(dragStart[0], dragStart[1], dragEnd[0], dragEnd[1]);
  }
  mouseRollover(selectedColumn);
  
}



void findMinMax(int col) {
  float sum = 0; 
   // find the minimum and maximum data values for the selected column  
  for (int i = 0; i < data.getRowCount(); i++) {
    // get the current value
    float dataValue = data.getFloat(i, col); 
    if (Float.isNaN(dataValue)){
      continue;
    }
    if (i == 0) {
      // if the first data element, we need to set min and max to that value
      minValue = maxValue = dataValue;
    } else {
      // we need to test the data value and update the min and max values accordingly
      if (dataValue < minValue) {
        minValue = dataValue;
      }
      if (dataValue > maxValue) {
        maxValue = dataValue;
      }
    }
    sum += dataValue;


  average= (sum)/(data.getRowCount());

  }
}
void calculateDataPoints(int col) {
  dataPoints = new ArrayList<float[]>();
  pointSelected = new ArrayList<Boolean>();
  for (int row = 0; row < data.getRowCount(); row++) {
    float dataValue = data.getFloat(row, col);
    float x = map(dataValue, minValue, maxValue, plotLeft, plotRight);

    float jitter_y = random(14);
    float y = plotMiddle + jitter_y;
    dataPoints.add(new float[] {x, y});
    pointSelected.add(false);
  } 
}

void drawAxes(int col) {
  // draw the axis line
  mean = (selectedSum)/(numSelected);
  stroke(0);
  strokeWeight(1);
  line(plotLeft, axisTop, plotLeft, axisBottom);
  line(plotRight, axisTop, plotRight, axisBottom);
  line(plotLeft, axisTop, plotRight, axisTop);
  line(map(average, minValue, maxValue, plotLeft, plotRight), axisTop, map(average, minValue, maxValue, plotLeft, plotRight), axisBottom); //make a value for map(average, minValue, maxValue, plotLeft, plotRight), axisBottom)
  
  fill(0);
  line(map(mean, minValue, maxValue, plotLeft, plotRight), axisTop, map(mean, minValue, maxValue, plotLeft, plotRight), axisBottom);
  // draw the text labels for the min and max values
  fill(0);
  textAlign(CENTER, TOP);
  text(minValue, plotLeft, axisBottom);
  text(maxValue, plotRight, axisBottom);
  text(average, map(average, minValue, maxValue, plotLeft, plotRight), axisBottom); //make a value for map(average, minValue, maxValue, plotLeft, plotRight), axisBottom)
  text(mean, map(mean, minValue, maxValue, plotLeft, plotRight), axisBottom);

}

void drawDataPoints(int col) {
  noFill();
  for (int row = 0; row < dataPoints.size(); row++) {
    float[] point = dataPoints.get(row);
    ellipse(point[0], point[1], 6, 6);
  }  
}

void mouseRollover(int col) { //use mouseMoved
 for (int row = 0; row < data.getRowCount(); row++) {
    float dataValue = data.getFloat(row, col);
    float x = map(dataValue, minValue, maxValue, plotLeft, plotRight);
    float jitter_y = random(14);
    float y = plotMiddle + jitter_y;
    if(dist(x,y,mouseX,mouseY) < 8) {
      fill(0);
      textAlign(CENTER);
      text(dataValue, mouseX, mouseY);
    }
  }
}

void keyPressed() {
  if (key == '[') {
    selectedColumn--;
    if (selectedColumn < 0) {
      selectedColumn = data.getColumnCount() - 1;
    }
    
    //println( "[ key pressed! Current Column = " +selectedColumn);
  } else if (key == ']') {
    selectedColumn++;
    if (selectedColumn == data.getColumnCount()) {
      selectedColumn = 0;
    }
    //println( "] key pressed! Current Column = " +selectedColumn);
  } else {
    selectedColumn = selectedColumn;
  }
  
  findMinMax(selectedColumn);
  println("data minimum = " + minValue + " data maximum = " + maxValue + " average = " + average);
  
    // calculate the data points for the values
  calculateDataPoints(selectedColumn);
}

boolean dragRectangleContainsPoint(float point[]) {
  
  // First we have to determine the left, right, bottom, top.
  // If we don't do this, and the drag start is left or below the
  // drag end, the test will fail.  Try it.
  float dragRectLeft = min(dragStart[0], dragEnd[0]);
  float dragRectRight = max(dragStart[0], dragEnd[0]);
  float dragRectTop = min(dragStart[1], dragEnd[1]);
  float dragRectBottom = max(dragStart[1], dragEnd[1]);
  
  // simple test for inclusion in the rectangle
  // note the limits are inclusive (Java rectangle tests omit the right and bottom)
  if (point[0] >= dragRectLeft  && point[0] <= dragRectRight &&
      point[1] >= dragRectTop && point[1] <= dragRectBottom) {
        return true;
  }
  
  // not in the rectangle
  return false;
}

void setSelectedPoints(int col) {
  // First clear the selected points flags
  pointSelected.clear();
  numSelected = 0;
  //float selectedSum = 0;
  float selectedAvg = 0;
  
  // loop through the points array list and test for inclusion in the drag
  // rectangle.  The return value from the test function becomes the new
  // flag to indicate the point is selected.
  for (int i = 0; i < data.getRowCount(); i++) {
    boolean selected = dragRectangleContainsPoint(dataPoints.get(i));
    pointSelected.add(selected);
    if (selected) {
      numSelected++;
      Float selectedSum = data.getFloat(i,col);
    }
    selectedAvg = selectedSum/numSelected;
    //println("average = " + selectedAvg); //avg of pixels not data
  //text(mean, map(mean, minValue, maxValue, plotLeft, plotRight), axisBottom);
  //line(map(selectedAvg, minValue, maxValue, plotLeft, plotRight), axisTop, map(selectedAvg, minValue, maxValue, plotLeft, plotRight), axisBottom); //make a value for map(average, minValue, maxValue, plotLeft, plotRight), axisBottom)
  //^^ mouserollover doesnt work anymore????
  } 
} 

// When the mouse is pressed we set the start and end drag rectangle corners to 
// the mouse x, y location.
void mousePressed() {
  dragStart = new float[2];
  dragStart[0] = mouseX;
  dragStart[1] = plotTop;
  dragEnd = new float[2];
  dragEnd[0] = mouseX;
  dragEnd[1] = plotBottom; 
}

// When the mouse is dragged, update the mouse end position and then we
// call a method to set all points inside the drag rectangle bounds. 
void mouseDragged() {
  dragging = true;
  dragEnd[0] = mouseX;
  dragEnd[1] = plotBottom;
  
  setSelectedPoints(selectedColumn);
 
  //if(dragging = true) {
  float selectedSum = 0;
  float mean;
  //selectedSum = pointSelected;
  //mean of points seleted
  //for loop
   mean = (selectedSum)/(numSelected);
  fill(0);
  line(map(mean, minValue, maxValue, plotLeft, plotRight), axisTop, map(mean, minValue, maxValue, plotLeft, plotRight), axisBottom);
   text(mean, map(mean, minValue, maxValue, plotLeft, plotRight), axisBottom);
//}

}

// When the mouse is released, clear the mouse dragging flag.
// Other things could happen in this function to make the selection final
// for example you may update the average of the points.  
void mouseReleased() {
  dragging = false;
}
