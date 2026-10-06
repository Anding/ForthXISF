\ Ordered UTF-8 projection of a FITS map for metadata viewers and WCS sidecars.

16384 constant FITS_PROJECTION_SIZE

: XISF.mapIterProjection { buf key-addr key-u map -- buf }
    key-addr key-u buf write-buffer abort" FITS projection buffer full"
    9 buf echo-buffer abort" FITS projection buffer full"
    key-addr key-u map >string buf write-buffer abort" FITS projection buffer full"
    13 buf echo-buffer abort" FITS projection buffer full"
    10 buf echo-buffer abort" FITS projection buffer full"
    buf
;

: save-FITSprojection { img filepath-buffer | fileid projection-buffer -- }
    filepath-buffer create-imageDirectory
    filepath-buffer buffer-to-string w/o
        create-file abort" Cannot create FITS projection" -> fileid
    FITS_PROJECTION_SIZE allocate-buffer -> projection-buffer
    projection-buffer ['] XISF.mapIterProjection img FITS_MAP @ simple-iterate-map drop
    projection-buffer fileid buffer-to-file
    projection-buffer free-buffer
    fileid close-file abort" Cannot close FITS projection"
;

: replace-file-atomically { source-buffer destination-buffer -- }
    0 source-buffer echo-buffer abort" Publication source path buffer full"
    0 destination-buffer echo-buffer abort" Publication destination path buffer full"
    source-buffer buffer-to-string drop
    destination-buffer buffer-to-string drop
    ReplaceFileAtomic abort" Cannot replace publication manifest"
;
