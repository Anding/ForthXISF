\ Save a 16-bit greyscale frame as an 8-bit PNG at an explicit destination.

: save-PNGimage-to { frame filepath-buffer -- }
    filepath-buffer create-imageDirectory
    frame FRAME_BITMAP
    frame FRAME_WIDTH @
    frame FRAME_HEIGHT @
    filepath-buffer buffer-to-string drop
    SaveBitmapAsPNG abort" Error writing PNG file"
;