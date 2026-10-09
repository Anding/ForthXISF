\ Shared roots and replaceable output-stream pathname policy.

NEED ForthBase

s" E:\images\working" $value astro.working-root
s" E:\images" $value astro.science-root

: append-path { caddr u filepath-buffer -- }
\ Append one backslash-separated component to a prepared pathname.
    '\' filepath-buffer echo-buffer abort" Filepath buffer full"
    caddr u filepath-buffer write-buffer abort" Filepath buffer full"
;

: default-write-preview-root { frame filepath-buffer -- }
\ Build the directory containing replaceable preview generations.
    frame drop
    filepath-buffer reset-buffer
    astro.working-root filepath-buffer write-buffer drop
    s" \preview" filepath-buffer write-buffer drop
;

DEFER write-preview-root ( frame filepath-buffer -- )
ASSIGN default-write-preview-root TO-DO write-preview-root

: default-write-metadata-root { frame filepath-buffer -- }
\ Build the directory containing replaceable metadata generations.
    frame drop
    filepath-buffer reset-buffer
    astro.working-root filepath-buffer write-buffer drop
    s" \metadata" filepath-buffer write-buffer drop
;

DEFER write-metadata-root ( frame filepath-buffer -- )
ASSIGN default-write-metadata-root TO-DO write-metadata-root

: default-write-science-filepath { frame filepath-buffer | map -- }
\ Build a science pathname without its format-specific extension.
    frame FRAME_METADATA @ -> map
    filepath-buffer reset-buffer
    astro.science-root filepath-buffer write-buffer drop
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
;

DEFER write-science-filepath ( frame filepath-buffer -- )
ASSIGN default-write-science-filepath TO-DO write-science-filepath
