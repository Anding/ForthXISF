\ write rig and observation properties to the maps
\ these property sets are known from the system not from any device

need Windows

UUIDlength buffer: xisf.UUIDstring  
TSlength buffer: xisf.TSstring


\ the camera driver does not know - this must be set manually or by script
0 value image_type



: add-observationFITS ( map --)
\ add key value pairs for FITS observation parameters
	>R
	s"  "                                   R@ =>" #OBS"            \ a header to indicate the source of these FITS values	
 	obs.type observationType                R@ =>" IMAGETYP"	
 	obs.type LIGHT = if obs.object else 0 0 then
                                            R@ =>" OBJECT"
	xisf.TSstring 0 make-timestamp          R@ =>" DATE-OBS"        \ UTC date and time in ISO format
	xisf.TSstring 1 make-timestamp          R@ =>" LOCAL-DT"        \ local date and time in ISO format
	xisf.TSstring 3 make-timestamp drop 10  R@ =>" NIGHTOF"         \ local date in midday to midday format
 	obs.observer                            R@ =>" OBSERVER"			
 	xisf.UUIDString make-UUID               R@ =>" UUID"											
	R> drop
;	

: add-rigFITS ( map --)
\ add key value pairs for FITS rig parameters
	>R
	s"  "                                   R@ =>" #RIG"            \ a header to indicate the source of these FITS values	
	rig.telescope                           R@ =>" TELESCOP"
	rig.focal_len                           R@ =>" FOCALLEN"	
	rig.focal_ratio                         R@ =>" FOCRATIO"	
	rig.aperature_dia                       R@ =>" APTDIA"			
	rig.aperature_area                      R@ =>" APTAREA"
	rig.software                            R@ =>" SWCREATE"		
	R> drop
;	


