\ simple xml writer

: xml.intro ( -- c-addr u )
	s\" <?xml version=\"1.0\" encoding=\"UTF-8\"?>
\ 	s\" <xisf version=\"1.0\">"		XISF.WriteToHeader
;

: xml.open-tag ( c-addr u buf --)
;

: 
	
	
	
	
\ call this after XISF.StartXML
	s\" <Image geometry=\""				XISF.WriteToHeader
	ImageWidth @ dup						XISF.WriteIntToHeader	\ width
	s\" :"									XISF.WriteToHeader
	ImageHeight @ dup						XISF.WriteIntToHeader	\ height
	s\" :1\" sampleFormat=\"UInt16\" colorSpace=\"Gray\" location=\"attachment:"	XISF.WriteToHeader
	0 XISF_DATA ( ... offset)			XISF.WriteIntToHeader	\ location
	s\" :"									XISF.WriteToHeader
	( width height) 2 * * dup 			XISF.WriteIntToHeader	\ size in bytes of the image buffer
	s\" \">"									XISF.WriteToHeader
	( dataSize) 0 XISF_DATA + XISFBufferSize !					\ update the buffer size to match the image size
;