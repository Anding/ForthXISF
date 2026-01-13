\ Functionality to load XISF files
\ limited to XISF files created in ForthXISF!

NEED ForthXISF


: xisf.open-file ( caddr u -- fileid buf 0 | IOR )
\ open an XISF file and read the XISF header into buf
\ leave the file pointer at the first byte past the header
    r/o open-file ?dup if ." Cannot open XISF file" exit then
    XISF_HEADER_SIZE allocate-buffer    ( fileid buf)
    2dup XISF_HEADER_SIZE rot
    ( fileid buf buf n fileid) buffer-read-file ( fileid buf n2 IOR)
    ?dup if nip nip nip ." Cannot read XISF file" exit then
    XISF_HEADER_SIZE = 0= if nip nip ." Cannot read full XISF buffer" exit then
    0
;

: xisf.scan-for-geometry ( buf -- width height depth )
\ scan a newly opened XISF file and return the XISF geometry
    >R R@ buffer-reset-search
    ( geometry="[^"]*") s\" geometry=\"[^\"]*\"" 
    R> buffer-match ( c-addrM uM -1 | 0)
    0= if ." Failed to find geometry tag" exit then
    10 /string 1-       \ remove geometry=" and the closing "
    >number~~~
;


s" E:\coding\ForthXISF\XISF_test1.xisf" xisf.open-file

    
