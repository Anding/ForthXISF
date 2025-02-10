\ write rig and observation properties to the maps
\ these property sets are known from the system not from any device

UUIDlength buffer: UUIDstring  
TSlength buffer: TSstring


\ the camera driver does not know - this must be set manually or by script
0 value image_type

: add-observationFITS ( map --)
\ add key value pairs for FITS observation parameters
	>R
	s"  " 							R@ =>" #OBS"			\ a header to indicate the source of these FITS values	
 	obs.type observationType	R@ =>" IMAGETYP"	
 	obs.type LIGHT = if	
 		obs.object					R@ =>" OBJECT"
 	then
	TSstring 0 timestamp			R@ =>" DATE-OBS"		\ UTC date and time in ISO format
	TSstring 1 timestamp			R@ =>" LOCAL-DT"		\ local date and time in ISO format
	TSstring 3 timestamp drop 10	R@ =>" NIGHTOF"	\ local date in midday to midday format
 	obs.observer					R@ =>" OBSERVER"			
 	UUIDString make-UUID 		R@ =>" UUID"			\ generated UUID									
	R> drop
;	

: add-rigFITS ( map --)
\ add key value pairs for FITS rig parameters
	>R
	s"  " 							R@ =>" #RIG"			\ a header to indicate the source of these FITS values	
	rig.telescope					R@ =>" TELESCOP"
	rig.focal_len (.)				R@ =>" FOCALLEN"		
	rig.aperature_dia (.)		R@ =>" APTDIA"			
	rig.aperature_area (.)		R@ =>" APTAREA"
	rig.software					R@ =>" SWCREATE"		
	R> drop
;	

: add-observationXISF ( map --)
\ add key value pairs for XISF camera parameters
	>R
 	obs.type observationType	R@	=>" IMAGETYPE"
   UUIDString zcount				R@ =>" UUID"				\ requires that add-observationFITS has been called first
	R> drop
;

CR ." finished importing XISF_maps.f" CR