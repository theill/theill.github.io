/* [ S V E N D S K - Loops ] - En Svendsk -> JAVA Compiler
     loops.h - Headerfil til loops.c
   (c)1998, Peter Theill og Ken Christensen
   
   F›rste version d. 14 maj 1998                  Sidste ‘ndring d. 18 maj 1998
*/

/* Hver entry i den k‘dede liste */
struct sttLoop
{

  int No;
  struct sttLoop* Next;

};

void newLoop(int fNo);
void freeLoop(void);
int getLastLoop(void);
int getLastLoopValue(void);
void printList(void);
