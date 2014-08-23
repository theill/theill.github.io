/* [ S V E N D S K - Loops ] - En Svendsk -> JAVA Compiler
     loops.c - holder styr p† en l›kke, dvs dets nummer
   (c)1998, Peter Theill og Ken Christensen
   
   F›rste version d. 14 maj 1998                  Sidste ‘ndring d. 18 maj 1998
*/

#include <alloc.h> // malloc(), NULL
#include <stdio.h> // fprintf()
#include "loops.h"

// Vores k‘det liste af l›kker
static struct sttLoop* gLoopList = NULL;

void newLoop(int fNo)
{
  // Tilf›jer en ny loop-struct til listen

  struct sttLoop* aLoop = NULL;
  
  aLoop = (struct sttLoop*)malloc(sizeof(struct sttLoop));
  
  // Check for allokerings fejl (ikke nok mem.)
  if (aLoop == NULL)
  {
    printf("Fejl: Allokering af memory.\n");
    exit(-1);
  }

  aLoop->No = fNo;
  
  aLoop->Next = gLoopList;
  gLoopList = aLoop;

}

void freeLoop(void)
{
  /* Sletter *DEN SIDST TILFJEDE* loop-struct fra listen, dvs. l‘s det f›rste
     element fra listen. */
  
  struct sttLoop* aLoop = gLoopList;
  
  gLoopList = aLoop->Next;

  aLoop->Next = NULL;
  free(aLoop);

}

int getLastLoopNo(void)
{
  // Returnerer sidste loop-nummer (f›rste element)

  if(gLoopList != NULL)
    return(gLoopList->No);
  else
    return(-1);

}

void printList(void)
{
  // Udskriver listen. Bruges kun til test af rutinen

  struct sttLoop* list = gLoopList;
  
  while(list != NULL)
  {
    fprintf(stdout, "Loop: %d\n", list->No);
    list = list->Next;
  }

}

/* TEST ONLY
void main()
{

  newLoop(0, 1);
  newLoop(1, 11);
  newLoop(2, 22);
  freeLoop();
  
  printList();
  printf("hej %d\n", getLastLoopNo());
  
}
*/
