4032 constant XISFHeaderMaxLen
640 480 2 * * constant XISFDataMaxLen

BEGIN-STRUCTURE XISF_BUFFER
	8 +FIELD XISF_SIGNATURE
	4 +FIELD XISF_HEADER_LEN
	4 +FIELD XISF_RESERVED
	XISFHeaderMaxLen	+FIELD XISF_HEADER		\ header with trailing zeros
	XISFDataMaxLen		+FIELD XISF_DATA 			\ data with trailing zeros
END-STRUCTURE

variable XISFHeaderPointer
	
: XISF.StartHeader ( buff -- )
	0 XISFHeaderLength !
	XISF_Header XISFHeaderPointer !
;

: XISF.HeaderLength ( -- n )
	XISFHeaderPointer @ XISFBuffer XISF_Header -
;
	
: XISF.WriteToHeader ( addr n -- )
	dup >R
	XISFHeaderPointer @ swap cmove
	R> XISFHeaderPointer +!
;
	
: XISF.FinishHeader ( buff -- )
	s" XISF0100" ( buff addr n) -rot swap ( addr buffer n ) cmove
	XISF.HeaderLength XISFBuffer XISF_HEADER_LEN l!
;

: XISF.StartXML ( -- )
	s\" <xisf version=\"1.0\">"		XISF.WriteToHeader
;

: XISF.FinishXML
	s\" </xisf>"							XISF.WriteToHeader
;

: XISF.StartImage
	s\"<Image geometry=\""				XISF.WriteToHeader
	( width)
	s\" :"									XISF.WriteToHeader
	( height)
	s\" :"									XISF.WriteToHeader
	s\" \" sampleFormat=\"UInt16\" colorSpace=\"Gray\" location=\"attachment:\"	XISF.WriteToHeader
	( location)
	( length)
	s\" \">"									XISF.WriteToHeader
;

: XISF.FinishImage
	s\" </Image>"							XISF.WriteToHeader
;

: XISF.MAKE-FITSKEY-INT ( addr caddr u  <name> -- ) 
\ defining word for a FITS key with integer value
\ e.g. variable-name S" FITS-keyword" XISF.MAKE-FITSKEY-INT <name>
	CREATE 
		, $,
	DOES> ( --)
		dup >R @		( value)
		R> count		( value caddr u)
		s\" <FITSKeyword name=\""		XISF.WriteToHeader
		( value caddr u) 					XISF.WriteToHeader
		s\" \" value =\" "				XISF.WriteToHeader
		( value) <# dup SIGN 0 (value-as-double) #S #> ( caddr u)	XSIF.WriteToHeader
		s\" \" />\""						XISF.WriteToHeader
;

XISF_BUFFER BUFFER: XISFBuffer

XISFBuffer XISF.StartHeader
XISF.StartXML
XISF.FinishXML
XISFBuffer XISF.FinishHeader

XISFBuffer 64 dump
