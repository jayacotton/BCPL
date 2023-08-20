# BCPL

Get a BCPL compiler running so that the xerox parc ALTO operating
system code can be compiled in a linux environment.

I downloaded this compiler from bitsaver with the intention of 
converting it to compile for 68000 or 68020/68030 as running on
the S100 bus.  See s100computers.com for information on the 
CPU boards.

Below is the original README from the distro I copied.  I will
include the Copyright at the end.

8/20/23 An interest point.  Code compiled on an X86 based Linux
distro with the BCPL compiler, runs on Linux.  This should make
testing code much faster.

8/20/23 is the starting date of this new project, at this time I
am setting up a github repo the allow development to proceed.

Much gratitude to Robert Nordier and Martin Richards for keeping this
code alive.

This is an x86 (IA-32) port of the "classic" old BCPL compiler
(around 1980) from the Tripos Research Group at Cambridge University.

BCPL was a popular systems programming language during the 1960s
and 1970s, and is of great historical importance: about the time
of the birth of UNIX, BCPL directly inspired the computer language
B and thus had a very big influence on the development of C.

The compiler available here is very close to that featured in the
book, _BCPL: the language and its compiler_ by Martin Richards and
Colin Whitby-Stevens (Cambridge: Cambridge University Press, 1979).

As a real, working computer language implementation, that can be
studied, modified, and played with, the classic BCPL compiler has
a good deal to recommend it.  The compiler frontend consists of
only about 2000 lines of BCPL code, and (as supplied here) compiles
to a static (fully-linked) x86 binary that is less than 36000 bytes
in size.

The present distribution supplies a compiler backend (OCODE to x86
code generator), together with peephole optimizer, and reasonably
extensive runtime support.  A few revisions have been made to the
compiler frontend -- it looks for header files in a standard location,
for instance -- and  the runtime incorporates support for UNIX
command line arguments and error reporting.  Some documentation
that formed part of the original BCPL distribution tape is also
included, as are a few utility programs.

Martin Richards, the originator of BCPL, has a home page at

    http://www.cl.cam.ac.uk/~mr10/

Richards has continued to develop BCPL, very much as though it were
still a living language, and has a large and complex distribution
of "present day" BCPL available, together with some archive materials.

The web page for this distribution is

    http://www.nordier.com/software/obcpl.html


Robert Nordier
www.nordier.com

Most of the files here are taken from a BCPL compiler distribution
dating from the early 1980s.  None of the files bears a copyright
notice in the original, but -- on the basis of other files in the
distribution -- it seems reasonable to assume that the bulk of these
are

   (c) Copyright 1978-1980 Tripos Research Group
       University of Cambridge
       Computer Laboratory

Changes and additions are

    (c) Copyright 2004, 2012 Robert Nordier

and are freely redistributable.


Robert Nordier
www.nordier.com

