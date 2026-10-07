NEED ForthAstroSolver
NEED simple-tester

4 3 1 allocate-frame constant solver.test-frame
solver.test-frame FRAME_METADATA @ constant solver.test-metadata

s" 04:29:05.0" solver.test-metadata =>" OBJCTRA"
s" +29:33:59.0" solver.test-metadata =>" OBJCTDEC"
s" 00:00:00.0" solver.test-metadata =>" SIDEREAL"
s" 2461082.0" solver.test-metadata =>" NIGHTOF"
s" EAST" solver.test-metadata =>" PIERSIDE"
s" 67.2708" solver.test-metadata =>" CRVAL1"
s" 29.5664" solver.test-metadata =>" CRVAL2"

Tstart

T{ solver.test-metadata solver.alignment-FITS }T ==
T{ s" 10UALPT" solver.test-metadata >string nip 0> }T -1 ==
T{ s" 10UALPT" solver.test-metadata >string s\" s\" " search nip nip }T -1 ==
T{ s" 10UALPT" solver.test-metadata >string
   s" add-alignment-point" search nip nip
}T -1 ==

Tend

solver.test-frame free-frame
bye
