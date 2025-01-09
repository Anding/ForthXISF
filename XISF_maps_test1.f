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

s" TAKAHASHI CCA250" $-> rig.telescope

FITSmap add-observationFITS 
FITSmap add-rigFITS
CR FITSmap .map CR

XISFmap add-observationXISF
CR XISFmap .map CR
