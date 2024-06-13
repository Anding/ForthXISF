\ test for XISF.f
include "%idir%\..\ForthBase\ForthBase.f"
include "%idir%\..\ForthBase\FiniteFractions.f"
include "%idir%\buffers.f"
include "%idir%\xml.f"
include "%idir%\XISF.f"
include "%idir%\..\simple-tester\simple-tester.f"

CR
Tstart

	640 480 1 allocate-image
	CONSTANT img1
	
T{ img1 image_size }T 640 480 1 2* * * ==
T{ img1 initialize-XISFimage 0 }T 0 ==

T{ img1 s" E:\test\MadeInForth.XISF" save-image 0 }T 0 ==
T{	img1 free-image 0 }T 0 ==
	
Tend
