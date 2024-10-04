\ test XISF_filename.f
include "%idir%\..\ForthBase\ForthBase.f"
include "%idir%\..\ForthBase\windows\windows.f"
include "%idir%\..\ForthBase\FiniteFractions\FiniteFractions.f"
include "%idir%\..\ForthBase\buffers\buffers.f"
include "%idir%\..\forth-map\map.fs"
include "%idir%\..\forth-map\map-tools.fs"
include "%idir%\..\ForthXML\xml.f"
include "%idir%\..\ForthXISF\XISF_maps.f"
include "%idir%\..\ForthXISF\XISF.f"
include "%idir%\..\forth-map\map.fs"
include "%idir%\..\forth-map\map-tools.fs"
include "%idir%\XISF_filename.f"

CR

UUIDlength buffer: UUIDstring  
TSlength buffer: TSstring
	
	640 480 1 allocate-image
	CONSTANT img1
	
	map-strings
	map CONSTANT map1
		TSstring 3 timestamp drop 10	map1 =>" LOCALDAY"
		TSstring 1 timestamp				map1 =>" LOCAL-DT"
		UUIDString make-UUID 			map1 =>" UUID"
	
	CR
	map1 dup .map img1 FITS_MAP !
	CR

	img1 initialize-XISFfilepath
	CR
	img1 FILEPATH_BUFFER buffer-to-string type 
	CR
	
	img1 free-image
	
	c" %idir%" $ExpandMacros $@ type
	CR
	
	
	