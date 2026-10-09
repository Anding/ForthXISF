\ Replaceable output-stream pathname policy.

NEED ForthBase

s" E:\images" $value astro.root

: append-path { caddr u filepath-buffer -- }
\ Append one backslash-separated component to a prepared pathname.
    '\' filepath-buffer echo-buffer abort" Filepath buffer full"
    caddr u filepath-buffer write-buffer abort" Filepath buffer full"
;

: default-write-generation-filepath
    { frame stream-addr stream-u filename-addr filename-u
      suffix-addr suffix-u filepath-buffer -- }
\ Build one complete UUID-versioned working filepath.
    filepath-buffer reset-buffer
    astro.root filepath-buffer write-buffer drop
    s" working" filepath-buffer append-path
    stream-addr stream-u filepath-buffer append-path
    s" UUID" frame FRAME_METADATA @ >string filepath-buffer append-path
    filename-addr filename-u filepath-buffer append-path
    suffix-addr suffix-u filepath-buffer write-buffer
        abort" Filepath buffer full"
;

: default-write-manifest-filepath
    { frame stream-addr stream-u filename-addr filename-u
      suffix-addr suffix-u filepath-buffer -- }
\ Build one complete working-stream manifest filepath.
    frame drop
    filepath-buffer reset-buffer
    astro.root filepath-buffer write-buffer drop
    s" working" filepath-buffer append-path
    stream-addr stream-u filepath-buffer append-path
    filename-addr filename-u filepath-buffer append-path
    suffix-addr suffix-u filepath-buffer write-buffer
        abort" Filepath buffer full"
;

: default-write-preview-image-filepath
    { frame suffix-addr suffix-u filepath-buffer -- }
\ Build the raw-preview pathname with the writer's suffix.
    frame s" preview" s" image" suffix-addr suffix-u filepath-buffer
        default-write-generation-filepath
;

DEFER write-preview-image-filepath ( frame caddr u filepath-buffer -- )
ASSIGN default-write-preview-image-filepath
    TO-DO write-preview-image-filepath

: default-write-preview-stretched-filepath
    { frame suffix-addr suffix-u filepath-buffer -- }
\ Build the stretched-preview pathname with the writer's suffix.
    frame s" preview" s" stretched" suffix-addr suffix-u filepath-buffer
        default-write-generation-filepath
;

DEFER write-preview-stretched-filepath ( frame caddr u filepath-buffer -- )
ASSIGN default-write-preview-stretched-filepath
    TO-DO write-preview-stretched-filepath

: default-write-preview-histogram-filepath
    { frame suffix-addr suffix-u filepath-buffer -- }
\ Build the preview-histogram pathname with the writer's suffix.
    frame s" preview" s" histogram" suffix-addr suffix-u filepath-buffer
        default-write-generation-filepath
;

DEFER write-preview-histogram-filepath ( frame caddr u filepath-buffer -- )
ASSIGN default-write-preview-histogram-filepath
    TO-DO write-preview-histogram-filepath

: default-write-preview-manifest-filepath
    { frame suffix-addr suffix-u filepath-buffer -- }
\ Build the preview-manifest filepath with the requested publication suffix.
    frame s" preview" s" latest" suffix-addr suffix-u filepath-buffer
        default-write-manifest-filepath
;

DEFER write-preview-manifest-filepath ( frame caddr u filepath-buffer -- )
ASSIGN default-write-preview-manifest-filepath
    TO-DO write-preview-manifest-filepath

: default-write-metadata-filepath
    { frame suffix-addr suffix-u filepath-buffer -- }
\ Build the FITS-key projection pathname with the writer's suffix.
    frame s" metadata" s" fits" suffix-addr suffix-u filepath-buffer
        default-write-generation-filepath
;

DEFER write-metadata-filepath ( frame caddr u filepath-buffer -- )
ASSIGN default-write-metadata-filepath TO-DO write-metadata-filepath

: default-write-metadata-manifest-filepath
    { frame suffix-addr suffix-u filepath-buffer -- }
\ Build the metadata-manifest filepath with the requested publication suffix.
    frame s" metadata" s" latest" suffix-addr suffix-u filepath-buffer
        default-write-manifest-filepath
;

DEFER write-metadata-manifest-filepath ( frame caddr u filepath-buffer -- )
ASSIGN default-write-metadata-manifest-filepath
    TO-DO write-metadata-manifest-filepath

: default-write-science-filepath
    { frame suffix-addr suffix-u filepath-buffer | map -- }
\ Build one complete science filepath with the requested format suffix.
    frame FRAME_METADATA @ -> map
    filepath-buffer reset-buffer
    astro.root filepath-buffer write-buffer drop
    s" NIGHTOF" map >string filepath-buffer append-path
    s" IMAGETYP" map >string filepath-buffer append-path
    '\' filepath-buffer echo-buffer drop
    filepath-buffer buffer-punctuate-filepath
    s" FILTER" map >string filepath-buffer write-buffer drop
    '-' filepath-buffer echo-buffer drop
    'E' filepath-buffer echo-buffer drop
    s" EXPTIME" map >string filepath-buffer write-buffer drop
    '-' filepath-buffer echo-buffer drop
    'F' filepath-buffer echo-buffer drop
    s" FOCUSPOS" map >string filepath-buffer write-buffer drop
    '-' filepath-buffer echo-buffer drop
    s" UUID" map >string drop 24 + 12 filepath-buffer write-buffer drop
    suffix-addr suffix-u filepath-buffer write-buffer
        abort" Science filepath buffer full"
;

DEFER write-science-filepath ( frame caddr u filepath-buffer -- )
ASSIGN default-write-science-filepath TO-DO write-science-filepath

DEFER write-filepath ( frame caddr u filepath-buffer -- )
ASSIGN default-write-science-filepath TO-DO write-filepath
