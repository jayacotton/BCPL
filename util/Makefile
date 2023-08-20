# Makefile for obcpl/util

BC=obcpl
BFLAGS=-O

all: cmpltest xref gpm

cmpltest: cmpltest.b
	$(BC) $(BFLAGS) cmpltest.b

xref: xref.b
	$(BC) $(BFLAGS) xref.b

gpm: gpm.b
	$(BC) $(BFLAGS) gpm.b

install:

clean:
	rm -f cmpltest cmpltest.o
	rm -f xref xref.o
	rm -f gpm gpm.o
