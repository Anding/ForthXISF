
\ Frame cloning helper. Pixel storage and metadata are newly owned; callers
\ decide which source pixels or metadata to copy before freeing either frame.

: frame.allocate-like { frame | new-frame -- new-frame }
\ Allocate an independent frame with matching geometry and new metadata.
    frame FRAME_WIDTH @ frame FRAME_HEIGHT @ frame FRAME_DEPTH @ allocate-frame -> new-frame
    new-frame
;
