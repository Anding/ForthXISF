\ test for XML.f

include "%idir%\buffers.f"
include "%idir%\XML.f"
include "%idir%\..\simple-tester\simple-tester.f"
	CR
	
	\ create a new buffer
	1024 allocate-buffer
	constant buf1 

	\ write some XML
	\ example from https://pixinsight.com/doc/docs/XISF-1.0-spec/XISF-1.0-spec.html
: test1 ( buf --)
	>R
	R@ xml.<??>
	
	s" Created with ForthXISF" R@ xml.comment
	
	s" xisf" R@ xml.<tag 
		s" version" s" 1.0" R@ xml.keyval
	R@ xml.>
	
		s" Image" R@ xml.<tag
			s" geometry" s" 6:6:3" R@ xml.keyval
			s" sampleFormat" s" UInt8" R@ xml.keyval
			s" colorSpace" s" RGB" R@ xml.keyval
			s" location" s" embedded" R@ xml.keyval
		R@ xml.>
		
				s" Data" R@ xml.<tag
					s" encoding" s" base64" R@ xml.keyval
				R@ xml.>
					s" AAAAAP8A/wD/AAAAAAAAAP8AAP8AAAAAAAAA/wD/AP8AAAAA/wD//wD/AP8AAP8A/wD//wD//wD//wD/AP8AAP8A/wD//wD/AP8AAAAAAAAA/wD/AP8AAAAAAAAAAP8A/wD/AAAAAAAAAP8A" R@ xml.write
				s" Data" R@ xml.</tag>
				
				s" Property" R@ xml.<tag
					s" id" s" Observation:Center:RA" R@ xml.keyval
					s" type" s" Float64" R@ xml.keyval
					s" value" s" 195.4998" R@ xml.keyval
				R@ xml./>
				
		s" Image" R@ xml.</tag>
		
	s" xisf" R@ xml.</tag>
	R> drop
;
	buf1 test1
	
	\ save the XML to a file
	s" %idir%\XML_test1.xml" r/w create-file drop
	constant test_fileid1
	buf1 test_fileid1 buffer-to-file 
	test_fileid1 close-file drop	
	
	\ open the reference XML file
	s" %idir%\XML_test1_reference.xml" r/o open-file drop
	constant test_fileid2
	test_fileid2 file-to-buffer
	constant buf2
	test_fileid2 close-file drop
	
	\ compare the buffers
Tstart
	T{ buf1 buffer-to-string hashS }T buf2 buffer-to-string hashS ==

Tend

