\ test for XISF.f
\ include "%idir%\..\ForthBase\ForthBase.f"
\ include "%idir%\..\ForthBase\FiniteFractions.f"
include "%idir%\buffers.f"
include "%idir%\XISF.f"
include "%idir%\..\simple-tester\simple-tester.f"

CR
Tstart

	640 480 1 allocate-image
	CONSTANT img1

	img1 s" E:\test\MadeInForth.XISF" 2dup CR type CR 
	save-image
	img1 free-image
	
Tend
