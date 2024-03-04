\ simple xml writer
\ requires buffers.f

: xml.write ( c-addr u buff --)
	write-buffer abort" XML buffer full"
;

: xml.echo ( c buff --)
	echo-buffer abort" XML buffer full"
;	

: xml.<??> ( buff -- )
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
	s"</ " R@ xml.write
	R@ xml.write
	s\" >\r\n" R> xml.write
;

: xml.key=val ( c-addr1 u1 c-addr2 u2 buf --)
\ write a key (c-addr1 u1) value (c-addr2 u2) pair
	>R
	' ' R@ xml.echo
	2swap R@ xml.write
	s\"=\"" R@ xml.write
	R@ xml.write
	'"' R> xml.echo
;
	