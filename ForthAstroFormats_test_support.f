\ Shared frame and filepath helpers for codec regression tests.

NEED ForthImageLoaders

: test.make-frame { | frame map -- frame }
    64 48 1 allocate-frame -> frame
    frame FRAME_METADATA @ -> map
    s" 16" map =>" BITPIX"
    s" 2" map =>" NAXIS"
    s" 64" map =>" NAXIS1"
    s" 48" map =>" NAXIS2"
    s" UInt16" map =>" SMPLFRMT"
    s" Gray" map =>" COLORSPC"
    s" Light" map =>" IMAGETYP"
    s" -50" map =>" OFFSET"
    s" test-frame" map =>" UUID"
    64 48 * 0 do
        i 257 * 0x10000 mod frame FRAME_BITMAP i 2* + w!
    loop
    frame
;

: test.prepare-path { filename-addr filename-u filepath-buffer -- filepath-buffer }
    filepath-buffer reset-buffer
    s" E:\Coding\ForthAstroFormats\testdata\" filepath-buffer write-buffer drop
    filepath-buffer buffer-punctuate-filepath
    filename-addr filename-u filepath-buffer write-buffer drop
    filepath-buffer
;
