\ test for XISF_map

include "%idir%\..\forthbase\libraries\libraries.f"
NEED forthbase
NEED forth-map
NEED windows

include "%idir%\properties_obs.f"
include "%idir%\properties_rig.f"
include "%idir%\XISF_maps.f"

map CONSTANT FITSmap
map CONSTANT XISFmap

s" Takahashi Epsilon 160-ED" $-> rig.telescope
160 -> rig.aperature_dia
18000 -> rig.aperature_area
530 -> rig.focal_len

s" Crab_nebula" $-> obs.object
s" Patrick Moore" $-> obs.observer
3 -> obs.type

CR
." FITSmap"
FITSmap add-observationFITS 
FITSmap add-rigFITS
FITSmap .map CR

." XISFmap"
XISFmap add-observationXISF
XISFmap .map CR
