NEED ForthAstroPaths
NEED simple-tester

FILEPATH_SIZE allocate-buffer constant paths.test.filepath

Tstart

T{ astro.working-root hashS }T s" E:\images\working" hashS ==
T{ astro.science-root hashS }T s" E:\images" hashS ==

s" E:\test-working" $-> astro.working-root
s" E:\test-science" $-> astro.science-root

T{ astro.working-root hashS }T s" E:\test-working" hashS ==
T{ astro.science-root hashS }T s" E:\test-science" hashS ==

1 1 1 allocate-frame constant paths.test.frame
s" 11111111-2222-3333-4444-555555555555"
    paths.test.frame FRAME_METADATA @ =>" UUID"
s" 2026-10-09" paths.test.frame FRAME_METADATA @ =>" NIGHTOF"
s" Dark" paths.test.frame FRAME_METADATA @ =>" IMAGETYP"
s" LUM" paths.test.frame FRAME_METADATA @ =>" FILTER"
s" 5" paths.test.frame FRAME_METADATA @ =>" EXPTIME"
s" 5100" paths.test.frame FRAME_METADATA @ =>" FOCUSPOS"

T{ paths.test.frame paths.test.filepath write-preview-root
   paths.test.filepath buffer-to-string hashS
}T s" E:\test-working\preview" hashS ==

T{ paths.test.frame paths.test.filepath write-metadata-root
   paths.test.filepath buffer-to-string hashS
}T s" E:\test-working\metadata" hashS ==

T{ paths.test.frame paths.test.filepath write-science-filepath
   paths.test.filepath buffer-to-string hashS
}T s" E:\test-science\2026-10-09\Dark\LUM-E5-F5100-555555555555" hashS ==

paths.test.frame free-frame

Tend
