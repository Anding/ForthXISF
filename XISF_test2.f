\ test XISF_filename.f

NEED windows

include "%idir%\XISF.f"

CR

UUIDlength buffer: UUIDstring  
TSlength buffer: TSstring
	
	640 480 1 allocate-image
	CONSTANT img1
	
	map CONSTANT map1
	map1 img1 FITS_MAP !
		TSstring 3 timestamp drop 10	map1 =>" NIGHTOF"
		UUIDString make-UUID 			map1 =>" UUID"		
		s" 2500"								map1 =>" FOCUSPOS"
		s" LUM"								map1 =>" FILTER"		
		s" Light"							map1 =>" IMAGETYP"
		s" Crab_Nebula"					map1 =>" OBJECT"
	map1 .map CR
	img1 initialize-XISFfilepath
	img1 XISF_FILEPATH_BUFFER buffer-to-string type CR

		s" Flat"							map1 =>" IMAGETYP"
		0 0								map1 =>" OBJECT"	
	map1 .map CR
	img1 initialize-XISFfilepath
	img1 XISF_FILEPATH_BUFFER buffer-to-string type CR	

	img1 initialize-FITSfilepath
	img1 FITS_FILEPATH_BUFFER buffer-to-string type CR		

	img1 free-image
	
\ c" %idir%" $ExpandMacros $@ type
\ CR
	
	
	