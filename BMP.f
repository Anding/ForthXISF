\ Save a 16-bit greyscale bitmap as an 8-bit greyscale BMP using each sample's
\ high byte. The caller owns the filepath buffer and its directory portion.

: save-BMPimage { frame bitmap filepath-buffer -- }
    filepath-buffer create-imageDirectory
    0 filepath-buffer echo-buffer abort" BMP filepath buffer full"
    bitmap
    frame FRAME_WIDTH @
    frame FRAME_HEIGHT @
    filepath-buffer buffer-to-string drop
    SaveBitmapAsBMP abort" Error writing BMP file"
;
