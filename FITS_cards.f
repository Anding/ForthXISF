\ FITS card parsing shared by FITS readers and plate solvers.

: FITS.read-line ( caddr u -- caddr1 u1 caddr2 u2 0 | flag )
\ Return key/value/0 for an ordinary card, 1 for END, 2 for SIMPLE, and 3 for
\ an unrecognized non-assignment card. Callers use flags to control scanning.
    over 8 -white 2dup hash$ case
        [ s" END" hash$ ] literal of 2drop 2drop 1 endof
        [ s" SIMPLE" hash$ ] literal of 2drop 2drop 2 endof
        drop over 8 + c@
        '=' of
            2>R
            10 /string -white FITSstrToStr
            2R> 0
        endof
        >R 2drop 2drop 3 R>
    endcase
;
