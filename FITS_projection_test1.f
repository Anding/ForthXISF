\ Regression coverage for ordered FITS-map projection and atomic publication.

need ForthXISF
need FITS_projection
need simple-tester

256 allocate-buffer constant projection.path
256 allocate-buffer constant publication.source
256 allocate-buffer constant publication.destination
256 allocate-buffer constant projection.expected

: test.write-file { caddr u filepath-buffer | fileid -- }
    filepath-buffer create-imageDirectory
    filepath-buffer buffer-to-string w/o
        create-file abort" Cannot create test file" -> fileid
    caddr u fileid write-file abort" Cannot write test file"
    fileid close-file abort" Cannot close test file"
;

: test.file-hash { filepath-buffer | fileid buffer -- }
    filepath-buffer buffer-to-string r/o
        open-file abort" Cannot open test file" -> fileid
    fileid file-to-buffer -> buffer
    buffer buffer-to-string hashS
    buffer free-buffer
;

s" E:\images\tests\forthxisf\projection.dat" projection.path write-buffer drop
s" E:\images\tests\forthxisf\publication.tmp" publication.source write-buffer drop
s" E:\images\tests\forthxisf\publication.dat" publication.destination write-buffer drop
s" FIRST" projection.expected write-buffer drop
9 projection.expected echo-buffer drop
s" first" projection.expected write-buffer drop
13 projection.expected echo-buffer drop
10 projection.expected echo-buffer drop
s" SECOND" projection.expected write-buffer drop
9 projection.expected echo-buffer drop
s" second" projection.expected write-buffer drop
13 projection.expected echo-buffer drop
10 projection.expected echo-buffer drop

4 3 1 allocate-image constant projection.image
s" first" projection.image FITS_MAP @ =>" FIRST"
s" second" projection.image FITS_MAP @ =>" SECOND"

4 3 1 allocate-image constant filename.image
s" 2026-10-06" filename.image FITS_MAP @ =>" NIGHTOF"
s" Light" filename.image FITS_MAP @ =>" IMAGETYP"
s" LUM" filename.image FITS_MAP @ =>" FILTER"
s" 5" filename.image FITS_MAP @ =>" EXPTIME"
0 0 filename.image FITS_MAP @ =>" FOCUSPOS"
s" 01234567-89ab-cdef-0123-456789abcdef" filename.image FITS_MAP @ =>" UUID"

Tstart

T{ projection.image projection.path save-FITSprojection }T ==
T{ projection.path test.file-hash }T projection.expected buffer-to-string hashS ==

s" old" publication.destination test.write-file
s" published" publication.source test.write-file
T{ publication.source publication.destination replace-file-atomically }T ==
T{ publication.destination test.file-hash }T s" published" hashS ==
T{ publication.source buffer-to-string FileExists? }T 0 ==

T{ filename.image initialize-XISFfilepath
   filename.image XISF_FILEPATH_BUFFER buffer-filename-to-string hashS
}T s" LUM-E5-F-456789abcdef.xisf" hashS ==
T{ filename.image initialize-FITSfilepath
   filename.image FITS_FILEPATH_BUFFER buffer-filename-to-string hashS
}T s" LUM-E5-F-456789abcdef.fits" hashS ==

Tend

projection.image free-image
filename.image free-image
projection.path free-buffer
publication.source free-buffer
publication.destination free-buffer
projection.expected free-buffer
bye
