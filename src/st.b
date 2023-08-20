

//    MASTER
SECTION "MASTER"


GET "SYNHDR"

LET START(PARM) BE
$(1
LET SYSI, SYSO = INPUT(), OUTPUT()
SYSPRINT := FINDOUTPUT("/dev/stderr")
SELECTOUTPUT(SYSPRINT)

WRITEF("*NBCPL %N*N", @START)

$( LET OPT = VEC 20
   AND TREESIZE = 55000
   OPTION := OPT
   SAVESPACESIZE := 2
   LEXTRACE := FALSE
   PRSOURCE := FALSE
   LINECOUNT, PRLINE:=1,0
   FOR I = 0 TO 20 DO OPT!I := FALSE

SOURCESTREAM := FINDINPUT("OPT")    // ## OPTION/LN:OPT

UNLESS FINDFAIL(SOURCESTREAM) DO
$(P LET CH = 0
    AND N = 0
    SELECTINPUT(SOURCESTREAM)
    WRITES("OPTIONS  ")

    $( CH := RDCH()
    L: IF CH='*N' \/ CH=ENDSTREAMCH BREAK
       WRCH(CH)
       IF CH='P' DO N := 1
       IF CH='T' DO N := 2
       IF CH='C' DO N := 3
       IF CH='M' DO N := 4
       IF CH='N' DO N := 5
       IF CH='S' DO PRSOURCE := TRUE
       IF CH='E' DO LEXTRACE := TRUE
       IF CH='L' DO  $( TREESIZE := READN()
                        WRITEN(TREESIZE)
                     $)
       IF CH='3' DO SAVESPACESIZE := 3
       OPTION!N := TRUE
                 $) REPEAT

    NEWLINE()
    ENDREAD()  $)P

   TRANSCHARS := NOT OPTION!3
   REPORTMAX := 20
   REPORTCOUNT := 0



SOURCESTREAM := SYSI
SELECTINPUT(SOURCESTREAM)

OCODE := SYSO
IF FINDFAIL(OCODE) DO OCODE := SYSPRINT

$(2 LET COMP(V, TREEMAX) BE
    $(C LET B = VEC 63
        CHBUF := B

      $(3 TREEP, TREEVEC := V+TREEMAX, V
          TEST PRSOURCE THEN
            $( SYSLIST:=FINDOUTPUT("LIST")    // ## LIST/LN:LIST
               IF FINDFAIL(SYSLIST) DO SYSLIST:=SYSPRINT
             $) ELSE SYSLIST:=SYSPRINT

        $( LET A = FORMTREE()
           IF A=0 BREAK

           WRITEF("*NTREE SIZE %N*N", TREEMAX+TREEVEC-TREEP)

           IF OPTION!2 DO $( WRITES("AE TREE*N")
                             PLIST(A, 0, 20)
                             NEWLINE()  $)


           UNLESS REPORTCOUNT=0 DO STOP(8)

           UNLESS OPTION!3 DO
                  $( SELECTOUTPUT(OCODE)
                     COMPILEAE(A)
                     SELECTOUTPUT(SYSPRINT)  $)

      $)3 REPEAT
    $)C

   APTOVEC(COMP, TREESIZE)


   ENDREAD()
   WRITES("*NPHASE 1 COMPLETE*N")
   UNLESS REPORTCOUNT=0 DO STOP(8)
   FINISH   $)1

.
//    LEX1
SECTION "LEX1"

GET "SYNHDR"

LET NEXTSYMB() BE
$(1 NLPENDING := FALSE

$(2 IF LEXTRACE DO WRCH(CH)

    SWITCHON CH INTO

$(S CASE '*P':
    CASE '*N': LINECOUNT := LINECOUNT + 1
               NLPENDING := TRUE  // IGNORABLE CHARACTERS
    CASE '*T':
    CASE '*S': RCH() REPEATWHILE CH='*S'
               LOOP

    CASE '0':CASE '1':CASE '2':CASE '3':CASE '4':
    CASE '5':CASE '6':CASE '7':CASE '8':CASE '9':
         SYMB := S.NUMBER
         READNUMBER(10)
         RETURN

    CASE 'a':CASE 'b':CASE 'c':CASE 'd':CASE 'e':
    CASE 'f':CASE 'g':CASE 'h':CASE 'i':CASE 'j':
    CASE 'k':CASE 'l':CASE 'm':CASE 'n':CASE 'o':
    CASE 'p':CASE 'q':CASE 'r':CASE 's':CASE 't':
    CASE 'u':CASE 'v':CASE 'w':CASE 'x':CASE 'y':
    CASE 'z':
    CASE 'A':CASE 'B':CASE 'C':CASE 'D':CASE 'E':
    CASE 'F':CASE 'G':CASE 'H':CASE 'I':CASE 'J':
    CASE 'K':CASE 'L':CASE 'M':CASE 'N':CASE 'O':
    CASE 'P':CASE 'Q':CASE 'R':CASE 'S':CASE 'T':
    CASE 'U':CASE 'V':CASE 'W':CASE 'X':CASE 'Y':
    CASE 'Z':
         RDTAG(CH)
         SYMB := LOOKUPWORD()
         IF SYMB=S.GET DO $( PERFORMGET(); LOOP  $)
         RETURN

    CASE '$': RCH()
              UNLESS CH='(' | CH=')' DO SYNREPORT(91)
              SYMB := CH='(' -> S.LSECT, S.RSECT
              RDTAG('$')
              LOOKUPWORD()
              RETURN

    CASE '[':
    CASE '(': SYMB := S.LPAREN; BREAK
    CASE ']':
    CASE ')': SYMB := S.RPAREN; BREAK

    CASE '#':
         SYMB := S.NUMBER
         RCH()
         CH := CAPITALCH(CH)
         IF '0'<=CH<='7' DO  $( READNUMBER(8);  RETURN  $)
         IF CH='B' DO $( RCH(); READNUMBER(2);  RETURN  $)
         IF CH='O' DO $( RCH(); READNUMBER(8);  RETURN  $)
         IF CH='X' DO $( RCH(); READNUMBER(16); RETURN  $)
         SYNREPORT(33)

    CASE '?': SYMB := S.QUERY;     BREAK
    CASE '+': SYMB := S.PLUS;      BREAK
    CASE ',': SYMB := S.COMMA;     BREAK
    CASE ';': SYMB := S.SEMICOLON; BREAK
    CASE '@': SYMB := S.LV;        BREAK
    CASE '&': SYMB := S.LOGAND;    BREAK
    CASE '|': SYMB := S.LOGOR;     BREAK
    CASE '=': SYMB := S.EQ;        BREAK
    CASE '!': SYMB := S.VECAP;     BREAK
    CASE '%': SYMB := S.BYTEAP;    BREAK
    CASE '**':SYMB := S.MULT;      BREAK

    CASE '/':
         RCH()
         IF CH='\' DO $( SYMB := S.LOGAND; BREAK $)
         IF CH='/' DO
            $( RCH() REPEATUNTIL CH='*N' | CH=ENDSTREAMCH
               LOOP  $)

         UNLESS CH='**' DO $( SYMB := S.DIV; RETURN  $)

         $( RCH()
            IF CH='**' DO
               $( RCH() REPEATWHILE CH='**'
                  IF CH='/' BREAK  $)
            IF CH='*N' DO LINECOUNT := LINECOUNT+1
            IF CH=ENDSTREAMCH DO SYNREPORT(63)
         $) REPEAT

         RCH()
         LOOP


    CASE '~': RCH()
              IF CH='=' DO $( SYMB := S.NE;     BREAK $)
              SYMB := S.NOT
              RETURN

    CASE '\': RCH()
              IF CH='/' DO $( SYMB := S.LOGOR;  BREAK $)
              IF CH='=' DO $( SYMB := S.NE;     BREAK $)
              SYMB := S.NOT
              RETURN

    CASE '<': RCH()
              IF CH='=' DO $( SYMB := S.LE;     BREAK $)
              IF CH='<' DO $( SYMB := S.LSHIFT; BREAK $)
              SYMB := S.LS
              RETURN

    CASE '>': RCH()
              IF CH='=' DO $( SYMB := S.GE;     BREAK $)
              IF CH='>' DO $( SYMB := S.RSHIFT; BREAK $)
              SYMB := S.GR
              RETURN

    CASE '-': RCH()
              IF CH='>' DO $( SYMB := S.COND; BREAK  $)
              SYMB := S.MINUS
              RETURN

    CASE ':': RCH()
              IF CH='=' DO $( SYMB := S.ASS; BREAK  $)
              SYMB := S.COLON
              RETURN


    CASE '"': CHARP := 0
              RCH()

              UNTIL CH='"' DO
                  $( IF CHARP=255 DO SYNREPORT(34)
                     CHARP := CHARP + 1
                     CHARV!CHARP := RDSTRCH()  $)

              CHARV!0 := CHARP
              WORDSIZE := PACKSTRING(CHARV, WORDV)
              SYMB := S.STRING
              BREAK

    CASE '*'':RCH()
              DECVAL := RDSTRCH()
              SYMB := S.NUMBER
              UNLESS CH='*'' DO SYNREPORT(34)
              BREAK


    DEFAULT:  UNLESS CH=ENDSTREAMCH DO $( CH := '*S'
                                          SYNREPORT(94)  $)
    CASE '.': IF GETP=0 DO $( SYMB := S.END
                              RETURN   $)
              ENDREAD()
              GETP := GETP - 3
              SOURCESTREAM := GETV!GETP
              SELECTINPUT(SOURCESTREAM)
              LINECOUNT := GETV!(GETP+1)
              CH := GETV!(GETP+2)
              LOOP
$)S

$)2 REPEAT

    RCH()
$)1

.
//    LEX2
SECTION "LEX2"

GET "SYNHDR"

LET LOOKUPWORD() = VALOF
$(1 LET HASHVAL =
            (WORDV!0+WORDV!WORDSIZE >> 1) REM NAMETABLESIZE

    LET I = 0

    WORDNODE := NAMETABLE!HASHVAL

    UNTIL WORDNODE=0 | I>WORDSIZE DO
          TEST WORDNODE!(I+2)=WORDV!I
            THEN I := I+1
            ELSE WORDNODE, I := H2!WORDNODE, 0

    IF WORDNODE=0 DO
      $( WORDNODE := NEWVEC(WORDSIZE+2)
         WORDNODE!0, WORDNODE!1 := S.NAME, NAMETABLE!HASHVAL
         FOR I = 0 TO WORDSIZE DO WORDNODE!(I+2) := WORDV!I
         NAMETABLE!HASHVAL := WORDNODE  $)

    RESULTIS H1!WORDNODE  $)1


AND DECLSYSWORDS() BE
$(1 CODEP := TABLE
      S.AND,S.ABS,
      S.BE,S.BREAK,S.BY,
      S.CASE,
      S.DO,S.DEFAULT,
      S.EQ,S.EQV,S.OR,S.ENDCASE,
      S.FALSE,S.FOR,S.FINISH,
      S.GOTO,S.GE,S.GR,S.GLOBAL,S.GET,
      S.IF,S.INTO,
      S.LET,S.LV,S.LE,S.LS,S.LOGOR,S.LOGAND,S.LOOP,S.LSHIFT,
      S.MANIFEST,
      S.NE,S.NOT,S.NEQV,S.NEEDS,
      S.OR,
      S.RESULTIS,S.RETURN,S.REM,S.RSHIFT,S.RV,
      S.REPEAT,S.REPEATWHILE,S.REPEATUNTIL,
      S.SWITCHON,S.STATIC,S.SECTION,
      S.TO,S.TEST,S.TRUE,S.DO,S.TABLE,
      S.UNTIL,S.UNLESS,
      S.VEC,S.VALOF,
      S.WHILE,
      0

    D("AND/ABS/*
      *BE/BREAK/BY/*
      *CASE/*
      *DO/DEFAULT/*
      *EQ/EQV/ELSE/ENDCASE/*
      *FALSE/FOR/FINISH/*
      *GOTO/GE/GR/GLOBAL/GET/*
      *IF/INTO/*
      *LET/LV/LE/LS/LOGOR/LOGAND/LOOP/LSHIFT//")

    D("MANIFEST/*
      *NE/NOT/NEQV/NEEDS/*
      *OR/*
      *RESULTIS/RETURN/REM/RSHIFT/RV/*
      *REPEAT/REPEATWHILE/REPEATUNTIL/*
      *SWITCHON/STATIC/SECTION/*
      *TO/TEST/TRUE/THEN/TABLE/*
      *UNTIL/UNLESS/*
      *VEC/VALOF/*
      *WHILE/*
      *$//")

     NULLTAG := WORDNODE  $)1


AND D(WORDS) BE
$(1 LET I, LENGTH = 1, 0

    $( LET CH = GETBYTE(WORDS, I)
       TEST CH='/'
           THEN $( IF LENGTH=0 RETURN
                   CHARV!0 := LENGTH
                   WORDSIZE := PACKSTRING(CHARV, WORDV)
                   LOOKUPWORD()
                   H1!WORDNODE := !CODEP
                   CODEP := CODEP + 1
                   LENGTH := 0  $)
           ELSE $( LENGTH := LENGTH + 1
                   CHARV!LENGTH := CH  $)
       I := I + 1
    $) REPEAT
$)1



.
//    LEX3
SECTION "LEX3"

GET "SYNHDR"

LET RCH() BE
    $( CH := RDCH()

       IF PRSOURCE & GETP=0 & CH NE ENDSTREAMCH DO
          $( SELECTOUTPUT(SYSLIST)
             UNLESS LINECOUNT=PRLINE DO
                           $( WRITEF("%I4  ", LINECOUNT)
                              PRLINE := LINECOUNT  $)
             WRCH(CH); SELECTOUTPUT(SYSPRINT)  $)

       CHCOUNT := CHCOUNT + 1
       CHBUF!(CHCOUNT&63) := CH  $)

AND WRCHBUF() BE
    $( WRITES("*N...")
       FOR P = CHCOUNT-63 TO CHCOUNT DO
                $( LET K = CHBUF!(P&63)
                   UNLESS K=0 DO WRCH(K)  $)
       NEWLINE()  $)


AND RDTAG(CHAR1) BE
    $( CHARP := 1
       CHARV!1 := CAPITALCH(CHAR1)

       $( RCH()
          CH := CAPITALCH(CH)
          UNLESS 'A'<=CH<='Z' |
                 '0'<=CH<='9' |
                  CH='.' | CH='_' BREAK
          CHARP := CHARP+1
          CHARV!CHARP := CH  $) REPEAT

       CHARV!0 := CHARP
       WORDSIZE := PACKSTRING(CHARV, WORDV)  $)


AND PERFORMGET() BE
    $( TRANSCHARS := FALSE
       NEXTSYMB()
       TRANSCHARS := NOT OPTION!3
       UNLESS SYMB=S.STRING THEN SYNREPORT(97)

       GETV!GETP := SOURCESTREAM
       GETV!(GETP+1) := LINECOUNT
       GETV!(GETP+2) := CH
       GETP := GETP + 3
       LINECOUNT := 1
       SOURCESTREAM := FINDINPUT(WORDV)
       IF FINDFAIL(SOURCESTREAM) THEN
          $( LET PATH = VEC 63
             AND DIR = "/usr/local/lib/obcpl/"
             AND APPEND(D, S) BE
              $( LET ND = D%0
                FOR I = 1 TO S%0 DO $(
                   ND := ND + 1
                   D%ND := S%I $)
                   D%0 := ND $)
             IF DIR%0 + WORDV%0 <= 255 $(
                PATH%0 := 0
                APPEND(PATH, DIR)
                APPEND(PATH, WORDV)
                SOURCESTREAM:=FINDINPUT(PATH) $)
           $)
       TEST FINDFAIL(SOURCESTREAM) THEN // Unstack GET info.
           $( GETP:=GETP-3
              SOURCESTREAM:=GETV!(GETP)
              LINECOUNT:=GETV!(GETP+1)
              SYNREPORT(96,WORDV) // Generate error.
           $) ELSE
           $( SELECTINPUT(SOURCESTREAM)
              RCH()
           $)
     $)



AND FINDFAIL(STREAM) = STREAM = 0

AND READNUMBER(RADIX) BE
    $( LET D = VALUE(CH)
       DECVAL := D
       IF D>=RADIX DO SYNREPORT(33)

       $( RCH()
          D := VALUE(CH)
          IF D>=RADIX RETURN
          DECVAL := RADIX*DECVAL + D  $) REPEAT
    $)


AND VALUE(CH) = '0'<=CH<='9' -> CH-'0',
                'A'<=CH<='F' -> CH-'A'+10,
                'a'<=CH<='f' -> CH-'a'+10,
                100

AND RDSTRCH() = VALOF
    $(
    GETCH:
      $( LET K = CH

         RCH()

         IF K='*N' DO SYNREPORT(34)

         TEST K='**' THEN
             $( IF CH='*N' | CH='*S' | CH='*T' DO
                $(
                   $( IF CH='*N' DO LINECOUNT := LINECOUNT+1
                      RCH()
                   $) REPEATWHILE CH='*N' | CH='*S' | CH='*T'
                   UNLESS CH='**' DO SYNREPORT(34)
                   RCH()
                   GOTO GETCH
                $)

                K := CH
                CH := CAPITALCH(CH)
                IF CH='T' DO K := '*T'
                IF CH='S' DO K := '*S'
                IF CH='N' DO K := '*N'
                IF CH='E' DO K := '*E'
                IF CH='B' DO K := '*B'
                IF CH='P' DO K := '*P'
                IF CH='C' DO K := '*C'
                IF CH='X' DO K:=READOCTALORHEX(16,2)
                IF '0' <= CH <= '9' DO
                  $( K:=VALUE(CH)*64+READOCTALORHEX(8,2)
                     IF K>255 DO SYNREPORT(34)
                  $)
                RCH()
             $) ELSE
             IF CH='*N' THEN LINECOUNT:=LINECOUNT+1

         RESULTIS K
      $)
    $)


AND READOCTALORHEX(RADIX,DIGITS) = VALOF
    $( LET ANSWER = 0
       FOR J = 1 TO DIGITS DO
          $( LET VALCH = VALUE(VALOF $( RCH(); RESULTIS CH $) )
             IF VALCH > RADIX DO SYNREPORT(34)
             ANSWER:=ANSWER*RADIX + VALCH
          $)
       RESULTIS ANSWER
    $)
.
//    SYN0
SECTION "SYN0"

GET "SYNHDR"

LET NEWVEC(N) = VALOF
    $( TREEP := TREEP - N - 1;
       IF TREEP<=TREEVEC DO
                $( REPORTMAX := 0
                   SYNREPORT(98)  $)
       RESULTIS TREEP  $)

AND LIST1(X) = VALOF
    $( LET P = NEWVEC(0)
       P!0 := X
       RESULTIS P  $)

AND LIST2(X, Y) = VALOF
    $( LET P = NEWVEC(1)
       P!0, P!1 := X, Y
       RESULTIS P   $)

AND LIST3(X, Y, Z) = VALOF
    $( LET P = NEWVEC(2)
       P!0, P!1, P!2 := X, Y, Z
       RESULTIS P     $)

AND LIST4(X, Y, Z, T) = VALOF
    $( LET P = NEWVEC(3)
       P!0, P!1, P!2, P!3 := X, Y, Z, T
       RESULTIS P   $)

AND LIST5(X, Y, Z, T, U) = VALOF
    $( LET P = NEWVEC(4)
       P!0, P!1, P!2, P!3, P!4 := X, Y, Z, T, U
       RESULTIS P   $)

AND LIST6(X, Y, Z, T, U, V) = VALOF
    $( LET P = NEWVEC(5)
       P!0, P!1, P!2, P!3, P!4, P!5 := X, Y, Z, T, U, V
       RESULTIS P  $)

AND FORMTREE() =  VALOF
$(1 LET V = VEC 63
    CHBUF := V
    FOR I = 0 TO 63 DO CHBUF!I := 0
    CHCOUNT := 0

 $( LET V = VEC 20   // FOR 'GET' STREAMS
    GETV, GETP, GETT := V, 0, 20

    RCH()
    IF CH=ENDSTREAMCH RESULTIS 0

 $( LET V = VEC 128
    WORDV := V

 $( LET V = VEC 256
    CHARV, CHARP := V, 0

 $( LET V = VEC NAMETABLESIZE
    NAMETABLE := V
    FOR I = 0 TO NAMETABLESIZE DO NAMETABLE!I := 0
    DECLSYSWORDS()

    REC.P, REC.L := LEVEL(), L

 L: NEXTSYMB()

    IF OPTION!1 DO   //   LEX DEBUGGING OPTION
         $( WRITEF("%I3 %S*N", SYMB, WORDV)
            IF SYMB=S.END RESULTIS 0
            GOTO L  $)

 $( LET RPROG(THING) = VALOF
    $( LET A = 0
       NEXTSYMB(); A:=RBEXP()
       UNLESS H1!A=S.STRING THEN SYNREPORT(95)
       RESULTIS LIST3(THING, A,
          SYMB = S.NEEDS -> RPROG(S.NEEDS),RDBLOCKBODY())
    $)
 $( LET A = SYMB=S.SECTION -> RPROG(S.SECTION),
            SYMB=S.NEEDS   -> RPROG(S.NEEDS),RDBLOCKBODY()
    UNLESS SYMB=S.END DO SYNREPORT(99)

    RESULTIS A        $)1



AND SYNREPORT(N, A) BE
     $( REPORTCOUNT := REPORTCOUNT + 1
        WRITEF("*NSYNTAX ERROR NEAR LINE %N:  ", LINECOUNT)
        SYNMESSAGE(N, A)
        WRCHBUF()
        IF REPORTCOUNT GR REPORTMAX DO
                    $( WRITES("*NCOMPILATION ABORTED*N")
                       STOP(8)   $)
        NLPENDING := FALSE

        UNTIL SYMB=S.LSECT | SYMB=S.RSECT |
              SYMB=S.LET | SYMB=S.AND |
              SYMB=S.END | NLPENDING DO NEXTSYMB()
        LONGJUMP(REC.P, REC.L)   $)

AND SYNMESSAGE(N, A) BE
$( LET S = VALOF SWITCHON N INTO
     $( DEFAULT:  A := N; RESULTIS "ERROR %N"

        CASE 91: RESULTIS "'$' OUT OF CONTEXT"
        CASE 94: RESULTIS "ILLEGAL CHARACTER"
        CASE 95: RESULTIS "BAD SECTION NAME"
        CASE 96: RESULTIS "NO INPUT %S"
        CASE 97: RESULTIS "BAD GET DIRECTIVE"
        CASE 98: RESULTIS "PROGRAM TOO LARGE"
        CASE 99: RESULTIS "INCORRECT TERMINATION"

        CASE 8:CASE 40:CASE 43:
                 RESULTIS "NAME EXPECTED"
        CASE 6:  RESULTIS "'$(' EXPECTED"
        CASE 7:  RESULTIS "'$)' EXPECTED"
        CASE 9:  RESULTIS "UNTAGGED '$)' MISMATCH"
        CASE 32: RESULTIS "ERROR IN EXPRESSION"
        CASE 33: RESULTIS "BAD NUMBER"
        CASE 34: RESULTIS "BAD STRING OR CHARACTER CONSTANT"
        CASE 15:CASE 19:CASE 41: RESULTIS "')' MISSING"
        CASE 30: RESULTIS "BAD CONDITIONAL EXPRESSION"
        CASE 42: RESULTIS "BAD PROCEDURE HEADING"
        CASE 44:
        CASE 45: RESULTIS "BAD DECLARATION"
        CASE 50: RESULTIS "UNEXPECTED ':'"
        CASE 51: RESULTIS "ERROR IN COMMAND"
        CASE 54: RESULTIS "'ELSE' EXPECTED"
        CASE 57:
        CASE 58: RESULTIS "BAD FOR LOOP"
        CASE 60: RESULTIS "'INTO' EXPECTED"
        CASE 61:CASE 62: RESULTIS "':' EXPECTED"
        CASE 63: RESULTIS "'**/' MISSING"
      $)

    WRITEF(S, A)  $)


.
//    SYN1
SECTION "SYN1"

GET "SYNHDR"

LET RDBLOCKBODY() = VALOF
$(1 LET P, L = REC.P, REC.L
    LET A = 0

    REC.P, REC.L := LEVEL(), RECOVER

    IGNORE(S.SEMICOLON)

    SWITCHON SYMB INTO
    $(S CASE S.MANIFEST:
        CASE S.STATIC:
        CASE S.GLOBAL:
            $(  LET OP = SYMB
                NEXTSYMB()
                A := RDSECT(RDCDEFS)
                A := LIST3(OP, A, RDBLOCKBODY())
                ENDCASE  $)


        CASE S.LET: NEXTSYMB()
                    A := RDEF()
           RECOVER: WHILE SYMB=S.AND DO
                       $( NEXTSYMB()
                          A := LIST3(S.AND, A, RDEF())  $)
                    A := LIST3(S.LET, A, RDBLOCKBODY())
                    ENDCASE

        DEFAULT: A := RDSEQ()

                 UNLESS SYMB=S.RSECT | SYMB=S.END DO
                          SYNREPORT(51)

        CASE S.RSECT: CASE S.END:
    $)S

    REC.P, REC.L := P, L
    RESULTIS A   $)1

AND RDSEQ() = VALOF
    $( LET A = 0
       IGNORE(S.SEMICOLON)
       A := RCOM()
       IF SYMB=S.RSECT | SYMB=S.END RESULTIS A
       RESULTIS LIST3(S.SEQ, A, RDSEQ())   $)


AND RDCDEFS() = VALOF
    $(1 LET A, B = 0, 0
        LET PTR = @A
        LET P, L = REC.P, REC.L
        REC.P, REC.L := LEVEL(), RECOVER

        $( B := RNAME()
           TEST SYMB=S.EQ | SYMB=S.COLON THEN NEXTSYMB()
                                         ELSE SYNREPORT(45)
           !PTR := LIST4(S.CONSTDEF, 0, B, REXP(0))
           PTR := @H2!(!PTR)
  RECOVER: IGNORE(S.SEMICOLON) $) REPEATWHILE SYMB=S.NAME

        REC.P, REC.L := P, L
        RESULTIS A  $)1

AND RDSECT(R) = VALOF
    $(  LET TAG, A = WORDNODE, 0
        CHECKFOR(S.LSECT, 6)
        A := R()
        UNLESS SYMB=S.RSECT DO SYNREPORT(7)
        TEST TAG=WORDNODE
             THEN NEXTSYMB()
             ELSE IF WORDNODE=NULLTAG DO
                      $( SYMB := 0
                         SYNREPORT(9)  $)
        RESULTIS A   $)


AND RNAMELIST() = VALOF
    $(  LET A = RNAME()
        UNLESS SYMB=S.COMMA RESULTIS A
        NEXTSYMB()
        RESULTIS LIST3(S.COMMA, A, RNAMELIST())   $)


AND RNAME() = VALOF
    $( LET A = WORDNODE
       CHECKFOR(S.NAME, 8)
       RESULTIS A  $)

AND IGNORE(ITEM) BE IF SYMB=ITEM DO NEXTSYMB()

AND CHECKFOR(ITEM, N) BE
      $( UNLESS SYMB=ITEM DO SYNREPORT(N)
         NEXTSYMB()  $)

.
//    SYN2
SECTION "SYN2"

GET "SYNHDR"

LET RBEXP() = VALOF
$(1 LET A, OP = 0, SYMB

    SWITCHON SYMB INTO

 $( DEFAULT: SYNREPORT(32)

    CASE S.QUERY:
        NEXTSYMB()
        RESULTIS LIST1(S.QUERY)

    CASE S.TRUE:
    CASE S.FALSE:
    CASE S.NAME:
        A := WORDNODE
        NEXTSYMB()
        RESULTIS A

    CASE S.STRING:
        A := NEWVEC(WORDSIZE+1)
        A!0 := S.STRING
        FOR I = 0 TO WORDSIZE DO A!(I+1) := WORDV!I
        NEXTSYMB()
        RESULTIS A

    CASE S.NUMBER:
        A := LIST2(S.NUMBER, DECVAL)
        NEXTSYMB()
        RESULTIS A

    CASE S.LPAREN:
        NEXTSYMB()
        A := REXP(0)
        CHECKFOR(S.RPAREN, 15)
        RESULTIS A

    CASE S.VALOF:
        NEXTSYMB()
        RESULTIS LIST2(S.VALOF, RCOM())

    CASE S.VECAP: OP := S.RV
    CASE S.LV:
    CASE S.RV: NEXTSYMB(); RESULTIS LIST2(OP, REXP(37))

    CASE S.PLUS: NEXTSYMB(); RESULTIS REXP(34)

    CASE S.MINUS: NEXTSYMB()
                  A := REXP(34)
                  TEST H1!A=S.NUMBER
                      THEN H2!A := - H2!A
                      ELSE A := LIST2(S.NEG, A)
                  RESULTIS A

    CASE S.NOT: NEXTSYMB(); RESULTIS LIST2(S.NOT, REXP(24))

    CASE S.ABS: NEXTSYMB(); RESULTIS LIST2(S.ABS, REXP(35))

    CASE S.TABLE: NEXTSYMB()
                  RESULTIS LIST2(S.TABLE, REXPLIST())   $)1



AND REXP(N) = VALOF
$(1 LET A = RBEXP()

    LET B, C, P, Q = 0, 0, 0, 0

$(2 LET OP = SYMB

    IF NLPENDING RESULTIS A

    SWITCHON OP INTO

$(S DEFAULT: RESULTIS A

    CASE S.LPAREN: NEXTSYMB()
                   B := 0
                   UNLESS SYMB=S.RPAREN DO B := REXPLIST()
                   CHECKFOR(S.RPAREN, 19)
                   A := LIST3(S.FNAP, A, B)
                   LOOP

    CASE S.BYTEAP:P:=36;  GOTO LASSOC
    CASE S.VECAP: P := 40; GOTO LASSOC

    CASE S.REM:CASE S.MULT:CASE S.DIV: P := 35; GOTO LASSOC

    CASE S.PLUS:CASE S.MINUS: P := 34; GOTO LASSOC

    CASE S.EQ:CASE S.NE:
    CASE S.LE:CASE S.GE:
    CASE S.LS:CASE S.GR:
        IF N>=30 RESULTIS A

        $(R NEXTSYMB()
            B := REXP(30)
            A := LIST3(OP, A, B)
            TEST C=0 THEN C :=  A
                     ELSE C := LIST3(S.LOGAND, C, A)
            A, OP := B, SYMB
        $)R REPEATWHILE S.EQ<=OP<=S.GE

        A := C
        LOOP

    CASE S.LSHIFT:CASE S.RSHIFT: P, Q := 25, 30; GOTO DYADIC

    CASE S.LOGAND: P := 23; GOTO LASSOC

    CASE S.LOGOR:  P := 22; GOTO LASSOC

    CASE S.EQV:CASE S.NEQV: P := 21; GOTO LASSOC

    CASE S.COND:
            IF N>=13 RESULTIS A
            NEXTSYMB()
            B := REXP(0)
            CHECKFOR(S.COMMA, 30)
            A := LIST4(S.COND, A, B, REXP(0))
            LOOP

    LASSOC: Q := P

    DYADIC: IF N>=P RESULTIS A
            NEXTSYMB()
            A := LIST3(OP, A, REXP(Q))
            LOOP
$)S
$)2 REPEAT
$)1

LET REXPLIST() = VALOF
    $(1 LET A = 0
        LET PTR = @A

        $( LET B = REXP(0)
           UNLESS SYMB=S.COMMA DO $( !PTR := B
                                     RESULTIS A  $)
           NEXTSYMB()
           !PTR := LIST3(S.COMMA, B, 0)
           PTR := @H3!(!PTR)  $) REPEAT
    $)1

LET RDEF() = VALOF
$(1 LET N = RNAMELIST()

    SWITCHON SYMB INTO

 $( CASE S.LPAREN:
      $( LET A = 0
         NEXTSYMB()
         UNLESS H1!N=S.NAME DO SYNREPORT(40)
         IF SYMB=S.NAME DO A := RNAMELIST()
         CHECKFOR(S.RPAREN, 41)

         IF SYMB=S.BE DO
            $( NEXTSYMB()
               RESULTIS LIST5(S.RTDEF, N, A, RCOM(), 0)  $)

         IF SYMB=S.EQ DO
            $( NEXTSYMB()
               RESULTIS LIST5(S.FNDEF, N, A, REXP(0), 0)  $)

         SYNREPORT(42)  $)

    DEFAULT: SYNREPORT(44)

    CASE S.EQ:
         NEXTSYMB()
         IF SYMB=S.VEC DO
              $( NEXTSYMB()
                 UNLESS H1!N=S.NAME DO SYNREPORT(43)
                 RESULTIS LIST3(S.VECDEF, N, REXP(0))  $)
         RESULTIS LIST3(S.VALDEF, N, REXPLIST())  $)1

.
//    SYN4
SECTION "SYN4"

GET "SYNHDR"

LET RBCOM() = VALOF
$(1 LET A, B, OP = 0, 0, SYMB

    SWITCHON SYMB INTO
 $( DEFAULT: RESULTIS 0

    CASE S.NAME:CASE S.NUMBER:CASE S.STRING:
    CASE S.TRUE:CASE S.FALSE:
    CASE S.LV:CASE S.RV:CASE S.VECAP:
    CASE S.LPAREN:
            A := REXPLIST()

            IF SYMB=S.ASS  THEN
               $( OP := SYMB
                  NEXTSYMB()
                  RESULTIS LIST3(OP, A, REXPLIST())  $)

            IF SYMB=S.COLON DO
               $( UNLESS H1!A=S.NAME DO SYNREPORT(50)
                  NEXTSYMB()
                  RESULTIS LIST4(S.COLON, A, RBCOM(), 0)  $)

            IF H1!A=S.FNAP DO
                 $( H1!A := S.RTAP
                    RESULTIS A  $)

            SYNREPORT(51)
            RESULTIS A

    CASE S.GOTO:CASE S.RESULTIS:
            NEXTSYMB()
            RESULTIS LIST2(OP, REXP(0))

    CASE S.IF:CASE S.UNLESS:
    CASE S.WHILE:CASE S.UNTIL:
            NEXTSYMB()
            A := REXP(0)
            IGNORE(S.DO)
            RESULTIS LIST3(OP, A, RCOM())

    CASE S.TEST:
            NEXTSYMB()
            A := REXP(0)
            IGNORE(S.DO)
            B := RCOM()
            CHECKFOR(S.OR, 54)
            RESULTIS LIST4(S.TEST, A, B, RCOM())

    CASE S.FOR:
        $(  LET I, J, K = 0, 0, 0
            NEXTSYMB()
            A := RNAME()
            CHECKFOR(S.EQ,57)
            I := REXP(0)
            CHECKFOR(S.TO, 58)
            J := REXP(0)
            IF SYMB=S.BY DO $( NEXTSYMB()
                               K := REXP(0)  $)
            IGNORE(S.DO)
            RESULTIS LIST6(S.FOR, A, I, J, K, RCOM())  $)

    CASE S.LOOP:
    CASE S.BREAK:CASE S.RETURN:CASE S.FINISH:CASE S.ENDCASE:
            A := WORDNODE
            NEXTSYMB()
            RESULTIS A

    CASE S.SWITCHON:
            NEXTSYMB()
            A := REXP(0)
            CHECKFOR(S.INTO, 60)
            RESULTIS LIST3(S.SWITCHON, A, RDSECT(RDSEQ))

    CASE S.CASE:
            NEXTSYMB()
            A := REXP(0)
            CHECKFOR(S.COLON, 61)
            RESULTIS LIST3(S.CASE, A, RBCOM())

    CASE S.DEFAULT:
            NEXTSYMB()
            CHECKFOR(S.COLON, 62)
            RESULTIS LIST2(S.DEFAULT, RBCOM())

    CASE S.LSECT:
            RESULTIS RDSECT(RDBLOCKBODY)   $)1


AND RCOM() = VALOF
$(1 LET A = RBCOM()

    IF A=0 DO SYNREPORT(51)

    WHILE SYMB=S.REPEAT | SYMB=S.REPEATWHILE |
                          SYMB=S.REPEATUNTIL DO
          $( LET OP = SYMB
             NEXTSYMB()
             TEST OP=S.REPEAT
                 THEN A := LIST2(OP, A)
                 ELSE A := LIST3(OP, A, REXP(0))   $)

    RESULTIS A  $)1


.

//    PLIST
SECTION "PLIST"


GET "SYNHDR"

LET PLIST(X, N, D) BE
    $(1 LET SIZE = 0
        LET V = TABLE 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0

        IF X=0 DO $( WRITES("NIL"); RETURN  $)

        SWITCHON H1!X INTO
    $(  CASE S.NUMBER: WRITEN(H2!X); RETURN

        CASE S.NAME: WRITES(X+2); RETURN

        CASE S.STRING: WRITEF("*"%S*"",X+1)
                       RETURN

        CASE S.FOR:
                SIZE := SIZE + 2

        CASE S.COND:CASE S.FNDEF:CASE S.RTDEF:
        CASE S.TEST:CASE S.CONSTDEF:
                SIZE := SIZE + 1

        CASE S.NEEDS:CASE S.SECTION:CASE S.VECAP:CASE S.BYTEAP:CASE S.FNAP:
        CASE S.MULT:CASE S.DIV:CASE S.REM:CASE S.PLUS:CASE S.MINUS:
        CASE S.EQ:CASE S.NE:CASE S.LS:CASE S.GR:CASE S.LE:CASE S.GE:
        CASE S.LSHIFT:CASE S.RSHIFT:CASE S.LOGAND:CASE S.LOGOR:
        CASE S.EQV:CASE S.NEQV:CASE S.COMMA:
        CASE S.AND:CASE S.VALDEF:CASE S.VECDEF:
        CASE S.ASS:CASE S.RTAP:CASE S.COLON:CASE S.IF:CASE S.UNLESS:
        CASE S.WHILE:CASE S.UNTIL:CASE S.REPEATWHILE:
        CASE S.REPEATUNTIL:
        CASE S.SWITCHON:CASE S.CASE:CASE S.SEQ:CASE S.LET:
        CASE S.MANIFEST:CASE S.STATIC:CASE S.GLOBAL:
                SIZE := SIZE + 1

        CASE S.VALOF:CASE S.LV:CASE S.RV:CASE S.NEG:CASE S.NOT:
        CASE S.TABLE:CASE S.GOTO:CASE S.RESULTIS:CASE S.REPEAT:
        CASE S.DEFAULT:CASE S.ABS:
                SIZE := SIZE + 1

        CASE S.LOOP:
        CASE S.BREAK:CASE S.RETURN:CASE S.FINISH:CASE S.ENDCASE:
        CASE S.TRUE:CASE S.FALSE:CASE S.QUERY:
        DEFAULT:
                SIZE := SIZE + 1

                IF N=D DO $( WRITES("ETC")
                             RETURN  $)

                WRITES ("OP")
                WRITEN(H1!X)
                FOR I = 2 TO SIZE DO
                     $( NEWLINE()
                        FOR J=0 TO N-1 DO WRITES( V!J )
                        WRITES("**-")
                        V!N := I=SIZE->"  ","! "
                        PLIST(H1!(X+I-1), N+1, D)  $)
                RETURN  $)1

.


//    TRN0
SECTION "TRN0"


GET "TRNHDR"

LET NEXTPARAM() = VALOF
    $( PARAMNUMBER := PARAMNUMBER + 1
       RESULTIS PARAMNUMBER  $)

AND TRANSREPORT(N, X) BE
    $( SELECTOUTPUT(SYSPRINT)
       REPORTCOUNT := REPORTCOUNT + 1
       IF REPORTCOUNT GE REPORTMAX DO
                $( WRITES("*NCOMPILATION ABORTED*N")
                   STOP(8)  $)
       WRITES("*NREPORT:   "); TRNMESSAGE(N)
       WRITEF("*NCOMMANDS COMPILED %N*N", COMCOUNT)
       PLIST(X, 0, 4); NEWLINE()
       SELECTOUTPUT(OCODE)  $)

AND TRNMESSAGE(N) BE
$( LET S = VALOF
    SWITCHON N INTO

    $( DEFAULT: WRITEF("COMPILER ERROR  %N", N); RETURN

       CASE 141: RESULTIS "TOO MANY CASES"
       CASE 104: RESULTIS "ILLEGAL USE OF BREAK, LOOP OR RESULTIS"
       CASE 101:
       CASE 105: RESULTIS "ILLEGAL USE OF CASE OR DEFAULT"
       CASE 106: RESULTIS "TWO CASES WITH SAME CONSTANT"
       CASE 144: RESULTIS "TOO MANY GLOBALS"
       CASE 142: RESULTIS "NAME DECLARED TWICE"
       CASE 143: RESULTIS "TOO MANY NAMES DECLARED"
       CASE 115: RESULTIS "NAME NOT DECLARED"
       CASE 116: RESULTIS "DYNAMIC FREE VARIABLE USED"
       CASE 117:CASE 118:CASE 119:
                 RESULTIS "ERROR IN CONSTANT EXPRESSION"
       CASE 110:CASE 112:
                 RESULTIS "LHS AND RHS DO NOT MATCH"
       CASE 109:CASE 113:
                 RESULTIS "LTYPE EXPRESSION EXPECTED"
                   $)

   WRITES(S)   $)


LET COMPILEAE(X) BE
   $(1 LET A = VEC 1500
       LET D = VEC 200
       LET K = VEC 300
       LET L = VEC 300

       DVEC, DVECS, DVECE, DVECP, DVECT := A, 3, 3, 3, 1500
       DVEC!0, DVEC!1, DVEC!2 := 0, 0, 0

       GLOBDECL, GLOBDECLS, GLOBDECLT := D, 0, 200

       CASEK, CASEL, CASEP, CASET, CASEB := K, L, 0, 300, -1
       ENDCASELABEL, DEFAULTLABEL := 0, 0

       RESULTLABEL, BREAKLABEL, LOOPLABEL := -1, -1, -1

       COMCOUNT, CURRENTBRANCH := 0, X

       OCOUNT := 0

       PARAMNUMBER := 0
       SSP := SAVESPACESIZE
       UNLESS X=0 THEN
        $( UNLESS H1!X=S.SECTION | H1!X=S.NEEDS BREAK
           OUT1(H1!X)
           OUTSTRING(H2!X+1)
           X:=H3!X
        $) REPEAT
       OUT2(S.STACK, SSP)
       DECLLABELS(X)
       TRANS(X)
       OUT2(S.GLOBAL, GLOBDECLS/2)

    $( LET I = 0
       UNTIL I=GLOBDECLS DO
          $( OUTN(GLOBDECL!I)
             OUTL(GLOBDECL!(I+1))
             I := I + 2  $)

       ENDOCODE()  $)1

.

//    TRN1
SECTION "TRN1"


GET "TRNHDR"

LET TRANS(X) BE
  $(TR
NEXT:
 $( LET SW = FALSE
    IF X=0 RETURN
    CURRENTBRANCH := X

    SWITCHON H1!X INTO
$(  DEFAULT: TRANSREPORT(100, X); RETURN

    CASE S.LET:
      $( LET A, B, S, S1 = DVECE, DVECS, SSP, 0
         LET V = VECSSP
         DECLNAMES(H2!X)
         CHECKDISTINCT(B, DVECS)
         DVECE := DVECS
         VECSSP, S1 := SSP, SSP
         SSP := S
         TRANSDEF(H2!X)
         UNLESS SSP=S1 DO TRANSREPORT(110, X)
         UNLESS SSP=VECSSP DO $( SSP := VECSSP
                                 OUT2(S.STACK, SSP)  $)
         OUT1(S.STORE)
         DECLLABELS(H3!X)
         TRANS(H3!X)
         VECSSP := V
         UNLESS SSP=S DO OUT2(S.STACK, S)
         DVECE, DVECS, SSP := A, B, S
         RETURN   $)

    CASE S.STATIC:
    CASE S.GLOBAL:
    CASE S.MANIFEST:
     $(1 LET A, B, S = DVECE, DVECS, SSP
         AND OP = H1!X
         AND Y = H2!X

         IF OP=S.MANIFEST DO OP := S.NUMBER

         UNTIL Y=0 DO
           $( TEST OP=S.STATIC THEN
                $( LET M = NEXTPARAM()
                   ADDNAME(H3!Y, S.LABEL, M)
                   COMPDATALAB(M)
                   OUT2(S.ITEMN, EVALCONST(H4!Y))  $)

                OR ADDNAME(H3!Y, OP, EVALCONST(H4!Y))

              Y := H2!Y
              DVECE := DVECS  $)

         DECLLABELS(H3!X)
         TRANS(H3!X)
         DVECE, DVECS, SSP := A, B, S
         RETURN   $)1


    CASE S.ASS:
       ASSIGN(H2!X, H3!X)
       RETURN

    CASE S.RTAP:
     $( LET S = SSP
        SSP := SSP+SAVESPACESIZE
        OUT2(S.STACK, SSP)
        LOADLIST(H3!X)
        LOAD(H2!X)
        OUT2(S.RTAP, S)
        SSP := S
        RETURN  $)

    CASE S.GOTO:
        LOAD(H2!X)
        OUT1(S.GOTO)
        SSP := SSP-1
        RETURN

    CASE S.COLON:
        OUT2P(S.BLAB, H4!X)
        TRANS(H3!X)
        RETURN

    CASE S.UNLESS: SW := TRUE
    CASE S.IF:
     $( LET L = NEXTPARAM()
        JUMPCOND(H2!X, SW, L)
        TRANS(H3!X)
        COMPLAB(L)
        RETURN   $)

    CASE S.TEST:
     $( LET L, M = NEXTPARAM(), NEXTPARAM()
        JUMPCOND(H2!X, FALSE, L)
        TRANS(H3!X)
        COMPJUMP(M)
        COMPLAB(L)
        TRANS(H4!X)
        COMPLAB(M)
        RETURN   $)

    CASE S.LOOP:
        IF LOOPLABEL<0 DO TRANSREPORT(104, X)
        IF LOOPLABEL=0 DO LOOPLABEL := NEXTPARAM()
        COMPJUMP(LOOPLABEL)
        RETURN

    CASE S.BREAK:
        IF BREAKLABEL<0 DO TRANSREPORT(104, X)
        IF BREAKLABEL=0 DO BREAKLABEL := NEXTPARAM()
        COMPJUMP(BREAKLABEL)
        RETURN

    CASE S.RETURN: OUT1(S.RTRN)
                   RETURN

    CASE S.FINISH: OUT1(S.FINISH)
                   RETURN

    CASE S.RESULTIS:
        IF RESULTLABEL<0 DO TRANSREPORT(104, X)
        LOAD(H2!X)
        OUT2P(S.RES, RESULTLABEL)
        SSP := SSP - 1
        RETURN

    CASE S.WHILE: SW := TRUE
    CASE S.UNTIL:
     $( LET L, M = NEXTPARAM(), NEXTPARAM()
        LET BL, LL = BREAKLABEL, LOOPLABEL
        BREAKLABEL, LOOPLABEL := 0, M

        COMPJUMP(M)
        COMPLAB(L)
        TRANS(H3!X)
        COMPLAB(M)
        JUMPCOND(H2!X, SW, L)
        UNLESS BREAKLABEL=0 DO COMPLAB(BREAKLABEL)
        BREAKLABEL, LOOPLABEL := BL, LL
        RETURN   $)

    CASE S.REPEATWHILE: SW := TRUE
    CASE S.REPEATUNTIL:
    CASE S.REPEAT:
     $( LET L, BL, LL = NEXTPARAM(), BREAKLABEL, LOOPLABEL
        BREAKLABEL, LOOPLABEL := 0, 0
        COMPLAB(L)
        TEST H1!X=S.REPEAT
            THEN $( LOOPLABEL := L
                    TRANS(H2!X)
                    COMPJUMP(L)  $)
              OR $( TRANS(H2!X)
                    UNLESS LOOPLABEL=0 DO COMPLAB(LOOPLABEL)
                    JUMPCOND(H3!X, SW, L)  $)
        UNLESS BREAKLABEL=0 DO COMPLAB(BREAKLABEL)
        BREAKLABEL, LOOPLABEL := BL, LL
        RETURN   $)

    CASE S.CASE:
     $( LET L, K = NEXTPARAM(), EVALCONST(H2!X)
        IF CASEP>=CASET DO TRANSREPORT(141, X)
        IF CASEB<0 DO TRANSREPORT(105, X)
        FOR I = CASEB TO CASEP-1 DO
                    IF CASEK!I=K DO TRANSREPORT(106, X)
        CASEK!CASEP := K
        CASEL!CASEP := L
        CASEP := CASEP + 1
        COMPLAB(L)
        TRANS(H3!X)
        RETURN   $)

    CASE S.DEFAULT:
        IF CASEB<0 DO TRANSREPORT(105, X)
        UNLESS DEFAULTLABEL=0 DO TRANSREPORT(101, X)
        DEFAULTLABEL := NEXTPARAM()
        COMPLAB(DEFAULTLABEL)
        TRANS(H2!X)
        RETURN

    CASE S.ENDCASE: IF CASEB<0 DO TRANSREPORT(105, X)
                    COMPJUMP(ENDCASELABEL)
                    RETURN

    CASE S.SWITCHON:
        TRANSSWITCH(X)
        RETURN

    CASE S.FOR: TRANSFOR(X)
                RETURN

    CASE S.SEQ:
        TRANS(H2!X)
        COMCOUNT :=  COMCOUNT + 1
        X := H3!X
        GOTO NEXT        $)TR
.

//    TRN2
SECTION "TRN2"


GET "TRNHDR"

LET DECLNAMES(X) BE UNLESS X=0 SWITCHON H1!X INTO

     $(  DEFAULT: TRANSREPORT(102, CURRENTBRANCH)
                  RETURN

         CASE S.VECDEF: CASE S.VALDEF:
               DECLDYN(H2!X)
               RETURN

         CASE S.RTDEF: CASE S.FNDEF:
               H5!X := NEXTPARAM()
               DECLSTAT(H2!X, H5!X)
               RETURN

         CASE S.AND:
               DECLNAMES(H2!X)
               DECLNAMES(H3!X)
               RETURN    $)


AND DECLDYN(X) BE UNLESS X=0 DO

    $( IF H1!X=S.NAME DO
          $( ADDNAME(X, S.LOCAL, SSP)
             SSP := SSP + 1
             RETURN   $)

       IF H1!X=S.COMMA DO
          $( ADDNAME(H2!X, S.LOCAL, SSP)
             SSP := SSP + 1
             DECLDYN(H3!X)
             RETURN  $)

       TRANSREPORT(103, X)   $)

AND DECLSTAT(X, L) BE
    $(1 LET T = CELLWITHNAME(X)

       IF DVEC!(T+1)=S.GLOBAL DO
          $( LET N = DVEC!(T+2)
             ADDNAME(X, S.GLOBAL, N)
             IF GLOBDECLS>=GLOBDECLT DO TRANSREPORT(144, X)
             GLOBDECL!GLOBDECLS := N
             GLOBDECL!(GLOBDECLS+1) := L
             GLOBDECLS := GLOBDECLS + 2
             RETURN  $)


    $( LET M = NEXTPARAM()
       ADDNAME(X, S.LABEL, M)
       COMPDATALAB(M)
       OUT2P(S.ITEML, L)    $)1


AND DECLLABELS(X) BE
    $( LET B = DVECS
       SCANLABELS(X)
       CHECKDISTINCT(B, DVECS)
       DVECE := DVECS   $)


AND CHECKDISTINCT(E, S) BE
       UNTIL E=S DO
          $( LET P = E + 3
             AND N = DVEC!E
             WHILE P<S DO
                $( IF DVEC!P=N DO TRANSREPORT(142, N)
                   P := P + 3  $)
             E := E + 3  $)


AND ADDNAME(N, P, A) BE
    $( IF DVECS>=DVECT DO TRANSREPORT(143, CURRENTBRANCH)
       DVEC!DVECS, DVEC!(DVECS+1), DVEC!(DVECS+2) := N, P, A
       DVECS := DVECS + 3  $)


AND CELLWITHNAME(N) = VALOF
    $( LET X = DVECE

       X := X - 3 REPEATUNTIL X=0 \/ DVEC!X=N

       RESULTIS X  $)


AND SCANLABELS(X) BE UNLESS X=0 SWITCHON H1!X INTO

    $( DEFAULT: RETURN

       CASE S.COLON:
            H4!X := NEXTPARAM()
            DECLSTAT(H2!X, H4!X)

       CASE S.IF: CASE S.UNLESS: CASE S.WHILE: CASE S.UNTIL:
       CASE S.SWITCHON: CASE S.CASE:
            SCANLABELS(H3!X)
            RETURN

       CASE S.SEQ:
            SCANLABELS(H3!X)

       CASE S.REPEAT:
       CASE S.REPEATWHILE: CASE S.REPEATUNTIL: CASE S.DEFAULT:
            SCANLABELS(H2!X)
            RETURN

       CASE S.TEST:
            SCANLABELS(H3!X)
            SCANLABELS(H4!X)
            RETURN    $)


AND TRANSDEF(X) BE
    $(1 TRANSDYNDEFS(X)
        IF STATDEFS(X) DO
           $( LET L, S= NEXTPARAM(), SSP
              COMPJUMP(L)
              TRANSSTATDEFS(X)
              SSP := S
              OUT2(S.STACK, SSP)
              COMPLAB(L)  $)1


AND TRANSDYNDEFS(X) BE
        SWITCHON H1!X INTO
     $( CASE S.AND:
            TRANSDYNDEFS(H2!X)
            TRANSDYNDEFS(H3!X)
            RETURN

        CASE S.VECDEF:
            OUT2(S.LLP, VECSSP)
            SSP := SSP + 1
            VECSSP := VECSSP + 1 + EVALCONST(H3!X)
            RETURN

        CASE S.VALDEF: LOADLIST(H3!X)
                       RETURN

        DEFAULT: RETURN  $)

AND TRANSSTATDEFS(X) BE
        SWITCHON H1!X INTO
     $( CASE S.AND:
             TRANSSTATDEFS(H2!X)
             TRANSSTATDEFS(H3!X)
             RETURN

        CASE S.FNDEF: CASE S.RTDEF:
         $(2 LET A, B, C = DVECE, DVECS, DVECP
             AND BL, LL = BREAKLABEL, LOOPLABEL
             AND RL, CB = RESULTLABEL, CASEB
             BREAKLABEL, LOOPLABEL := -1, -1
             RESULTLABEL, CASEB := -1, -1

             COMPENTRY(H2!X, H5!X)
             SSP := SAVESPACESIZE

             DVECP := DVECS
             DECLDYN(H3!X)
             CHECKDISTINCT(B, DVECS)
             DVECE := DVECS
             DECLLABELS(H4!X)

             OUT2(S.SAVE, SSP)

             TEST H1!X=S.FNDEF
                THEN $( LOAD(H4!X); OUT1(S.FNRN)  $)
                  OR $( TRANS(H4!X); OUT1(S.RTRN)  $)

             OUT2(S.ENDPROC, 0)

             BREAKLABEL, LOOPLABEL := BL, LL
             RESULTLABEL, CASEB := RL, CB
             DVECE, DVECS, DVECP := A, B, C   $)2

        DEFAULT: RETURN   $)

AND STATDEFS(X) = H1!X=S.FNDEF \/ H1!X=S.RTDEF -> TRUE,
                  H1!X NE S.AND -> FALSE,
                  STATDEFS(H2!X) -> TRUE,
                  STATDEFS(H3!X)


.

//    TRN3
SECTION "TRN3"


GET "TRNHDR"

LET JUMPCOND(X, B, L) BE
$(JC LET SW = B
     SWITCHON H1!X INTO
     $( CASE S.FALSE: B := NOT B
        CASE S.TRUE: IF B DO COMPJUMP(L)
                     RETURN

        CASE S.NOT: JUMPCOND(H2!X, NOT B, L)
                    RETURN

        CASE S.LOGAND: SW := NOT SW
        CASE S.LOGOR:
         TEST SW THEN $( JUMPCOND(H2!X, B, L)
                         JUMPCOND(H3!X, B, L)  $)

                   OR $( LET M = NEXTPARAM()
                         JUMPCOND(H2!X, NOT B, M)
                         JUMPCOND(H3!X, B, L)
                         COMPLAB(M)  $)

         RETURN

        DEFAULT: LOAD(X)
                 OUT2P(B -> S.JT, S.JF, L)
                 SSP := SSP - 1
                 RETURN     $)JC

AND TRANSSWITCH(X) BE
    $(1 LET P, B, DL = CASEP, CASEB, DEFAULTLABEL
        AND ECL = ENDCASELABEL
        LET L = NEXTPARAM()
        ENDCASELABEL := NEXTPARAM()
        CASEB := CASEP

        COMPJUMP(L)
        DEFAULTLABEL := 0
        TRANS(H3!X)
        COMPJUMP(ENDCASELABEL)

        COMPLAB(L)
        LOAD(H2!X)
        IF DEFAULTLABEL=0 DO DEFAULTLABEL := ENDCASELABEL
        OUT3P(S.SWITCHON, CASEP-P, DEFAULTLABEL)

        FOR I = CASEB TO CASEP-1 DO $( OUTN(CASEK!I)
                                       OUTL(CASEL!I)  $)

        SSP := SSP - 1
        COMPLAB(ENDCASELABEL)
        ENDCASELABEL := ECL
        CASEP, CASEB, DEFAULTLABEL := P, B, DL   $)1

AND TRANSFOR(X) BE
     $( LET A, B = DVECE, DVECS
        LET L, M = NEXTPARAM(), NEXTPARAM()
        LET BL, LL = BREAKLABEL, LOOPLABEL
        LET K, N = 0, 0
        LET STEP = 1
        LET S = SSP
        BREAKLABEL, LOOPLABEL := 0, 0

        ADDNAME(H2!X, S.LOCAL, S)
        DVECE := DVECS
        LOAD(H3!X)

        TEST H1!(H4!X)=S.NUMBER
            THEN K, N := S.LN, H2!(H4!X)
              OR $( K, N := S.LP, SSP
                    LOAD(H4!X)  $)

        UNLESS H5!X=0 DO STEP := EVALCONST(H5!X)

        OUT1(S.STORE)
        COMPJUMP(L)
        DECLLABELS(H6!X)
        COMPLAB(M)
        TRANS(H6!X)
        UNLESS LOOPLABEL=0 DO COMPLAB(LOOPLABEL)
        OUT2(S.LP, S); OUT2(S.LN, STEP); OUT1(S.PLUS); OUT2(S.SP, S)
        COMPLAB(L)
        TEST STEP > 0 THEN
          $( OUT2(S.LP,S)
             OUT2(K,N)
          $)
         ELSE
          $( OUT2(K,N)
             OUT2(S.LP,S)
          $)
        OUT2P(S.ENDFOR, M)

        UNLESS BREAKLABEL=0 DO COMPLAB(BREAKLABEL)
        BREAKLABEL, LOOPLABEL, SSP := BL, LL, S
        OUT2(S.STACK, SSP)
        DVECE, DVECS := A, B  $)

.

//    TRN4
SECTION "TRN4"


GET "TRNHDR"

LET LOAD(X) BE
    $(1 IF X=0 DO $( TRANSREPORT(148, CURRENTBRANCH)
                     LOADZERO()
                     RETURN  $)

     $( LET OP = H1!X

        SWITCHON OP INTO
     $( DEFAULT: TRANSREPORT(147, CURRENTBRANCH)
                 LOADZERO()
                 RETURN

        CASE S.BYTEAP: OP:=S.GETBYTE
        CASE S.DIV: CASE S.REM: CASE S.MINUS:
        CASE S.LS: CASE S.GR: CASE S.LE: CASE S.GE:
        CASE S.LSHIFT: CASE S.RSHIFT:
            LOAD(H2!X)
            LOAD(H3!X)
            OUT1(OP)
            SSP := SSP - 1
            RETURN

        CASE S.VECAP: CASE S.MULT: CASE S.PLUS: CASE S.EQ: CASE S.NE:
        CASE S.LOGAND: CASE S.LOGOR: CASE S.EQV: CASE S.NEQV:
         $( LET A, B = H2!X, H3!X
            IF H1!A=S.NAME \/ H1!A=S.NUMBER DO
                               A, B := H3!X, H2!X
            LOAD(A)
            LOAD(B)
            IF OP=S.VECAP DO $( OUT1(S.PLUS); OP := S.RV  $)
            OUT1(OP)
            SSP := SSP - 1
            RETURN   $)

        CASE S.NEG: CASE S.NOT: CASE S.RV: CASE S.ABS:
            LOAD(H2!X)
            OUT1(OP)
            RETURN

        CASE S.TRUE: CASE S.FALSE: CASE S.QUERY:
            OUT1(OP)
            SSP := SSP + 1
            RETURN

        CASE S.LV: LOADLV(H2!X)
                   RETURN

        CASE S.NUMBER:
            OUT2(S.LN, H2!X)
            SSP := SSP + 1
            RETURN

        CASE S.STRING:
         $( OUT1(S.LSTR)
            OUTSTRING(@ H2!X)
            WRC('*S')
            SSP := SSP + 1
            RETURN   $)

        CASE S.NAME:
             TRANSNAME(X, S.LP, S.LG, S.LL, S.LN)
             SSP := SSP + 1
             RETURN

        CASE S.VALOF:
         $( LET RL = RESULTLABEL
            LET A, B = DVECS, DVECE
            DECLLABELS(H2!X)
            RESULTLABEL := NEXTPARAM()
            TRANS(H2!X)
            COMPLAB(RESULTLABEL)
            OUT2(S.RSTACK, SSP)
            SSP := SSP + 1
            DVECS, DVECE := A, B
            RESULTLABEL := RL
            RETURN   $)


        CASE S.FNAP:
         $( LET S = SSP
            SSP := SSP + SAVESPACESIZE
            OUT2(S.STACK, SSP)
            LOADLIST(H3!X)
            LOAD(H2!X)
            OUT2(S.FNAP, S)
            SSP := S + 1
            RETURN   $)

        CASE S.COND:
         $( LET L, M = NEXTPARAM(), NEXTPARAM()
            LET S = SSP
            JUMPCOND(H2!X, FALSE, M)
            LOAD(H3!X)
            OUT2P(S.RES,L)
            SSP := S; OUT2(S.STACK, SSP)
            COMPLAB(M)
            LOAD(H4!X)
            OUT2P(S.RES,L)
            COMPLAB(L)
            OUT2(S.RSTACK,S)
            RETURN   $)

        CASE S.TABLE:
         $( LET M = NEXTPARAM()
            COMPDATALAB(M)
            X := H2!X
            WHILE H1!X=S.COMMA DO
                  $( OUT2(S.ITEMN, EVALCONST(H2!X))
                     X := H3!X   $)
            OUT2(S.ITEMN, EVALCONST(X))
            OUT2P(S.LLL, M)
            SSP := SSP + 1
            RETURN  $)                         $)1


AND LOADLV(X) BE
    $(1 IF X=0 GOTO ERR

        SWITCHON H1!X INTO
     $( DEFAULT:
        ERR:     TRANSREPORT(113, CURRENTBRANCH)
                 LOADZERO()
                 RETURN

        CASE S.NAME:
              TRANSNAME(X, S.LLP, S.LLG, S.LLL, 0)
              SSP := SSP + 1
              RETURN

        CASE S.RV:
            LOAD(H2!X)
            RETURN

        CASE S.VECAP:
         $( LET A, B = H2!X, H3!X
            IF H1!A=S.NAME DO A, B := H3!X, H2!X
            LOAD(A)
            LOAD(B)
            OUT1(S.PLUS)
            SSP := SSP - 1
            RETURN   $)  $)1

AND LOADZERO() BE $( OUT2(S.LN, 0)
                     SSP := SSP + 1  $)

AND LOADLIST(X) BE UNLESS X=0 DO
    $( UNLESS H1!X=S.COMMA DO $( LOAD(X); RETURN  $)

       LOADLIST(H2!X)
       LOADLIST(H3!X)  $)
.

//    TRN5
SECTION "TRN5"


GET "TRNHDR"

LET EVALCONST(X) = VALOF
    $(1 IF X=0 DO $( TRANSREPORT(117, CURRENTBRANCH)
                     RESULTIS 0  $)

        SWITCHON H1!X INTO
     $( DEFAULT: TRANSREPORT(118, X)
                 RESULTIS 0

        CASE S.NAME:
         $( LET T = CELLWITHNAME(X)
            IF DVEC!(T+1)=S.NUMBER RESULTIS DVEC!(T+2)
            TRANSREPORT(119, X)
            RESULTIS 0  $)

        CASE S.NUMBER: RESULTIS H2!X
        CASE S.TRUE:   RESULTIS TRUE
        CASE S.FALSE:  RESULTIS FALSE

        CASE S.NEG:    RESULTIS  -  EVALCONST(H2!X)
        CASE S.ABS:    RESULTIS ABS EVALCONST(H2!X)
        CASE S.NOT:    RESULTIS NOT EVALCONST(H2!X)

        CASE S.MULT:   RESULTIS EVALCONST(H2!X)   *    EVALCONST(H3!X)
        CASE S.DIV:    RESULTIS EVALCONST(H2!X)   /    EVALCONST(H3!X)
        CASE S.REM:    RESULTIS EVALCONST(H2!X)  REM   EVALCONST(H3!X)
        CASE S.PLUS:   RESULTIS EVALCONST(H2!X)   +    EVALCONST(H3!X)
        CASE S.MINUS:  RESULTIS EVALCONST(H2!X)   -    EVALCONST(H3!X)
        CASE S.LSHIFT: RESULTIS EVALCONST(H2!X)   <<   EVALCONST(H3!X)
        CASE S.RSHIFT: RESULTIS EVALCONST(H2!X)   >>   EVALCONST(H3!X)
        CASE S.LOGOR:  RESULTIS EVALCONST(H2!X) LOGOR  EVALCONST(H3!X)
        CASE S.LOGAND: RESULTIS EVALCONST(H2!X) LOGAND EVALCONST(H3!X)
        CASE S.EQV:    RESULTIS EVALCONST(H2!X)  EQV   EVALCONST(H3!X)
        CASE S.NEQV:   RESULTIS EVALCONST(H2!X)  NEQV  EVALCONST(H3!X)
                    $)1


AND ASSIGN(X, Y) BE
    $(1 IF X=0 \/ Y=0 DO
            $( TRANSREPORT(110, CURRENTBRANCH)
               RETURN  $)

        SWITCHON H1!X INTO
     $( CASE S.COMMA:
            UNLESS H1!Y=S.COMMA DO
                       $( TRANSREPORT(112, CURRENTBRANCH)
                          RETURN   $)
            ASSIGN(H2!X, H2!Y)
            ASSIGN(H3!X, H3!Y)
            RETURN

        CASE S.NAME:
            LOAD(Y)
            TRANSNAME(X, S.SP, S.SG, S.SL, 0)
            SSP := SSP - 1
            RETURN

        CASE S.BYTEAP:
            LOAD(Y)
            LOAD(H2!X)
            LOAD(H3!X)
            OUT1(S.PUTBYTE)
            SSP:=SSP-3
            RETURN

        CASE S.RV: CASE S.VECAP: CASE S.COND:
            LOAD(Y)
            LOADLV(X)
            OUT1(S.STIND)
            SSP := SSP - 2
            RETURN

        DEFAULT: TRANSREPORT(109, CURRENTBRANCH)   $)1


AND TRANSNAME(X, P, G, L, N) BE
    $(1 LET T = CELLWITHNAME(X)
        LET K, A = DVEC!(T+1), DVEC!(T+2)

        IF T=0 DO $( TRANSREPORT(115, X)
                     OUT2(G, 2)
                     RETURN  $)

        SWITCHON K INTO
        $( CASE S.LOCAL: IF T<DVECP DO TRANSREPORT(116, X)
                         OUT2(P, A); RETURN

           CASE S.GLOBAL: OUT2(G, A); RETURN

           CASE S.LABEL: OUT2P(L, A); RETURN

           CASE S.NUMBER: IF N=0 DO $( TRANSREPORT(113, X)
                                       N := P  $)
                          OUT2(N, A)  $)1

.

//    TRN6
SECTION "TRN6"


GET "TRNHDR"

LET COMPLAB(L) BE OUT2P(S.LAB, L)

AND COMPENTRY(N, L) BE
    $(  LET S = @N!2
        OUT3P(S.ENTRY, GETBYTE(S, 0), L)
        FOR I = 1 TO GETBYTE(S, 0) DO
          OUTC(GETBYTE(S, I))
        WRC('*S')  $)

AND COMPDATALAB(L) BE OUT2P(S.DATALAB, L)

AND COMPJUMP(L) BE OUT2P(S.JUMP, L)

AND OUT1(X) BE
    $( WRITEOP(X); WRC('*S')  $)

AND OUT2(X, Y) BE
    $( WRITEOP(X); WRC('*S')
       WRN(Y); WRC('*S')   $)

AND OUT2P(X, Y) BE
    $( WRITEOP(X); WRC('*S'); WRC('L')
       WRN(Y); WRC('*S')   $)

AND OUT3P(X, Y, Z) BE
    $( WRITEOP(X); WRC('*S')
       WRN(Y); WRC('*S'); WRC('L')
       WRN(Z); WRC('*S')   $)


AND OUTN(N) BE WRN(N)

AND OUTL(X) BE
    $( WRC('*S'); WRC('L'); WRN(X); WRC('*S')  $)

AND OUTC(X) BE
    $( WRN(X); WRC('*S')   $)

AND OUTSTRING(X) BE
    $( LET L = GETBYTE(X,0)
       WRN(L); WRC('*S')
       FOR I=1 TO L DO
         OUTC(GETBYTE(X,I))
    $)

AND WRITEOP(X) BE WRPN(X)

AND WRN(N) BE $( IF N<0 DO
                   $( WRC('-'); N := - N
                      IF N<0 THEN
                        $( LET NDIV10 = (N>>1)/5
                           WRPN(NDIV10)
                           N:=N-NDIV10*10
                        $)
                   $)
                 WRPN(N)  $)

AND WRPN(N) BE $( IF N>9 DO WRPN(N/10)
                  WRC(N REM 10 + '0')  $)

AND ENDOCODE() BE $( WRCH('*N'); OCOUNT := 0  $)


AND WRC(CH) BE $( OCOUNT := OCOUNT + 1
                  IF OCOUNT>62 /\ CH='*S' DO
                            $( WRCH('*N'); OCOUNT := 0; RETURN  $)
                  WRCH(CH)  $)




