\ test for XML.f with forth-maps

include "%idir%\buffers.f"
include "%idir%\XML.f"
include "%idir%\..\forth-map\map.fs"
include "%idir%\..\forth-map\map-tools.fs"
include "%idir%\..\simple-tester\simple-tester.f"
	CR
	
	\ create maps of properties and values
	
	map CONSTANT XISFattribute
	s" Observation:Center:RA" XISFattribute >value -1 swap !
	s" Observation:Center:Dec" XISFattribute >value -1 swap !
	s" Observation:StartTime" XISFattribute >value -1 swap !
	s" Observation:Location:Name" XISFattribute >value 0 swap !

	128 -> map.space
	
	map CONSTANT XISFtypes
	s" Observation:Center:RA" XISFtypes >value s" Float64" rot place
	s" Observation:Center:Dec" XISFtypes >value s" Float64" rot place
	s" Observation:StartTime" XISFtypes >value s" TimePoint" rot place
	s" Observation:Location:Name" XISFtypes >value s" String" rot place

	
	map CONSTANT XISFimage
	s" Observation:Center:RA" XISFimage >value s" 195.4997911" rot place
	s" Observation:Center:Dec" XISFimage >value s" 47.2661464" rot place
	s" Observation:StartTime" XISFimage >value s" '2024-03-15T02:55:15'" rot place
	s" Observation:Location:Name" XISFimage >value s" Observatorio de Aras de los Olmos (OAO)" rot place
	
	
	: xml-iterator ( buf c-addr u map -- buf)
		drop rot >R					\ our maps are global variables
		s" Property" R@ xml.<tag
			2dup s" id" 2swap R@ xml.keyval
			2dup XISFtypes >value count s" type" 2swap R@ xml.keyval			
				2dup XISFattribute >value @ IF				
					XISFimage >value count s" value" 2swap R@ xml.keyval
					R@ xml./>
				ELSE
					R@ xml.>
					XISFimage >value count R@ xml.write
					s" Property" R@ xml.</tag>
				THEN
		R>
	;
	
	\ create a new buffer
	1024 allocate-buffer
	constant buf1 

	buf1 ' xml-iterator XISFimage simple-iterate-map drop
	
	\ save the XML to a file
	s" %idir%\XML_test2.xml" r/w create-file drop
	constant test_fileid1
	buf1 test_fileid1 buffer-to-file 
	test_fileid1 close-file drop	
	
	\ open the reference XML file
	s" %idir%\XML_test2_reference.xml" r/o open-file drop
	constant test_fileid2
	test_fileid2 file-to-buffer
	constant buf2
	test_fileid2 close-file drop
	
	\ compare the buffers
 Tstart
	T{ buf1 buffer-to-string hashS }T buf2 buffer-to-string hashS ==

 Tend