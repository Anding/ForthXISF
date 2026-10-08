NEED ForthAstroFormats
NEED simple-tester

16 8 1 allocate-frame constant test-frame

Tstart

T{ test-frame FRAME_METADATA @ ordered-map? }T -1 ==
T{ test-frame FRAME_STATISTICS @ }T 0 ==

s" first" test-frame FRAME_METADATA @ =>" FIRST"
s" second" test-frame FRAME_METADATA @ =>" SECOND"
T{ test-frame FRAME_METADATA @ count-keys }T 2 ==

test-frame reset-frame-metadata
T{ test-frame FRAME_METADATA @ count-keys }T 0 ==

s" reused" test-frame FRAME_METADATA @ =>" FRESH"
T{ s" FRESH" test-frame FRAME_METADATA @ >string hashS }T
    s" reused" hashS ==

Tend

test-frame free-frame
bye
