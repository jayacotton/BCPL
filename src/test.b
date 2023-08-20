// Implement a UNIX wc(1)-like filter that
// counts lines, words, and characters.

// Robert Nordier   21 Dec 2004

GET "LIBHDR"

LET START() = VALOF
$(
    LET LC, WC, CC = 0, 0, 0
    AND SP = TRUE
    $(
        LET CH = RDCH()
        IF CH=ENDSTREAMCH BREAK
        IF CH='*N' THEN LC := LC + 1
        TEST CH='*T' | CH='*N' | CH='*S' THEN
            SP := TRUE
        OR IF SP $(
            WC := WC + 1
            SP := FALSE $)
        CC := CC + 1
    $) REPEAT
    WRITEF("%N %N %N*N", LC, WC, CC) 
    RESULTIS 0
$)

