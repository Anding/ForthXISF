\ Preview artifact writers for the shared current image.

NEED ImageAnalysis
NEED BMP
NEED ForthPublication

: save-stretched-BMPimage { | bitmap ior -- }
\ Apply the display function and save the resulting high-byte BMP.
    image frame-size allocate abort" Cannot allocate stretched bitmap"
        -> bitmap
    image bitmap apply-displayFunction-to
    image s" .bmp" stretched-BMPfilepath write-filepath-stretched-bmp
    image bitmap stretched-BMPfilepath ['] save-BMPimage-to catch -> ior
    bitmap free abort" Cannot free stretched bitmap"
    ior ?dup if throw then
;

: save-Histogram ( -- )
\ Save the current image histogram as 65,536 four-byte bins.
    image s" .bin" histogram-filepath write-filepath-histogram
    image FRAME_STATISTICS @ HISTOGRAM 0x40000 histogram-filepath
        save-binary-file-to
;
