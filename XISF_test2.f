\ test for XISF.f
NEED simple-tester

include "%idir%\XISF.f"\

CR
Tstart

T{ 640 480 1 allocate-image CONSTANT img1 }T ==
	
	img1 FITS_MAP @ CONSTANT map1
		s" T"	map1  =>" SIMPLE"
		s" 16" map1 =>" BITPIX"	
		s" 2"	map1 =>" NAXIS"	
		s" 640" map1 =>" NAXIS1"
		s" 480" map1 =>" NAXIS2"
		s" 2000" map1 =>" FOCUSPOS" 
		s" 23:30:35" map1 =>" TIME-OBS" 
		s" ff11238a23a4" map1 =>" UUID"
	
: test_write-FITSfilepath_buffer ( map buf -- )
	>R drop
	s" e:\coding\ForthXISF\" R@ write-buffer drop
	R@ buffer-punctuate-filepath
	s" FITS_test1.fits" R@ write-buffer drop
	R> drop
;
	ASSIGN test_write-FITSfilepath_buffer TO-DO write-FITSfilepath_buffer	
	
T{ img1 image_size }T 640 480 1 2* * * ==
T{ img1 initialize-FITSimage }T ==
T{ img1 initialize-FITSfilepath }T ==
cr img1 FITS_FILEPATH_BUFFER
	dup buffer-filepath-to-string type CR
	dup buffer-drive-to-string type CR
	dup buffer-dir-to-string type CR
	dup buffer-filename-to-string type CR
	drop
T{ img1 FITS_FILEPATH_BUFFER create-imageDirectory }T ==
T{ img1 save-FITSimage }T ==
T{	img1 free-image }T ==

\ serialize XISF_test1.xisf and the reference file to buffers
	s" %idir%\FITS_test1.fits" r/o open-file drop
	constant fileid1
	fileid1 file-to-buffer
	constant buf1

\	s" %idir%\FITS_test1_reference.fits" r/o open-file drop
\	constant fileid2
\	fileid2 file-to-buffer
\	constant buf2

\ compare XISF_test1.xisf and the reference
\ T{ buf1 buffer-to-string hashS }T buf2 buffer-to-string hashS ==

Tend
