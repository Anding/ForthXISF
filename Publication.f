\ Generic manifest mechanics for replaceable publications.

NEED ForthAstroFormats
NEED ForthAtomicFile

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

: write-manifest-path { filepath-buffer fileid -- }
\ Write a Windows pathname as a JSON-style string value.
    filepath-buffer buffer-to-string bounds ?do
        i c@ '\' = if
            s" \\" fileid write-file abort" Cannot write manifest"
        else
            i 1 fileid write-file abort" Cannot write manifest"
        then
    loop
;

: write-path-manifest-line { fileid key-addr key-u filepath-buffer -- }
\ Write one manifest record containing an authoritative generated filepath.
    key-addr key-u fileid write-file abort" Cannot write manifest"
    s\" : \"" fileid write-file abort" Cannot write manifest"
    filepath-buffer fileid write-manifest-path
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

: save-binary-file
    { frame data-addr data-u filepath-buffer | fileid -- }
\ Save one binary artifact through the active binary filepath policy.
    frame s" .bin" filepath-buffer write-filepath
    filepath-buffer create-imageDirectory
    filepath-buffer buffer-to-string w/o
        create-file abort" Cannot create binary publication" -> fileid
    data-addr data-u fileid write-file abort" Cannot write binary publication"
    fileid close-file abort" Cannot close binary publication"
;

: publish-preview-manifest
    { frame raw-path stretched-path histogram-path preview? histogram?
      manifest-path manifest-tmp-path | fileid -- }
\ Atomically publish the paths of the selected preview artifacts.
    frame s" .dat" manifest-path write-filepath
    frame s" .tmp" manifest-tmp-path write-filepath
    manifest-tmp-path open-publication-file -> fileid
    preview? if
        fileid s" image filepath" raw-path write-path-manifest-line
        fileid s" stretched image filepath" stretched-path
            write-path-manifest-line
    then
    histogram? if
        fileid s" histogram filepath" histogram-path write-path-manifest-line
    then
    fileid s" image name" s" UUID" frame FRAME_METADATA @ >string
        write-manifest-line
    fileid s" time-stamp" s" DATE-END" frame FRAME_METADATA @ >string
        write-manifest-line
    fileid close-file abort" Cannot close manifest"
    manifest-tmp-path manifest-path replace-file-atomically
;

: publish-metadata-manifest
    { frame metadata-path manifest-path manifest-tmp-path | fileid -- }
\ Atomically publish the current FITS-key projection path.
    frame s" .dat" manifest-path write-filepath
    frame s" .tmp" manifest-tmp-path write-filepath
    manifest-tmp-path open-publication-file -> fileid
    fileid s" fits keys filepath" metadata-path write-path-manifest-line
    fileid s" image name" s" UUID" frame FRAME_METADATA @ >string
        write-manifest-line
    fileid s" time-stamp" s" DATE-END" frame FRAME_METADATA @ >string
        write-manifest-line
    fileid close-file abort" Cannot close manifest"
    manifest-tmp-path manifest-path replace-file-atomically
;
