\ FITS write/load round-trip with explicit codec destinations.

NEED simple-tester
include "%idir%\ForthAstroFormats_test_support.f"

FILEPATH_SIZE allocate-buffer constant fits.roundtrip.path
FILEPATH_SIZE allocate-buffer constant fits.clone.path
0 value fits.source
0 value fits.clone

: fits.load-roundtrip { filepath-buffer -- frame }
    filepath-buffer buffer-to-string xisf.load-FITSfile
    if abort" Cannot load FITS round-trip" then
;

test.make-frame -> fits.source
s" roundtrip.fits" fits.roundtrip.path test.prepare-path drop
fits.source fits.roundtrip.path save-FITSimage-to
fits.roundtrip.path fits.load-roundtrip -> fits.clone
s" clone.fits" fits.clone.path test.prepare-path drop
fits.clone fits.clone.path save-FITSimage-to

Tstart
T{ fits.source FRAME_WIDTH @ }T fits.clone FRAME_WIDTH @ ==
T{ fits.source FRAME_HEIGHT @ }T fits.clone FRAME_HEIGHT @ ==
T{ fits.source frame-size }T fits.clone frame-size ==
T{ fits.roundtrip.path buffer-to-string hashF }T fits.clone.path buffer-to-string hashF ==
Tend

fits.source free-frame
fits.clone free-frame
bye
