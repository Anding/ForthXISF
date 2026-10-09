\ Generic pathname and manifest mechanics for replaceable publications.

NEED ForthAstroFormats
NEED ForthAtomicFile

: append-frame-filepath { frame caddr u filepath-buffer -- }
\ Append a frame UUID generation and filename to a stream root.
    s" UUID" frame FRAME_METADATA @ >string filepath-buffer append-path
    caddr u filepath-buffer append-path
;

: open-publication-file { filepath-buffer | fileid -- fileid }
\ Create the selected publication file and any missing parent directories.
    filepath-buffer create-imageDirectory
    filepath-buffer buffer-to-string w/o
        create-file abort" Cannot create publication file" -> fileid
    fileid
;

: write-manifest-line { fileid key-addr key-u value-addr value-u -- }
\ Write one quoted key/value manifest record.
    key-addr key-u fileid write-file abort" Cannot write manifest"
    s\" : \"" fileid write-file abort" Cannot write manifest"
    value-addr value-u fileid write-file abort" Cannot write manifest"
    s\" \"\r\n" fileid write-file abort" Cannot write manifest"
;

: write-frame-manifest-line { fileid key-addr key-u filename-addr filename-u frame | uuid-addr uuid-u -- }
\ Write one manifest record relative to the frame UUID generation.
    key-addr key-u fileid write-file abort" Cannot write manifest"
    s\" : \"" fileid write-file abort" Cannot write manifest"
    s" UUID" frame FRAME_METADATA @ >string -> uuid-u -> uuid-addr
    uuid-addr uuid-u fileid write-file abort" Cannot write manifest"
    s" \" fileid write-file abort" Cannot write manifest"
    filename-addr filename-u fileid write-file abort" Cannot write manifest"
    s\" \"\r\n" fileid write-file abort" Cannot write manifest"
;

: replace-file-atomically { source-buffer destination-buffer -- }
\ Replace a visible publication only after its temporary file is complete.
    0 source-buffer echo-buffer abort" Publication source path buffer full"
    0 destination-buffer echo-buffer abort" Publication destination path buffer full"
    10 0 do
        source-buffer buffer-to-string drop
        destination-buffer buffer-to-string drop
        ReplaceFileAtomic 0= if unloop exit then
        100 ms
    loop
    abort" Cannot replace publication manifest"
;
