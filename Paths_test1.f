NEED ForthAstroPaths
NEED simple-tester

Tstart

T{ astro.working-root hashS }T s" E:\images\working" hashS ==
T{ astro.science-root hashS }T s" E:\images" hashS ==

s" E:\test-working" $-> astro.working-root
s" E:\test-science" $-> astro.science-root

T{ astro.working-root hashS }T s" E:\test-working" hashS ==
T{ astro.science-root hashS }T s" E:\test-science" hashS ==

Tend
bye
