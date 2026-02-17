need forthXISF
need simple-tester

: test_write-XISFfilepath { map buf -- }
	s" E:\coding\ForthXISF\testdata\" buf write-buffer drop
	buf buffer-punctuate-filepath
	s" clone.xisf" buf write-buffer drop 
;

ASSIGN test_write-XISFfilepath TO-DO write-XISFfilepath

: test.xisf.load-file ( -- )
    s" E:\coding\ForthXISF\testdata\LUM-E155-F5100-f7843758a3f5.xisf" xisf.load-file ( img 0 | IOR )
    if 
        abort" xisf.load-file failed" 
    else 
        save-XISFimage 
    then
;         
 
cr 
Tstart
T{ test.xisf.load-file }T ==
T{ s" E:\coding\ForthXISF\testdata\clone.xisf" hashF }T s" E:\coding\ForthXISF\testdata\LUM-E155-F5100-f7843758a3f5.xisf" hashF ==
Tend

    