\ test for XISF.f
NEED simple-tester

include "%idir%\XISF.f"\

CR
Tstart

T{ 640 480 1 allocate-image CONSTANT img1 }T ==
	
	map CONSTANT map1
	map1 img1 FITS_MAP !	
		s" 2000" map1 =>" FOCUSPOS" 
		s" SXV-H9" map1 =>" INSTRUMENT" 
		s" 23:30:35" map1 =>" TIME-OBS" 
		s" ff11238a23a4" map1 =>" UUID"
		s" UInt16" map1 =>" SMPLFRMT" 
		s" Gray" map1 =>" COLORSPC" 
		s" Light" map1 =>" IMAGETYP" 
		s" -50" map1 =>" OFFSET" 
		s" ff11238a23a4" map1 =>" UUID" 
	
: test_write-XISFfilepath_buffer ( map buf -- )
	>R drop
	s" e:\coding\ForthXISF\" R@ write-buffer drop
	R@ buffer-punctuate-filepath
	s" XISF_test1.xisf" R@ write-buffer drop
	R> drop
;
	ASSIGN test_write-XISFfilepath_buffer TO-DO write-XISFfilepath_buffer	
	
T{ img1 image_size }T 640 480 1 2* * * ==
T{ img1 initialize-XISFimage }T ==
T{ img1 initialize-XISFfilepath }T ==
cr img1 XISF_FILEPATH_BUFFER
	dup buffer-filepath-to-string type CR
	dup buffer-drive-to-string type CR
	dup buffer-dir-to-string type CR
	dup buffer-filename-to-string type CR
	drop
T{ img1 XISF_FILEPATH_BUFFER create-imageDirectory }T ==
T{ img1 save-XISFimage }T ==
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
