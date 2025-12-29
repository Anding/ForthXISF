\ test for XISF.f
include "%idir%\XISF.f"\
NEED simple-tester

CR
Tstart

T{ 640 480 1 allocate-image CONSTANT img1 }T ==
	
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
	
: test_write-filepath_buffer ( map buf -- )
	>R drop
	s" e:\coding\ForthXISF\" R@ write-buffer drop
	R@ buffer-punctuate-filepath
	s" XISF_test1.xisf" R@ write-buffer drop
	R> drop
;
	ASSIGN test_write-filepath_buffer TO-DO write-filepath_buffer	
	
T{ img1 image_size }T 640 480 1 2* * * ==
T{ img1 initialize-XISFimage }T ==
T{ img1 initialize-XISFfilepath }T ==
cr img1 FILEPATH_BUFFER
	dup buffer-filepath-to-string type CR
	dup buffer-drive-to-string type CR
	dup buffer-dir-to-string type CR
	dup buffer-filename-to-string type CR
	drop
T{ img1 create-imageDirectory }T ==
T{ img1 save-image }T ==
T{	img1 free-image }T ==

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
