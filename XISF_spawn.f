
: frame.allocate-like { frame | new-frame -- new-frame }
\ Allocate an independent frame with matching geometry and new metadata.
    frame FRAME_WIDTH @ frame FRAME_HEIGHT @ frame FRAME_DEPTH @ allocate-frame -> new-frame
    new-frame
;
