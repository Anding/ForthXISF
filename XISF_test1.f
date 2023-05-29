\ test for XISF.f

XISF_BUFFER allocate ( addr ior) throw constant XISFBuffer  \ BUFFER: cannot handle allocations of this size
variable fpos
2000 fpos !

s" FOCUSPOS" fpos XISF.MAKE-FITSKEY-INT XISF.FITSfocuspos

XISFBuffer XISF.StartHeader
	XISF.StartXML
		XISF.StartImage
			XISF.FITSfocuspos
		XISF.FinishImage
	XISF.FinishXML
XISF.FinishHeader

XISFBuffer 256 dump

s" C:\test\MadeInForth.XISF" XISF.WriteFile