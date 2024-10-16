\ test for XISF.f
include "%idir%\..\ForthBase\libraries\libraries.f"
NEED forthbase
NEED finitefractions
NEED buffers
NEED forth-map
NEED ForthXML

include "%idir%\XISF.f"
NEED simple-tester

CR
Tstart

	640 480 1 allocate-image
	CONSTANT img1
	
	map-strings
	map CONSTANT map1
		s" FOCUSPOS" 	map1 >addr s" 2000" rot place
		s" INSTRUMENT"	map1 >addr s" SXV-H9" rot place
		s" TIME-OBS" 	map1 >addr s" 23:30:35" rot place
	map1 img1 FITS_MAP !
	
	map CONSTANT map2
		s" UInt16" 	map2 =>" sampleFormat"
		s" Gray" 	map2 =>" colorSpace"
		s" Light"	map2 =>" IMAGETYPE"
		s" 500"		map2 =>" OFFSET"
	map2 img1 XISF_MAP !
	
: test_write-filepath_buffer { map buf -- }									\ VFX locals
	s" %idir%\XISF_test1.xisf" buf write-buffer drop
;

	ASSIGN test_write-filepath_buffer TO-DO write-filepath_buffer	
	
T{ img1 image_size }T 640 480 1 2* * * ==
T{ img1 initialize-XISFimage 0 }T 0 ==		\ check no conflict to repeat the preparation of the XISF buffer
T{ img1 save-image 0 }T 0 ==
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
