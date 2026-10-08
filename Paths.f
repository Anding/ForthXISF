\ Shared operational roots for the imaging ecosystem.
\
\ Roots are mutable string data, not deferred behavior. Environments assign
\ site values once; path builders consume them without knowing the observatory.

NEED ForthBase

s" E:\images\working" $value astro.working-root
s" E:\images" $value astro.science-root
