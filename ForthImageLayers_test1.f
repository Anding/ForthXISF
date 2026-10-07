\ Verify that the split image packages have only their declared responsibilities.

NEED simple-tester
NEED ForthImageExport

[DEFINED] xisf.load-file [IF]
    abort" ForthImageExport must not load image readers"
[THEN]

[DEFINED] XISF.encode-header [IF]
    abort" ForthImageExport must not load the XISF codec"
[THEN]

Tstart
T{ [DEFINED] save-PNGimage-to }T -1 ==
T{ [DEFINED] save-RAWimage-to }T -1 ==
Tend

bye
