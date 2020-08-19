/* [ S V E N D S K - BISON specifikation ] - En Svendsk -> JAVA compiler
  (c)1998, Peter Theill og Ken Christensen

  F›rste version d. 29 april 1998                Sidste ‘ndring d. 27 maj 1998

  Se 'logfile.txt' for et udviklingsforl›b
*/

/* Bem‘rk:
    Det var meningen vi ville medtage funktioner i Svendsk, men grundet tids-
    mangel er det IKKE n†et. Vi har dog valgt ikke at slette funktionerne fra 
    grammatikken, da vi mener det giver et indblik i, hvordan Svendsk ville
    have h†ndteret funktioner.    
    Vi har udkommenteret alt kode relateret til funktioner med f›lgende tekst:

      funktioner - ikke implementeret
    
*/

%{
#include <stdio.h>
#include <stdarg.h>                         // va_list (varibel param.-liste)
#include "symbtab.h"                        // Symboltabellen
#include "loops.h"                          // L›kker
#define FALSE   0
#define TRUE    1
int USABLE_CODE = TRUE;                     /* Brugbar kode flag. S‘ttes til
                                               false, hvis den genererede kode
                                               ikke kan bruges, grundet en
                                               fejl i overs‘ttelsen. */

extern FILE *yyin;                          // Inputfil (Svendsk-programmet) 
FILE *foutput;                              // Outputfil (Java-programmet)
extern int yylineno, yycharno;              // Linie- og tegn-nummer
extern char* yytext;                        // yytext -> n‘ste token
int codeX = 0;                              // Formattering af Java-kode
char* gFileName;                            // Java-filnavn, fx Hello.java
int gLoops = 0;                             // Holder styr p† l›kkerne
#define USEYACCMAIN                         // TEST!!!

void typeCheck(int t1, int t2);

/* Formattering af kodegenerering */
void o(char *fmt, ...);
void fo(char *fmt, ...);

/* F›lgende doJava.. funktioner er hj‘lpefunktioner til kode-generering */
void doJavaPadding(int n);
void doJavaMain(char* n);
void doJavaVariable(const char* v);
void doJavaLoop(char* t, char* sign);
void doJavaFilename(char* f);
void doJavaIteration();
void doJavaLaes(char* id);

char* getJavaType(int t);
%}

%union
{
  char* navn;
  char* vaerdi;
  int type;
}

%start svendsk_program

   /* -[ D E K L A R A T I O N E R ]---------------------------------------- */
   
%token SVENDSK
%token VAR_ERKLAER
%token <navn> ID

/* Funktioner - ikke implementeret
%token START STOP
%token FUNKTIONER FUNKTION RETURNERER
*/

%token FELT_START FELT_STOP
%token HVIS ELLERS
%token AFBRYD
%token NYLINIE TABULATOR
%token SKRIV LOVLIG_TEKST LAES
%token SAND FALSK
%token <vaerdi> TAL
%token ITERATION

%type <type> udtryk

/* Bindinger (›verst har h›jst prioritet) */
%left ELLER
%left OG
%left '=' IKKELIG
%left '<' '>' MINDRELIG STOERRELIG
%left '+' '-'
%left '*' '/'
%right UMINUS IKKE

%% /* -[ R E G L E R ]------------------------------------------------------ */
   /* Alle tokens er skrevet med stort.
      S‘tninger afsluttes med ';'.                                           */


svendsk_program : SVENDSK ID { insert($2, T_PROGRAM); doJavaFilename($2); }
                { doJavaMain($2); codeX += 4; }
                variabel_liste
                
/* Funktioner - ikke implementeret
                funktions_hoved
*/
               
                FELT_START variabel_liste saetnings_liste FELT_STOP
                { codeX-=2; fo("}\n"); codeX-=2; fo("}\n"); }
                ;
                                      
/* Funktioner - ikke implementeret
funktions_hoved : FUNKTIONER START funktions_liste FUNKTIONER STOP
                | // epsilon
                ;
*/
           
variabel_liste  : variabel variabel_liste
                | /* epsilon */
                ;
                
variabel        : VAR_ERKLAER {doJavaVariable(yytext);}
                ;
                  
/* Funktioner - ikke implementeret
funktions_liste : funktion funktions_liste 
                | // epsilon
                ;
                
funktion        : FUNKTION ID { insert($2, T_FUNKTION); } '(' parameter_liste ')' returnering 
                  FELT_START { openScope(); codeX += 2; } saetnings_liste FELT_STOP
                  { closeScope(); codeX -= 2; }
                ;
                  
returnering     : RETURNERER variabel 
                | // epsilon
                ;
                 
parameter_liste : parameter
                | // epsilon
                ;
                  
parameter       : variabel
                | parameter ',' variabel
                ;
*/

saetnings_liste : saetning saetnings_liste
                | /* epsilon */
                ;
                  
saetning        : ID {fo("%s", $1); 
                       if(!lookup($1))
                         yyerror("%s ikke erkl‘ret\n", $1);}
                  '=' {o(" = ");}
                  udtryk {typeCheck(lookup($1), $5); o(";\n");}

                | variabel

/* Funktionskald - ikke implementeret!
                | ID '(' parameter_liste ')'
*/

                | HVIS '(' {fo("if("); } udtryk ')' { o(")\n");}
                  saetning ellers_del

                | loop_tal '{' {newLoop(gLoops++); fo("do {\n"); codeX += 2;}
                  saetnings_liste '}' loop_type {freeLoop();}
                  
                | FELT_START {openScope(); fo("{\n"); codeX+=2;}
                  saetnings_liste FELT_STOP { codeX-=2; closeScope(); fo("}\n");}
                  
                | AFBRYD {fo("break;\n"); if(getLastLoopNo() == -1)
                  yyerror("Fejl: 'afbryd()' kan ikke bruges uden for l›kker");}
                  
                | NYLINIE {fo("System.out.print('\\n');\n");}
                
                | TABULATOR {fo("System.out.print('\\t');\n");}
                
                | SKRIV '(' {fo("System.out.print(");}
                  skriv_indhliste 
                  ')' {o(");\n");}
                  
                | LAES '(' ID {typeCheck(lookup($3), T_STRENG);
                  if(!lookup($3)) yyerror("%s ikke erkl‘ret\n", $3);} 
                  ')'
                  {doJavaLaes($3);}
                ;
                  
ellers_del      : ELLERS { fo("else\n");} saetning
                | /* epsilon */
                ;
                  
loop_tal        : TAL {fo("int loop%d = %s;\n", gLoops, yytext);}
                | ID { if(!lookup($1)) yyerror("%s ikke erkl‘ret\n", $1);
                  typeCheck(lookup($1), T_HELTAL);
                  fo("int loop%d = %s;\n", gLoops, $1);}
                ;

loop_type       : '+' {fo("loop%d++;\n", getLastLoopNo()); codeX-=2;
                  fo("} while(true);\n");}
                | '-' {o("loop%d--;", getLastLoopNo()); codeX-=2;
                  fo("} while(true);\n");}
                | TAL loop_plus_minus { doJavaLoop($1, yytext); }
                | ID {if(!lookup($1)) yyerror("%s ikke erkl‘ret\n", $1);
                  typeCheck(lookup($1), T_HELTAL);} loop_plus_minus
                  { doJavaLoop($1, yytext); }
                ;
                  
loop_plus_minus : '+'
                | '-'
                ;
                 
skriv_indhliste : skriv_indh skriv_indhliste
                | /* epsilon */ {o("\"\"");}
                ;
                
skriv_indh      : '[' udtryk ']' {o(" + ");}
                | LOVLIG_TEKST {o("%s + ", yytext);}
                ;
                
udtryk          : udtryk {typeCheck($1, T_HELTAL);} '+' {o(" + ");} udtryk 
                  {typeCheck($5, T_HELTAL); $$ = T_HELTAL; }
                | udtryk {typeCheck($1, T_HELTAL);} '-' {o(" - ");} udtryk 
                  {typeCheck($5, T_HELTAL); $$ = T_HELTAL; }
                | udtryk {typeCheck($1, T_HELTAL);} '*' {o(" * ");} udtryk
                  {typeCheck($5, T_HELTAL); $$ = T_HELTAL; }
                | udtryk {typeCheck($1, T_HELTAL);} '/' {o(" / ");} udtryk
                  {typeCheck($5, T_HELTAL); $$ = T_HELTAL; }
                | '-' udtryk %prec UMINUS {typeCheck($2, T_HELTAL);
                  o("-"); $$ = T_HELTAL; }
                | '(' {o("(");} udtryk ')' {o(")"); $$ = $3; }
                | udtryk {typeCheck($1, T_HELTAL);} '<' {o(" < ");} udtryk
                  {typeCheck($5, T_HELTAL); $$ = T_BOOLSK;}
                | udtryk {typeCheck($1, T_HELTAL);} '>' {o(" > ");} udtryk
                  {typeCheck($5, T_HELTAL); $$ = T_BOOLSK; }
                | udtryk '=' {o(" == ");} udtryk
                  {typeCheck($1, $4); $$ = T_BOOLSK;}
                | udtryk IKKELIG {o(" != ");} udtryk
                  {typeCheck($1, $4); $$ = T_BOOLSK;}
                | udtryk STOERRELIG {o(" >= ");} udtryk {typeCheck($1, $4);}
                | udtryk MINDRELIG {o(" <= ");} udtryk {typeCheck($1, $4);}
                | udtryk {typeCheck($1, T_BOOLSK);} OG {o(" && ");} udtryk
                  {typeCheck($5, T_BOOLSK); $$ = T_BOOLSK;}
                | udtryk {typeCheck($1, T_BOOLSK);} ELLER {o(" || ");} udtryk
                  {typeCheck($5, T_BOOLSK); $$ = T_BOOLSK;}
                | IKKE '(' {o("!(");} udtryk {typeCheck($4, T_BOOLSK);}
                  ')' {o(")"); $$ = T_BOOLSK;}
                | SAND {o("true"); $$ = T_BOOLSK;}
                | FALSK {o("false"); $$ = T_BOOLSK;}
                | ID {o("%s", $1); if(!($$ = lookup($1)))
                  yyerror("Variabel %s ikke defineret", yytext);}
                | TAL {o("%s", yytext); $$ = T_HELTAL;}
                | ITERATION { doJavaIteration(); $$ = T_HELTAL; }
                ;
                
%% /* -[ S U P P O R T   R U T I N E R ]------------------------------------ */

int yyerror(const char* c1, const char* c2)
/* Udskriver fejl-meddelelser p† stderr (normalt sk‘rmen)

   Parametre
    const char *c1      : F›rste fejl-meddelelse
    const char *c2      : Anden fejl-meddelelse
*/
{
  fprintf(stderr, "Fejl: linie %d, tegn %d - ", yylineno, yycharno);

  if (c2 == NULL)
    fprintf(stderr, c1);
  else
    fprintf(stderr, c1, c2);

  fprintf(stderr, "\n");

  return(1);
}

void typeCheck(int t1, int t2)
/* Check'er om to typer er ens
   
   Parametre
    int t1      : F›rste type
    int t2      : Anden type
*/
{
  if (t1 != t2)
    yyerror("Typefejl!", "");
}

void o(char *fmt, ...)
/* Inds‘tter genererede Java kode p† nuv‘rende fil-position.

   Parameter
    char *fmt   : Format-streng, fx "int %s = %d"
    ...         : Variabel antal paramtre - bruges i videre kald

*/
{

  // Variabel parameter-lsite
  va_list argptr;
  
  va_start(argptr, fmt);

  // Skriv selve Java-koden til output-filen
  vfprintf(foutput, fmt, argptr);

  va_end(argptr);

}

void fo(char *fmt, ...)
/* Formaterer genererede Java kode.

   Parameter
    char *fmt   : Format-streng, fx "int %s = %d"
    ...         : Variabel antal paramtre - bruges i videre kald

*/
{

  // Variabel parameter-lsite
  va_list argptr;
  
  va_start(argptr, fmt);

  // Inds‘t mellemrum i Java-koden
  doJavaPadding(codeX);

  // Skriv selve Java-koden til output-filen
  vfprintf(foutput, fmt, argptr);

  va_end(argptr);

}

char* getJavaType(int t)
/* Finder og returnerer Java's tilsvarende type.

   Parameter
    int t       : En Svendsk type, defineret som en integer (i symbtab.h)
*/
{

  switch(t)
  {
    case T_HELTAL: return("int"); break;
    case T_BOOLSK: return("boolean"); break;
    case T_STRENG: return("String"); break;
    default: return("");
  }
  
  return("");
  
}

void doJavaPadding(int n)
/* Inds‘tter 'spaces'/mellemrum i Java-koden.

   Parameter
    int n       : Antallet af mellemrum der skal inds‘ttes
    
*/
{
  int i;
  
  for(i=0; i<n; i++)
    fprintf(foutput, " ");
    
}

void doJavaLaes(char *id)
/* Genererer Java for laes.
   
   Parameter
    char *id    : Variablen input'et skal placeres i.
    
   L‘g m‘rke til brugen af det globale objekt SvendskInput. Dette objekt
   bliver oprettet i doJavaMain().
*/
{

  fo("try {\n");
  fo("  %s = SvendskInput.readLine();\n", id);
  fo("}\n");
  fo("catch(java.io.IOException ioe)\n");
  fo("{ %s = \"\"; }\n", id);

}

void doJavaIteration()
/* Genererer Java for det Svendsk-reserverede ord ITERATION.
   Det er kun muligt at bruget ordet i en l›kke, s† det check'es der for i
   denne rutine. L‘g m‘rke til, at kode-genereringen *ikke* stoppes hvis der
   findes en malplaceret ITERATION. Variablen s‘ttes i stedet til -1 og et
   flag s‘ttes. Dette er gjort for at kunne forts‘tte kode-genereringen s†
   langt som muligt.
*/
{

  if(getLastLoopNo() == -1)
  {
    yyerror("ITERATION kan kun kaldes i en l›kke!\n", "");

    /* Koden er IKKE brugbar mere, men kode-genereringen kan forts‘tte videre, 
       og evt. finde flere fejl i samme 'run' */  
    USABLE_CODE = FALSE;
    fprintf(foutput, "-1");
  }
  else
    fprintf(foutput, "loop%d", getLastLoopNo());
    
}

void doJavaVariable(const char *v)
/* Genererer Java for en variabel-erkl‘ring (ex. int i)

  Parametre
   char *v      : En streng med en Svendsk variabel-erkl‘ring
                  fx i.heltal(), s.streng()
   
  Variabel-erkl‘ringen skal dekodes til brug i Java, dvs. f† fat i ID'et og 
  typen.
*/
{

  int i = 0, j = 0;
  char *id;
  char type[] = "**********"; // allokering af plads til typen. Max. 10 tegn

  // Find ID'et
  while(v[i] != '.')
    i++;
  
  id = (char *)strdup(v);

  id[i] = '\0';
  
  // Spring '.' over
  i++;
  
  // Find typen
  while(v[i] != '(')
    type[j++] = v[i++];

  type[j] = '\0';
  
  // Check om typen allerede *er* erkl‘ret
/*  if (lookup(id) != T_UNDEF)
  {
    printf("Variablen %s er allerede erkl‘ret som %s.\n", id, 
     getJavaType(lookup(id)));
     
    exit(-1);
  }
*/

  /* Find typen og generer tilsvarende java-kode. Variablen f†r automatisk
     tildelt en default v‘rdi */
 
  if (strcmp(type, "heltal") == 0)
    fo("int %s = 0;\n", id); 
  else if (strcmp(type, "boolsk") == 0) 
    fo("boolean %s = false;\n", id);
  else if (strcmp(type, "streng") == 0)
    fo("String %s = \"\";\n", id);
  
  // Frig›r hukommelse
  free(id);
  
}

void doJavaLoop(char* t, char* sign)
/* Genererer Java for en l›kke (do..while())

  Parametre
   char* t    : Variablen ID eller et TAL
                Et ID kunne fx v‘re i eller j
                Et TAL kunne fx v‘re 10, 12 eller 14
                
   char* sign : Et plus (+) eller et minus (-).
                Bruges til at finde ud af, om vi skal addere eller subtrahere
                i hvert genneml›b.
*/
{
  int loopNo = getLastLoopNo();
  
  /* Vi skal til at genere Java-koden for et loop. Eftersom det er muligt at
     l›kken skal addere eller subtrahere i hvert genneml›b, skal der checkes
     for et '+' eller et '-' for at finde den tilsvarende Java-syntaks
     (loop++ eller loop--). */
 
  if(strcmp(sign, "+") == 0)
  {
    fo("loop%d++;\n", loopNo);
    codeX -= 2;
    fo("} while(loop%d <= %s);\n", loopNo, t);
  }
  else
  {
    fo("loop%d--;\n", loopNo);
    codeX -= 2;
    fo("} while(loop%d >= %s);\n", loopNo, t);
  }

}

void doJavaMain(char* n)
/* Genererer Java for main()

   Parameter
    char *n     : Navnet p† klassen, fundet i "SVENDSK navn"
   
*/
{
  // Hovedet i et Java program (non AWT)

  fprintf(foutput, "public class %s\n", n);
  fprintf(foutput, "{\n");
  fprintf(foutput, "  public static void main(String[] args)\n");
  fprintf(foutput, "  {\n");
 
  // Her erkl‘res vores globale input-objekt 'SvendskInput'
  fprintf(foutput, "    java.io.BufferedReader SvendskInput;\n");
  fprintf(foutput, "    SvendskInput = new java.io.BufferedReader(new java.io.InputStreamReader(System.in));\n\n");

}

void doJavaFilename(char* f)
/* Tilf›jet .java extention til filnavnet. Man bliver n›d til at kalde filen
   det samme klassen, da Java ellers ikke vil compilere den.
   
   Parameter
    char *f     : Navnet p† klassen, dvs SVENDSK navn
    
*/
{
  gFileName = (char*)malloc(strlen(f)+6);
  strcpy(gFileName, f);
  strcat(gFileName, ".java");
}

 
#ifdef USEYACCMAIN                
int main(int argc, char* argv[])
{
  // Kald til Svendsk.exe: Svendsk <kildefil>

  char* cmdline;

  // Check antallet af parametre (vi skal bruge ‚n)
  if (argc != 2)
  {
    printf("Brug: %s kildefil\n", argv[0]);
    exit(-1);
  }
                  
  // ben fil med Svendsk kode
  if ( (yyin = fopen(argv[1], "rt")) == NULL )
  {
    fprintf(stderr, "Fejl: Filen '%s' kunne ikke †bnes!\n", argv[1] );
    exit(-2);
  }
  
  // Opret fil til output-kode (java)
  if ( (foutput = fopen("temp.tmp", "wt")) == NULL )
  {
    fprintf(stderr, "Fejl: Kunne ikke †bne output-fil\n");
    exit(-1);
  }
                  
  printf("SVENDSK version 1.0 - Maj 1998\n\n");

  printf("> Kompilerer...\n");

  // Nu starter vi med at parse
  yyparse();
  
  // Alt parset (og Java koden *er* genereret)

  // Luk filerne
  fclose(foutput);
  fclose(yyin);

  printf("\n> Opretter \"%s\"\n", gFileName);
  
  /* Slet den fil vi skal til at omd†be vores temp-fil TIL. fx Hello.java.
     Hvis den findes, er det nemlig ikke muligt at rename til den ;) */
  cmdline = (char*)malloc(4+strlen(gFileName)+7+1);
  strcpy(cmdline, "del ");
  strcat(cmdline, gFileName);
  strcat(cmdline, " >& nul");
  system(cmdline);
  free(cmdline);

  /* Omd†b tempor‘re fil (temp.tmp) til rigtige navn, dvs klassens navn +
     endelsen .java */
  cmdline = (char*)malloc(13+strlen(gFileName)+7+1);
  strcpy(cmdline, "ren temp.tmp ");
  strcat(cmdline, gFileName);
  strcat(cmdline, " >& nul");
  system(cmdline);
  free(cmdline);
  
  if(!USABLE_CODE)
    printf("\n> Java-koden er *ikke* brugbar, da der under genereringen opstod fejl!\n");
 
  return(0);
}
#endif
