need forthXISF
need CommandStrings
need simple-tester

256 buffer: ibuf
256 buffer: obuf
256 buffer: tbuf

cr Tstart
T{ ibuf << $09 | $ab | $cd | $ef | >> }T ibuf 4 ==
T{ ibuf obuf 4 moveReverseEndian }T ==
T{ obuf 4 hashS }T tbuf << $ab | $09 | $ef | $cd | >> hashS ==
Tend cr
