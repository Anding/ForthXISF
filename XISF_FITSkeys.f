\ FITS keyword headers for XISF file format
\ requires XISF.f

\ FITS variables
\ integers
shared variable focusPos

\ strings
shared variable telescope$
shared variable instrument$

\ finite fractions
shared variable observationDate
shared variable observationTime
shared variable targetRA
shared variable targetDec
shared variable latitude


\ FITS defining words
s" FOCUSPOS" focusPos ' FITS.INT FITS.MAKE FITS.KEYfocusPos

s" INSTRUMENT" instrument$  ' FITS.STR FITS.MAKE FITS.KEYinstrument
s" TELESCOPE" telescope$  ' FITS.STR FITS.MAKE FITS.KEYtelescope

s" DATE-OBS" observationDate ' FITS.FF- FITS.MAKE FITS.KEYdate-obs 
s" TIME-OBS" observationTime ' FITS.FF: FITS.MAKE FITS.KEYtime-obs 
s" RA" targetRA ' FITS.FF: FITS.MAKE FITS.KEYRA
s" DEC" targetDec ' FITS.FF: FITS.MAKE FITS.KEYdec 