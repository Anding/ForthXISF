\ Shared deferred science pathname used by the FITS and XISF codecs.

NEED simple-tester
include "%idir%\ForthAstroFormats_test_support.f"

FILEPATH_SIZE allocate-buffer constant science.test.fits-path
FILEPATH_SIZE allocate-buffer constant science.test.xisf-path
0 value science.test.frame

: science.test-write-filepath { frame filepath-buffer -- }
\ Direct both science formats to one deterministic test stem.
    frame drop
    filepath-buffer reset-buffer
    s" E:\Coding\ForthAstroFormats\testdata\science-path"
        filepath-buffer write-buffer drop
;

ACTION-OF write-science-filepath constant science.test.saved-path
ASSIGN science.test-write-filepath TO-DO write-science-filepath

test.make-frame -> science.test.frame
science.test.frame science.test.xisf-path save-XISFimage
science.test.frame science.test.fits-path save-FITSimage

Tstart
T{ science.test.xisf-path buffer-to-string hashS
}T s" E:\Coding\ForthAstroFormats\testdata\science-path.xisf" hashS ==
T{ science.test.fits-path buffer-to-string hashS
}T s" E:\Coding\ForthAstroFormats\testdata\science-path.fits" hashS ==
T{ science.test.xisf-path buffer-to-string FileExists? }T -1 ==
T{ science.test.fits-path buffer-to-string FileExists? }T -1 ==
Tend

science.test.saved-path TO-DO write-science-filepath
science.test.xisf-path buffer-to-string delete-file drop
science.test.fits-path buffer-to-string delete-file drop
science.test.frame free-frame
