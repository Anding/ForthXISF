\ Save a 16-bit greyscale frame as a raw binary file at an explicit destination.

: SaveBitmapAsBinary { bitmap width height caddr | fileid bitdepth t -- IOR }
\ AIMG is a deliberately small native interchange format: magic, width,
\ height, bit depth, reserved cell, then host-endian 16-bit pixels.
    caddr zcount delete-file drop
    caddr zcount w/o create-file if -1 exit then -> fileid
    s" AIMG" fileid write-file drop
    ADDR width 4 fileid write-file drop
    ADDR height 4 fileid write-file drop
    16 -> bitdepth
    ADDR bitdepth 4 fileid write-file drop
    0 -> t
    ADDR t 4 fileid write-file drop
    bitmap width height * 2* fileid write-file drop
    fileid close-file ( IOR)
;

: save-RAWimage-to { frame filepath-buffer -- }
    filepath-buffer create-imageDirectory
    frame FRAME_BITMAP
    frame FRAME_WIDTH @
    frame FRAME_HEIGHT @
    filepath-buffer buffer-to-string drop
    ( bitmap width height caddr) SaveBitmapAsBinary abort" Error writing RAW file"
;