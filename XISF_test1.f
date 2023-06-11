\ test for XISF.f

XISF_BUFFER BUFFER XISFBuffer
variable fpos		2000 fpos !
256 buffer: instrument		s" Takahashi CCA-250" instrument $!
640 ImageWidth !	480 ImageHeight !

s" FOCUSPOS" fpos XISF.MAKE-FITSKEY-INT XISF.FITSfocuspos
s" INSTRUMENT" instrument  XISF.MAKE-FITSKEY-STR XISF.FITSinstrument

XISFBuffer XISF.StartHeader
	XISF.StartXML 
	XISF.StartImage
		XISF.FITSfocuspos
		XISF.FITSinstrument
	XISF.FinishImage 
	XISF.FinishXML
XISF.FinishHeader

XISFBuffer 512 dump

s" C:\test\MadeInForth.XISF" XISF.WriteFile