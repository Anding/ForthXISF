\ test for buffers.f

include "%idir%\buffers.f"
include "%idir%\..\simple-tester\simple-tester.f"

1024 allocate-buffer constant buf1

CR
Tstart

T{ buf1 buffer_used }T 0 ==
T{ buf1 buffer_space }T 1024 ==

T{ s" 01234567" buf1 write-buffer }T 0 ==
T{ buf1 buffer_used }T 8 ==
T{ buf1 buffer_space }T 1016 ==

T{ s" ABCD01234567EFGH" buf1 write-buffer }T 0 ==
T{ buf1 buffer_used }T 24 ==
T{ buf1 buffer_space }T 1000 ==

T{ 'X' buf1 echo-buffer }T 0 ==
T{ buf1 buffer_used }T 25 ==
T{ buf1 buffer_space }T 999 ==

\ bounds check enforced?
T{ s" ABC" drop 1000 buf1 write-buffer }T -1 ==
T{ buf1 buffer_used }T 25 ==
T{ buf1 buffer_space }T 999 ==

Tend

buf1 BUFFER_ADDR 32 dump
buf1 free-buffer


