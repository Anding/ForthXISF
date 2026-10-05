\ Ordered UTF-8 projection of a FITS map for metadata viewers and WCS sidecars.

: XISF.mapIterProjection { fileid caddr u map -- fileid }
    caddr u fileid write-file abort" Cannot write FITS projection"
    9 fileid emit-file abort" Cannot write FITS projection"
    caddr u map >string fileid write-file abort" Cannot write FITS projection"
    13 fileid emit-file abort" Cannot write FITS projection"
    10 fileid emit-file abort" Cannot write FITS projection"
    fileid
;

: save-FITSprojection { img filepath-buffer | fileid -- }
    filepath-buffer create-imageDirectory
    filepath-buffer buffer-to-string w/o
        create-file abort" Cannot create FITS projection" -> fileid
    fileid ['] XISF.mapIterProjection img FITS_MAP @ simple-iterate-map drop
    fileid close-file abort" Cannot close FITS projection"
;

: replace-file-atomically { source-buffer destination-buffer -- }
    0 source-buffer echo-buffer abort" Publication source path buffer full"
    0 destination-buffer echo-buffer abort" Publication destination path buffer full"
    source-buffer buffer-to-string drop
    destination-buffer buffer-to-string drop
    ReplaceFileAtomic abort" Cannot replace publication manifest"
;
