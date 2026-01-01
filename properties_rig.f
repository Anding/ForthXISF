\ manage properties of an imaging rig
\ write the appropriate FITS keywords

\ APTDIA – diameter of the telescope in millimeters.
\ APTAREA – aperture area of the telescope in square millimeters. This value includes the effect of the central obstruction
\ FOCALLEN - focal length in mm
\ TELESCOP – user-entered information about the telescope used.
\ SWCREATE - software

s" " $value rig.aperature_dia
s" " $value rig.aperature_area
s" " $value rig.focal_len
s" " $value rig.focal_ratio
s"  " $value rig.telescope
s" github.com/Anding/Ptolemy" $value rig.software