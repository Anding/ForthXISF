\ serialize FITS and XISF forth-map structure
\ requires forth-map/map.fs, forth-map/map-tools.fs 

: XISF.FITSmapIter ( buf c-addr u map -- buf)
\ forth-map iterator
\ output format: <FITSKeyword name="FOCUSPOS" value="2000" />
	>R rot R> swap >R									( c-addr u map R:buf)
	s" FITSKeyword" R@ xml.<tag	
	-rot 2dup s" name" 2swap R@ xml.keyval 	( c-addr u map R:buf)
	rot >string				      					( c-addr u R:buf)		
	s" value" 2swap R@ xml.keyval					( R:buf)
	R@ xml./>
	R>
;

: XISF.write-FITSmap ( map buf --)
\ write out the FITS map as a series of XML structures
\ <FITSKeyword name="FOCUSPOS" value="2000" />
	['] XISF.FITSmapIter rot ( buf xt map) simple-iterate-map
	drop
;

: XISF.XISFmapIter { buf c-addr u map -- buf } 	\ VFX locals
\ forth-map iterator
\ outputformat: sampleFormat="UInt16"
	c-addr u 2dup map >string buf xml.keyval 		( c-addr u map R:buf)
	buf
;

: XISF.write-XISFmap ( map buf --)
\ write out the XISF map into the image XML tag
\ sampleFormat="UInt16"
	['] XISF.XISFmapIter rot ( buf xt map) simple-iterate-map
	drop
;