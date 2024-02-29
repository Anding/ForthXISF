\ test for buffers.f

include "%idir%\buffers.f"
include "%idir%\..\simple-tester\simple-tester.f"

1024 BUFFER_DESCRIPTOR +

allocate drop constant buf1

1024 buf1 BUFFER_SIZE !
buf1 reset-buffer

CR
Tstart

T{ buf1 buffer_used }T 0 ==
T{ buf1 buffer_free }T 1024 ==

T{ s" 01234567" buf1 write-buffer }T 8 ==
T{ buf1 buffer_used }T 8 ==
T{ buf1 buffer_free }T 1016 ==

T{ s" ABCD01234567EFGH" buf1 write-buffer }T 16 ==
T{ buf1 buffer_used }T 24 ==
T{ buf1 buffer_free }T 1000 ==
Tend

buf1 BUFFER_ADDR 24 dump
