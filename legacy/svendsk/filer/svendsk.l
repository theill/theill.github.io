/* [ S V E N D S K - FLEX specifikation ] - En Svendsk -> Java compiler
     - En scanner for Svendsk. (c)1998, Peter Theill og Ken Christensen

  F›rste 'ndring d. 29 april 1998                Sidste 'ndring d.  18 maj 1998
  
  Se LOGFILE.TXT for udviklingsforl›b
*/

%{
#include "svendsk.h"
#include "symbtab.h"
#define FALSE   0
#define TRUE    1
extern int USABLE_CODE;
int yylineno = 1, yycharno = 1;
int yylex(void);
//#define USELEXMAIN
void check_for_newline();
void make_name_and_type(char* text);
%}

%name flex

/* -[ D E F I N I T I O N E R ]--------------------------------------------- */
/* Se 'Designovervejelser' for beskrivelse af definitionerne */

mellemrum       [ \t]+
kommentar       ";>"([^<]|"<"[^;])*"<;"
ciffer          [0-9]
bogstav         [A-Za-z]
id              {bogstav}({bogstav}|{ciffer}|_)*
var_erklaer     {id}\.({typer})"()"
tal             -?[1-9]{ciffer}*|0
typer           heltal|boolsk|streng
afbryd          afbryd"()"
nylinie         nylinie"()"
tabulator       tabulator"()"
ascii_tegn      [^\"\n]
escape_tegn     \\\"|\\n
lovlig_tekst    \"({ascii_tegn}|{escape_tegn})*\"

%% /* -[ R E G L E R ]------------------------------------------------------ */

{kommentar}     { check_for_newline(); }
{mellemrum}     { yycharno++; }
"\n"            { yylineno++; yycharno=1; }
SVENDSK         { return(SVENDSK); }
ITERATION       { return(ITERATION); }
hvis            { return(HVIS); }
ellers          { return(ELLERS); }
{afbryd}        { return(AFBRYD); }
{nylinie}       { return(NYLINIE); }
{tabulator}     { return(TABULATOR); }
skriv           { return(SKRIV); }
laes            { return(LAES); }
sand            { return(SAND); }
falsk           { return(FALSK); }
og              { return(OG); }
eller           { return(ELLER); }
ikke            { return(IKKE); }
{var_erklaer}   { make_name_and_type( yytext );
                  return(VAR_ERKLAER); }
{id}            { yylval.navn = (char*)malloc(strlen(yytext)+1);
                  strcpy(yylval.navn, yytext);
                  return(ID); }
{lovlig_tekst}  { return(LOVLIG_TEKST); }
{tal}           { yylval.vaerdi = (char*)malloc(strlen(yytext)+1);
                  strcpy(yylval.vaerdi, yytext);
                  return(TAL); }
"-="            { return(IKKELIG); }
">="            { return(STOERRELIG); }
"<="            { return(MINDRELIG); }
">>"            { return(FELT_START); }
"<<"            { return(FELT_STOP); }
"="             { return('='); }
"+"             { return('+'); }
"-"             { return('-'); }
"*"             { return('*'); }   
"/"             { return('/'); }
"<"             { return('<'); }
">"             { return('>'); }
","             { return(','); }
"("             { return('('); }
")"             { return(')'); }
"["             { return('['); }
"]"             { return(']'); }
"{"             { return('{'); }
"}"             { return('}'); }
.               { yycharno++; return(0); }

%% /* -[ S U P P O R T   R U T I N E R ]------------------------------------ */

void check_for_newline()
/* Check'er om der er ny linie i en kommentar. Hvis det er tilf'ldes, opt'lles
   linie-counteren.
*/
{

  int i;
  
  for(i=0;i<strlen(yytext);i++)
    if(yytext[i] == '\n')
      yylineno++;

}

void make_name_and_type(char *text)
/* Udleder ID og TYPE ud fra en Svendsk variabel-erkl'ring, fx i.heltal()

   Parameter
    char *text  : Strengen med en Svendsk variabel-erkl'ring
*/
{

  int i = 0, j = 0;
  char *id;
  char type[] = "**********"; // allokering af plads til typen. Max. 10 tegn 
  
  // Find ID'et
  while(text[i] != '.')
    i++;
  
  id = (char *)strdup(text);

  id[i] = '\0';
  
  // Spring '.' over
  i++;

  // Find typen
  while(text[i] != '(')
    type[j++] = text[i++];

  type[j] = '\0';

  // Returnerer navn
  yylval.navn = (char*)malloc(strlen(id));
  strcpy(yylval.navn, id);
 
  // Find og returnerer type
  if (strcmp(type, "heltal") == 0)
    yylval.type = T_HELTAL;
  else if (strcmp(type, "boolsk") == 0) 
    yylval.type = T_BOOLSK;
  else if (strcmp(type, "streng") == 0)
    yylval.type = T_STRENG;

  // Check om den findes i symboltabellen
  if(lookup(id))
  {
    printf("Fejl: linie %d, tegn %d - Variablen %s allerede erkl'ret!\n", yylineno, yycharno, id);
    USABLE_CODE = FALSE;
  }
  else // Inds't i symboltabellen
    insert(id, yylval.type);
    
}

#ifdef USELEXMAIN
int main(int argc, char* argv[])
{
  // Kald til Svendsk.exe: Svendsk <kildefil>

  // Check antallet af parametre (vi skal bruge to)
  if (argc != 2)
  {
    printf("Syntaks: %s <kildefil>\n", argv[0]);
    exit(-1);
  }
                  
  // Open file with Svendsk-kode
  if ( (yyin = fopen(argv[1], "r")) == NULL )
  {
    fprintf(stderr, "Filen '%s' kunne ikke †bnes!\nEr navnet stavet rigtigt?", argv[1] );
    exit(-2);
  }
                  
  printf("%d",yylex());
}
#endif