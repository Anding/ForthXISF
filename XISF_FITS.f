\ serialize a forth-map structure as FITS keywords
\ requires forth-map/map.fs, forth-map/map-tools.fs 

: XISF.iter ( buf c-addr u map -- buf)
\ forth-map iterator
\ write out a forth-map to a buffer in xml empty-tag format
\ <Property key="key" value="value"/>
	>R rot R> swap >R								( c-addr u map R:buf)
	s" FITSKeyword" R@ xml.<tag	
	-rot 2dup s" name" 2swap R@ xml.keyval 	( c-addr u map R:buf)
	rot >string				      				( c-addr u R:buf)		
	s" value" 2swap R@ xml.keyval				( R:buf)
	R@ xml./>
	R>
;

: XISF.write-map ( map buf --)
\ write out a forth-map to a buffer in xml empty-tag format
\ <Property key="key" value="value"/>
\ the map values are counted strings
	['] XISF.iter rot ( buf xt map) simple-iterate-map
	drop
;