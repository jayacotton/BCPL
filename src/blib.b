// BLIB

GET "LIBHDR"

LET WRITES(S) BE FOR I = 1 TO S%0 DO WRCH(S%I)

AND WRITED(N, D) BE
$(  LET T = VEC 20
    AND I, K = 0, N
    TEST N<0 THEN D := D-1 ELSE K := -N
    T!I, K, I := K REM 10, K/10, I+1 REPEATUNTIL K=0
    FOR J = I+1 TO D DO WRCH('*S')
    IF N<0 DO WRCH('-')
    FOR J = I-1 TO 0 BY -1 DO WRCH('0'-T!J)  $)

AND WRITEN(N) BE WRITED(N, 0)

AND NEWLINE() BE WRCH('*N')

AND NEWPAGE() BE WRCH('*P')

AND READN() = VALOF
$(  LET SUM = 0
    AND NEG = FALSE
L: TERMINATOR := RDCH()
    SWITCHON TERMINATOR INTO
    $(  CASE '*S':
        CASE '*T':
        CASE '*N':    GOTO L
        CASE '-':     NEG := TRUE
        CASE '+':     TERMINATOR := RDCH()  $)
    WHILE '0'<=TERMINATOR<='9' DO
                 $( SUM := 10*SUM + TERMINATOR - '0'
                    TERMINATOR := RDCH() $)
    IF NEG DO SUM := -SUM
    RESULTIS SUM  $)

AND WRITEOCT(N, D) BE
    $( IF D>1 DO WRITEOCT(N>>3, D-1)
       WRCH((N&7)+'0')  $)

AND WRITEHEX(N, D) BE
    $( IF D>1 DO WRITEHEX(N>>4, D-1)
       WRCH((N&15)!TABLE
            '0','1','2','3','4','5','6','7',
            '8','9','A','B','C','D','E','F')  $)

AND WRITEF(FORMAT, A, B, C, D, E, F, G, H, I, J, K) BE
$(  LET T = @A
    FOR P = 1 TO FORMAT%0 DO
    $(  LET K = FORMAT%P
        TEST K='%'
          THEN $(  LET F, Q, N = 0, T!0, 0
                   AND TYPE = FORMAT%(P+1)
                   P := P + 1
                   SWITCHON CAPITALCH(TYPE) INTO
                $( DEFAULT: WRCH(TYPE); ENDCASE
                   CASE 'S': F := WRITES; GOTO L
                   CASE 'C': F := WRCH; GOTO L
                   CASE 'O': F := WRITEOCT; GOTO M
                   CASE 'X': F := WRITEHEX; GOTO M
                   CASE 'I': F := WRITED; GOTO M
                   CASE 'N': F := WRITED; GOTO L
                M: P := P + 1
                   N := CAPITALCH(FORMAT%P)
                   N := '0'<=N<='9' -> N-'0', N-'A'+10
                L: F(Q, N); T := T + 1  $) $)
            OR WRCH(K)  $) $)

AND CAPITALCH(CH) = 'a'<=CH<='z' -> CH-('a'-'A'), CH
