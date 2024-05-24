\ simple xml writer
\ requires buffers.f

: xml.write ( c-addr u buf --)
	write-buffer ABORT" XML buffer full"
;

: xml.echo ( c buf --)
	echo-buffer ABORT" XML buffer full"
;	

: xml.<??> ( buf -- )
\ write the full XML prolog tag and newline (Windows format)
	s\" <?xml version=\"1.0\" encoding=\"UTF-8\"?>\r\n" rot xml.write
;

: xml.<tag ( c-addr u buf --)
\ open an XML start-tag or empty-element-tag
	>R
	'<' R@ xml.echo
	R> xml.write
;

: xml.> ( buf --)
\ close an XML start-tag and newline (Windows format)
	s\" >\r\n" rot xml.write
;

: xml./> ( buf --)
\ close an XML empty-element tag and newline (Windows format)
	s\"  />\r\n" rot xml.write
;

: xml.</tag> ( c-addr u buf --)
\ write an XML end-tag and newline (Windows format)
	>R
	s" </" R@ xml.write
	R@ xml.write
	s\" >\r\n" R> xml.write
;

: xml.keyval ( c-addr1 u1 c-addr2 u2 buf --)
\ write a key (c-addr1 u1) value (c-addr2 u2) pair
	>R										( c1 u1 c2 u2 R:b)
	BL R@ xml.echo						( c1 u1 c2 u2 R:b)		\ ' ' is not a space!
	2swap R@ xml.write				( c2 u2 R:b)
	s\" =\"" R@ xml.write			( c2 u2 R:b)
	R@ xml.write						( R:b)
	'"' R> xml.echo					( )
;

: xml.append ( c-addr u buf --)
\ append a strng to the value just written and reclose
	>R
	R@ backspace-buffer ABORT" XML buffer empty"
	R@ xml.write
	'"' R> xml.echo
;

: xml.comment ( c-addr u buf --)
\ write an XML comment
	>R
	s" <!-- " R@ xml.write
	R@ xml.write
	s\"  -->\r\n" R> xml.write
;
	