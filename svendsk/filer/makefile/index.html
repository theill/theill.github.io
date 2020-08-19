# Makefile for Svendsk.exe - en Svendsk->Java Compiler

svendsk.exe : svendsk.obj lexyy.obj symbtab.obj loops.obj
        bcc -esvendsk.exe svendsk.obj lexyy.obj symbtab.obj loops.obj
# -e  Navn paa eksekverbar fil.

svendsk.obj : svendsk.c svendsk.h
##        bcc -c -Ic:\borlandc\classlib\include -Lc:\borlandc\classlib\lib svendsk.c
        bcc -c -w-ccc -w-rch -w-pro -Ic:\borlandc\classlib\include -Lc:\borlandc\classlib\lib svendsk.c
# -c  Compile only.
# -w  Fjern diverse warnings.

svendsk.c : svendsk.y
        c:\flex_bis\bison -v -d -Hc:\flex_bis\bison.h -Sc:\flex_bis\bison.cc -o svendsk.c svendsk.y
# -d  Producer filen svendsk.h med bl.a. #define's svarende til %token's.
# -H  Sti til filen bison.h.
# -S  Sti til filen bison.cc.
# -o  Navn paa output.

lexyy.obj : lexyy.c svendsk.h
##        bcc  -c lexyy.c
        bcc  -c -w-ccc -w-rch -w-pro lexyy.c
# -c  Compile only - don't link.

symbtab.obj : symbtab.c symbtab.h
        bcc -c symbtab.c
        
loops.obj : loops.c loops.h
        bcc -c loops.c

lexyy.c : svendsk.l
        c:\flex_bis\flex -8 -Hc:\flex_bis\flexskel.h -Sc:\flex_bis\flexskel.cc svendsk.l
# -I  Interactive
# -i  Ignore case.
# -8  8 bit tegn: , ,  osv
# -H  Sti til filen flexskel.h.
# -S  Sti til filen flexskel.cc
# -o  Navn paa output

clean:
        del *.obj
        del lexyy.c
        del svendsk.c
        del svendsk.h
        del svendsk.out
        del svendsk.exe
        del symbtab.exe
        del svendsk.bak
        del symbtab.bak
