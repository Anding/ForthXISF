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
XISF_BUFFER BUFFER: XISFBuffer
	
: XISF.StartHeader ( -- )
	0 XISFHeaderLength !
	XISFBuffer XISF_Header XISFHeaderPointer !
;

: XISF.HeaderLength ( -- n )
	XISFHeaderPointer @ XISFBuffer XISF_Header -
;
	
: XISF.WriteToHeader ( addr n -- )
	dup >R
	XISFHeaderPointer @ swap cmove
	R> XISFHeaderPointer +!
;
	
: XISF.FinishHeader ( -- )
	s" XISF0100" ( addr n) XISFBuffer swap ( addr buffer n ) cmove
	XISF.HeaderLength XISFBuffer XISF_HEADER_LEN l!
;

: XISF.StartXML ( -- )
	s\" <xisf version=\"1.0\"> "
	XISF.WriteToHeader
;

: XISF.FinishXML
	s\" </xisf> "
	XISF.WriteToHeader
;

XISF.StartHeader
XISF.StartXML
XISF.FinishXML
XISF.FinishHeader

XISFBuffer 64 dump
