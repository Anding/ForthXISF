\ test for XISF.f
include "%idir%\..\ForthBase\ForthBase.f"
include "%idir%\..\ForthBase\FiniteFractions.f"
include "%idir%\XISF.f"

XISF_BUFFER BUFFER XISFBuffer
variable focusPos		2000 focusPos !
variable observationTime 23 30 35 ~ observationTime !
256 buffer: instrument$		s" Takahashi CCA-250" instrument$ $!
640 ImageWidth !	480 ImageHeight !

s" FOCUSPOS" focusPos ' FITS.INT FITS.MAKE FITS.KEYfocusPos
s" INSTRUMENT" instrument$ ' FITS.STR FITS.MAKE FITS.KEYinstrument
s" TIME-OBS" observationTime ' FITS.FF: FITS.MAKE FITS.KEYtime-obs 

XISFBuffer XISF.StartHeader
	XISF.StartXML 
	XISF.StartImage
		FITS.KEYfocuspos
		FITS.KEYinstrument
		FITS.KEYtime-obs
	XISF.FinishImage 
	XISF.FinishXML
XISF.FinishHeader

XISFBuffer 512 dump

s" C:\test\MadeInForth.XISF" XISF.WriteFile