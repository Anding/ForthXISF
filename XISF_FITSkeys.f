\ FITS keyword headers for XISF file format
\ requires XISF.f

\ FITS variables
shared variable focusPos
shared variable imageWidth
shared variable imageHeight

shared variable telescope$
shared variable instrument$

shared variable date

\ FITS defining words
s" FOCUSPOS" focusPos XISF.MAKE-FITSKEY-INT FITSfocusPos
s" FOCUSPOS" focusPos XISF.MAKE-FITSKEY-INT FITSimageWidth

s" INSTRUMENT" instrument$  XISF.MAKE-FITSKEY-STR FITSinstrument$
s" TELESCOPE" telescope$  XISF.MAKE-FITSKEY-STR FITStelescope$