/*

 * COMP 1010 SECTION A01
 * INSTRUCTOR: Amir Hosseinmemar 
 * NAME: Devin Sebastian Efendy 
 * ASSIGNMENT: Assignment 5 
 * QUESTION: Question 2
 * PURPOSE: Make a sudoku game, which:
 1. only accept unique number and reject
    the same number in the same row, column, and sub-grid
 2. can erase any user input number and not given number
 3. detect when the game is over
 4. showing notice or message through a window dialog
 
 
 */

import javax.swing.JOptionPane;
final int GRID_DIMENSION = 9;

//Storing all coordinates(intersection-point) for number
float[] allPosition = new float[GRID_DIMENSION];

//detect a cell is empty or not
boolean cellIsEmpty;

//boolean for functional mouse click
boolean mouseClockBool1 = false;
boolean mouseClockBool2 = false;

//to check unique numbers
boolean sameRow;
boolean sameColumn;
boolean sameSubGrid;

//detect when all cells are filled
boolean itsOver;

//Starting number
String[] givenSudokuArray = 
  { "",  "", "2",    "", "8",  "",   "5",  "",  "", 
   "8",  "", "1",   "2", "5", "7",    "", "4", "9", 
    "", "4",  "",    "",  "", "3",   "8", "2", "7",

    "", "8", "4",   "1", "9",  "",    "",  "", "3", 
   "3",  "",  "",   "7",  "", "5",   "2",  "",  "", 
   "1",  "", "7",    "", "3", "2",    "",  "",  "", 

    "",  "",  "",    "", "7", "8",    "",  "",  "", 
    "", "6",  "",    "",  "", "9",   "1",  "",  "", 
    "", "2", "8",   "5",  "",  "",    "", "7", "4"};

//new sudoku array which is a deep copy from array above
String[] sudokuArray;

//Store all indeces in particular sub-grid
int[] subGridPos = new int[9];





void setup()
{
  size(300, 300);
  allPosition = calcPosition();
  sudokuArray = copySudoku(givenSudokuArray);
}

void draw()
{
  background(192);
  drawGrid();
  fillNum(sudokuArray, allPosition);
  gameOver();
  //println(subGridPos);
}

void drawGrid()
{
  /*
   purpose   : draw the grid
   input     : none
   output    : 9x9 grid
   parameter : none
   return    : void(none)
   */

  float xLine, yLine ;
  for (float x = 0, y = 0; x <= GRID_DIMENSION && y <= GRID_DIMENSION; x++, y++)
  {
    if ( x % 3 == 0 ) //to make the sub-grid
    {
      strokeWeight(4);
    } else
    {
      strokeWeight(1);
    }
    //width or height -1 to make the right margin look thicker
    yLine = (width-1)*(x/(GRID_DIMENSION));
    xLine = (height-1)*(y/(GRID_DIMENSION));

    stroke(0);
    line(yLine, 0, yLine, height);//draw the line in y-axis
    line(0, xLine, width, xLine);//draw the line in x-axis
  }
}

float[] calcPosition()
{
  /*
   purpose   : calculate and put the every position of the intersection point
   input     : none
   output    : array containing the list of position
   {0, 33.333, ... , 265} 
   parameter : none
   return    : float array
   */
  float[] array = new float [GRID_DIMENSION];//create a local arary

  for (float x = 0; x < GRID_DIMENSION; x++)
  {
    //store the coordinate values into the array
    array[int(x)] = (width-1)*(x/(GRID_DIMENSION));
  }
  return array;
}

void fillNum(String[] numList, float[] posCoordinate)
{
  /*
   purpose   : fill the cells correctly
   input     : sudokuArray, allPosition
   output    : fill the number in every cells
   parameter : string array, float array
   return    : void
   */

  int indexCount = 0;//keep track of index

  for (float y = 0; y < posCoordinate.length; y++)
  {
    float numY = posCoordinate[int(y)];

    for (float x = 0; x < posCoordinate.length; x++)
    {
      float numX = posCoordinate[int(x)];

      //Calculation to make the number placed in the middle of the box
      float textX = numX + (width-1)/GRID_DIMENSION/2 
                    - textWidth(numList[indexCount])/2;                  
      float textY = numY + (height-1)/GRID_DIMENSION - 
                    (height-1)/GRID_DIMENSION/2 + textDescent();

      //Calling the created function
      drawNumbers(numList, textX, textY, indexCount);
      checkEmptyCells(numList, numX, numY, indexCount);

      insertChar(numList, cellIsEmpty, indexCount, numX, numY);

      boolean givenNum = checkIfGivenNum(detectGivenNumber(givenSudokuArray), indexCount);
      removeNum(numList, numX, numY, indexCount, givenNum);

      checkRow(numList, int(y), numX, numY);
      checkColumn(numList, int(x), numX, numY);

      storeSubGridIndex(int(x), int(y), numX, numY);
      checkSubGrid(subGridPos, numList);

      indexCount++;
    }//end of the loop x
  }//end of the loop y

  //P.S: the loop will go to y = 0 first and then it will go from x = 0 until x = 8
  //     to create the coordinate (0,0);(1,0);(2,0);... etc
  //     then it will go to y = 1 and repeat the process (0,1);(1,1);(2,1);... etc
}

void checkEmptyCells(String[] array, float x, float y, int count)
{
  /*
   purpose   : to check wheter a cells is empty or not
   input     : the perimeter of cells, array, array index
   output    : change the value of cellIsEmpty
   parameter : String array, float, int
   return    : void
   */
  if (mouseX < x + (width-1)/GRID_DIMENSION && mouseX > x &&
    mouseY < y + (height-1)/GRID_DIMENSION && mouseY > y)
  {
    if (array[count].equals(""))
    {
      cellIsEmpty = true;
    }// true if the cells is not yet filled

    else
    {
      cellIsEmpty = false;
    }//false if the cells is filled
  }//if (detect mouse location)
}

void drawNumbers(String[] list, float x, float y, int count)
{
  /*
   purpose   : draw the numbers in the cell, and distinguish between
   given number and user input number with changing the color
   input     : sudokuArray, perimeter of cells, sudokuArray index
   output    : draw the number in the cells
   parameter : String array, float, int
   return    : void none
   */

  //call the checkIfGivenNum and store its value into a boolean variable
  boolean givenNum = checkIfGivenNum(detectGivenNumber(givenSudokuArray), count);

  if (count < list.length)
  {
    if (givenNum)
    {
      fill(0, 0, 255);
    }//Color blue for given number 
    else
    {
      fill(0);
    }//black for user input

    //draw the number
    textSize((int)width/20);
    text(list[count], x, y);
  }
}

String[] copySudoku(String[] array)
{
  /*
   purpose   : to make(deep copy) another array. So the array of given number
   and the array of real sudoku array is different
   input     : givenSudokuArray
   output    : sudokuArray
   parameter : String array
   return    : String array
   */

  String[] newArray = new String[array.length];

  for ( int i = 0; i < array.length; i++)
  {
    newArray[i] = array[i];
  }
  return newArray;
}

int[] detectGivenNumber(String[] array)
{
  /*
   purpose   : to store an given numbers into an array
   input     : givenSudokuArray
   output    : an array containing all given numbers
   parameter : String array
   return    : Integer array
   */

  int givenNumIndex[] = new int[38]; //create local int array
  int indexCount = 0; //keep track of index

  for (int i = 0; i < array.length; i++)
  {
    if (!array[i].equals(""))
    {
      givenNumIndex[indexCount] = i;
      indexCount++;
    }//Store anygiven number into the local int array
  }//end of the loop
  return givenNumIndex;//return {2,8,5, ... , 4} all given number
}

boolean checkIfGivenNum(int[] array, int count)
{
  /*
   purpose   : To check wheter a number inside a cell a given number or not
   input     : array from detectGivenNumber(String[] array), sudokuArray index
   output    : boolean value that detect wheter a number is given or not
   parameter : int array, and int
   return    : boolean value
   */
  boolean givenNum = false;

  for (int i = 0; i < array.length; i++)
  {
    if (array[i] == count)
    {
      givenNum = true;
      break;
    } else
    {
      givenNum = false;
    }
  }
  return givenNum;
}

char inputCharacter()
{
  /*
   purpose   : to store keyPressed into a char value
   input     : none
   output    : keyOutput
   parameter : none
   return    : char value
   */
  char keyInput = key;
  char keyOutput = 0;

  if (key > 48 && key < 58)
  {
    keyOutput = keyInput;
  }

  return keyOutput;
}


void insertChar(String[] array, boolean emptyCell, int count, float x, float y)
{
  /*
   purpose   : to insert/add a number into a correponding array index
   input     : sudokuArray, emptyCell, sudokuArray index, perimeter of cells
   output    : insertion of a number into a array index
   parameter : String array, boolean int, float
   return    : void
   */
  if (mouseX < x + (width-1)/GRID_DIMENSION && mouseX > x &&
    mouseY < y + (height-1)/GRID_DIMENSION && mouseY > y && 
    inputCharacter() != 0)
  {  
    if (mousePressed)
    {
      mouseClockBool1 = true;
    } //if mousePressed

    else if (mouseClockBool1)
    {
      mouseClockBool1 = false;
      mouseClockBool2 = true;
    }//if mouse released after mouse clicked

    else if (mouseClockBool2)
    {
      if (!emptyCell)
      {
        JOptionPane.showMessageDialog(null, "Already filled!");
      } // detect if a cell already filled

      else if (sameRow || sameColumn || sameSubGrid) 
      {
        JOptionPane.showMessageDialog
          (null, "Can't put same numbers in the same row, column, and sub-grid!");
      } // detect same number in a row, column, and sub-grid

      else
      {
        array[count] = str(inputCharacter());
      } // insert a number, if all conditions above are false

      mouseClockBool1 = false;
      mouseClockBool2 = false;
    }//code executed after mouse released
  }
}

void keyReleased()
{
  /*
   purpose   : to detect which key being pressed
   input     : none
   output    : key
   parameter : none
   return    : void
   */
  if (key > 48 && key < 58)//ASCII table value for number between 1-9
  {
    println(" ");
    println("Character typed : " +key);
    println("Now you can click on the cell...");
  } //if number 1-9 pressed

  else if (key == 'c')
  {
    println(" ");
    println("You can remove a number!");
  } //if "c" pressed
  else
  {
    JOptionPane.showMessageDialog(null, "Please enter a valid number (1-9)");
  }//if anything other than above pressed
}

void removeNum(String[] array, float x, float y, int count, boolean startNum)
{
  /*
   purpose   : to remove a number in sudokuArray
   input     : sudokuArray, index, startNum, perimeter of cells
   output    : the removal of index in sudokuArray
   parameter : String array, float, int, boolean
   return    : none
   */
  if (mouseX < x + (width-1)/GRID_DIMENSION && mouseX > x &&
    mouseY < y + (height-1)/GRID_DIMENSION && mouseY > y)
  {  
    if (mousePressed && key == 'c')
    {
      if (startNum)
      {
        JOptionPane.showMessageDialog(null, "Can't delete given numbers!");
        key = 0;//force change the key value so the message dialog box
        //won't be repeated
      }//if the users try to delete a given number

      else
      {
        array[count] = "";
      }//if the users delete their own inserted number
    }
  }
}

void checkRow(String[] array, int y, float numX, float numY)
{
  /*
   purpose   : to check if a number is unique in a particular row
   input     : sudokuArray, y value of cells, perimeter of cells
   output    : changes in sameRow value(true or false)
   parameter : String array, int, float
   return    : none
   */
  if (mouseX < numX + (width-1)/GRID_DIMENSION && mouseX > numX &&
    mouseY < numY + (height-1)/GRID_DIMENSION && mouseY > numY)
  {
    for (int i = y*9; i < (y*9) + 9; i++)
    {
      if (array[i].equals(str(inputCharacter())))
      {
        sameRow = true;
        break;//to get out off the loop so it won't change the sameRow
        //value to false
      }//detect a same number in a row

      else
      {
        sameRow = false;
      }//if there's no same number in a row
    }//end of the loop
  }
}

void checkColumn(String[] array, int x, float numX, float numY)
{
  /*
   purpose   : to check if a number is unique in a particular column
   input     : sudokuArray, x value of cells, perimeter of cells
   output    : changes in sameColumn value(true or false)
   parameter : String array, int, float
   return    : none
   */
  if (mouseX < numX + (width-1)/GRID_DIMENSION && mouseX > numX &&
    mouseY < numY + (height-1)/GRID_DIMENSION && mouseY > numY)
  {
    for (int i = x; i <= x+72; i += 9 )
    {
      if (array[i].equals(str(inputCharacter())))
      {
        sameColumn = true;
        break;//to get out off the loop so it won't change the sameRow
        //value to false
      }//detect a same number in a column
      else
      {
        sameColumn = false;
      }//if there's no same number in a column
    }//end of the loop
  }
}
void storeSubGridIndex(int x, int y, float numX, float numY)
{
  /*
   purpose   : to store all number inside a sub-grid into an array(subGridPos)
   input     : perimeter of cells, x and y values of the cells
   output    : changes/insertion of value in subGridpos
   parameter : int, float
   return    : none
   */
  int count = 0;
  if (mouseX < numX + (width-1)/GRID_DIMENSION && mouseX > numX &&
    mouseY < numY + (height-1)/GRID_DIMENSION && mouseY > numY)
  {
    for (int m = x, xL = 0, xR = 2; xL <=6 && xR <=8; xL +=3, xR +=3) //checkRow in sub-grid
    {
      if (m <= xR && m >= xL)//detect mouseX position in which xL and xR range
      {
        for (int i = xL; i <= xR; i++)//iteration for every new xL in the range of xL to xR
        {
          for (int n = 0; n < 3; n++)//iteration for every n in xL
          {
            int index = 0;
            if (y <= 2)
            {
              index = (i+n*9);
            }//if mouseY position is between y = 0 and y = 2

            else if (y <= 5 && y > 2)
            {
              index = (i+n*9)+27;
            }//if mouseY position is between y = 3 and y = 5

            else if (y <= 8 && y > 5)
            {
              index = (i+n*9)+54;
            }//if mouseY position is between y = 6 and y = 8

            subGridPos[count] = index;
            count++;
          }//end of the n loop
        }//end of the i loop
      }//if mouseX is between xL and xR
    }//end of m loop
  }

  /*P.S : 1. the first loop will detect if the location of mouseX value is between xL and xR. 
             xL start from 0 and xR start from 2 which are all left side sub-grid.
             and will both wil be incremented by 3, according to mouseX position,
             to 3-5(all middle sub-grid) and  6-8(all right side sub-grid).
             
          2. Let's say the mouseX is between 0-2. the second loop will store the value
             of xL and incremented it by 1 until it reach xR. Therefore, we have 3 values
             which are i = 0, i = 1, i = 2.
          
          3. Inside the third for loop, it will detect where is mouseY position(lets say the mouseY position is between y 0-2) 
             and it will calculate the formula of each corresponding i and n values
             with the results of 9 new values(0,9,18,1,10,19,2,11,20) which are
             all of the index in top-left sub-grid and store it into an array.
   */
}


void checkSubGrid(int[] subArray, String[] array)
{
  /*
   purpose   : to check if a number is unique in a particular sub-grid
   input     : subGridPos, sudokuArray
   output    : changes in sameSubGrid value(true or false)
   parameter : int array, String array
   return    : none
   */
  for (int i = 0; i < 9; i++)
  {
    int indexAt = subArray[i];
    if (array[indexAt].equals(str(inputCharacter())))//check every index in subGrid array
    {
      sameSubGrid = true;
      break;
    }//detect a same number in a sub-grid
    else
    {
      sameSubGrid = false;
    }//if there's no same number in a sub-grid
  }//end of the loop
}

void gameOver()
{
  /*
   purpose   : to detect if all the cells is filled correctly
   input     : none
   output    : changes in itsOver value(true or false)
   parameter : none
   return    : void
   */
  for (int i = 0; i < sudokuArray.length; i++)
  {
    if (sudokuArray[i].equals(""))
    {
      itsOver = false;
      break;//to not let i become equal to sudokuArray.length-1
            //if there's still empty string in the array.
    }//if there's an empty string

    if (i == sudokuArray.length-1)
    {
      itsOver = true;
    }//if there's not any empty string anymore
     //and i equal to sudokuArray.length-1
  }

  if (itsOver)
  {
    JOptionPane.showMessageDialog
      (null, "Congratulations! You have completed the game!");

    itsOver = false;
  }//if game over show message dialog
}