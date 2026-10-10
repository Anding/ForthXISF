\ Shared plate-solver contract and solver-independent metadata operations.

NEED ForthAstroFormats
NEED AstroCalc

256 buffer: solver.wcs-line
s" " $value solver.alignment-command

: no-solver { img -- failed? }
    s" FAILED" img FRAME_METADATA @ =>" SOLVSTAT"
    -1
;

DEFER solve-image ( img -- failed? )
ASSIGN no-solver TO-DO solve-image

: solver.import-WCS { caddr u img | metadata fileid -- }
\ Merge ordinary WCS FITS cards into the frame's ordered metadata.
    img FRAME_METADATA @ -> metadata
    caddr u r/o open-file abort" Cannot open solver WCS file" -> fileid
    begin
        solver.wcs-line 255 fileid read-line
            abort" Cannot read solver WCS file"
    while
        solver.wcs-line swap FITS.read-line
        dup 0= if
            drop metadata =>
        else
            drop
        then
    repeat
    drop
    fileid close-file abort" Cannot close solver WCS file"
;

: solver.~Dec$ ( deg-min-sec -- caddr u )
    ':' ':' -1 ~custom$
;

: solver.~RA$ ( hr-min-sec -- caddr u )
    ':' ':' 0 ~custom$
    s" HH:MM:SS.0" drop dup >R
    swap move R> 10
;

: solver.alignment-FITS { metadata |
    reported-ra reported-dec sidereal night-of
    solved-ra solved-dec pierside-addr pierside-u -- }
\ Derive the 10Micron alignment command once from the completed solve context.
    s" OBJCTRA" metadata >string >number~ -> reported-ra
    s" OBJCTDEC" metadata >string >number~ -> reported-dec
    s" SIDEREAL" metadata >string >number~ -> sidereal
    s" NIGHTOF" metadata >string >number~ -> night-of
    s" PIERSIDE" metadata >string -> pierside-u -> pierside-addr
    s" CRVAL1" metadata >string >float drop 1.5E1 f/ fp~ -> solved-ra
    s" CRVAL2" metadata >string >float drop fp~ -> solved-dec

    s\" s\" " $-> solver.alignment-command
    reported-ra reported-dec night-of JNOW swap
    solver.~RA$ $+> solver.alignment-command
    s" ," $+> solver.alignment-command
    solver.~Dec$ $+> solver.alignment-command
    s" ," $+> solver.alignment-command
    pierside-addr pierside-u 0> if 1 else 0 then
        $+> solver.alignment-command
    s" ," $+> solver.alignment-command
    solved-ra solved-dec night-of JNOW swap
    solver.~RA$ $+> solver.alignment-command
    s" ," $+> solver.alignment-command
    solver.~Dec$ $+> solver.alignment-command
    s" ," $+> solver.alignment-command
    sidereal solver.~RA$ $+> solver.alignment-command
    s\" \" add-alignment-point" $+> solver.alignment-command
    solver.alignment-command metadata =>" 10UALPT"
;
