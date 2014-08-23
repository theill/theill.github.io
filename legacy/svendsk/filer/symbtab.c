/* [ S V E N D S K - Symbol Tabel ] - En Svendsk -> JAVA Compiler
                     symbtab.c
   (c)1998, Peter Theill og Ken Christensen
   
   F›rste version d. 8 maj 1998                   Sidste ‘ndring d. 18 maj 1998
*/

#include <stdio.h>
#include <malloc.h>
#include <string.h>
#include "symbtab.h"

static struct SYMB* symbtab = NULL;
static int gScope;

int lookup(char* s)
{
  // Returnerer typen hvis fundet, ellers T_UNDEF
  
  struct SYMB* tmp = symbtab;
  
  while(tmp != NULL)
    if(gScope >= tmp->scope && strcmp(tmp->navn, s) == 0)
      return(tmp->type);
    else
      tmp = tmp->naeste;
      
  return(T_UNDEF);

}

void insert(char* s, int t)
{

  struct SYMB* ny = NULL;

  if (lookup(s) != T_UNDEF)
    return;
    
  ny = (struct SYMB*)malloc(sizeof(struct SYMB));
  
  ny->navn = (char*)malloc(strlen(s)+1);
  strcpy(ny->navn, s);
  
  ny->type = t;
  ny->scope = gScope;
  ny->naeste = symbtab;
  symbtab = ny;
  
}

void openScope()
{ gScope++; }

void closeScope()
{
  struct SYMB* tmp = symbtab;

  while( (tmp != NULL) && (tmp->scope == gScope) )
  {
    symbtab = symbtab->naeste;
    
    if(tmp->navn != NULL)
      free(tmp->navn);
    
    free(tmp);
    
    tmp = symbtab;
  }
  
  gScope--;

}

int getScope()
/* Returnerer hvilket scope man befinder sig i */
{ return(gScope); }


void udskrivTabel()
/* Udskriver den k‘dede liste. Funktionen bruges kun til test */
{

  struct SYMB* top = symbtab;
  
  while( top != NULL )
  {
    printf("Navn   : %s\n Type  : %d\n  Scope: %d\n", top->navn, top->type, top->scope);
    top = top->naeste;
  }

}
