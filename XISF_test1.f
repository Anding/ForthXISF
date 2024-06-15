\ test for XISF.f
include "%idir%\..\ForthBase\ForthBase.f"
include "%idir%\..\ForthBase\FiniteFractions\FiniteFractions.f"
include "%idir%\..\ForthBase\buffers\buffers.f"
include "%idir%\..\ForthXML\xml.f"
include "%idir%\XISF.f"
include "%idir%\..\simple-tester\simple-tester.f"

CR
Tstart

	640 480 1 allocate-image
	CONSTANT img1
	
T{ img1 image_size }T 640 480 1 2* * * ==
T{ img1 initialize-XISFimage 0 }T 0 ==		\ check no conflict to repeat the preparation of the XISF buffer
T{ img1 s" %idir%\XISF_test1.xisf" save-image 0 }T 0 ==
T{	img1 free-image 0 }T 0 ==

\ serialize XISF_test1.xisf and the reference file to buffers
	s" %idir%\XISF_test1.xisf" r/o open-file drop
	constant fileid1
	fileid1 file-to-buffer
	constant buf1

	s" %idir%\XISF_test1_reference.xisf" r/o open-file drop
	constant fileid2
	fileid2 file-to-buffer
	constant buf2

\ compare XISF_test1.xisf and the reference
T{ buf1 buffer-to-string hashS }T buf2 buffer-to-string hashS ==

Tend
