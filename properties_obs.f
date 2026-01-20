\ observation properties of an image

\ IMAGETYP – type of image: Light Frame, Bias Frame, Dark Frame, Flat Frame, or Tricolor Image.
\ OBJECT – name or catalog number of object being imaged, if available from Observatory Control Panel or specified by the user in Settings.
\ OBSERVER – user-entered information; the observer’s name.


0 value obs.type
\ one of the following observation types
BEGIN-ENUM
	+enum BIAS
	+enum DARK
	+enum FLAT
	+enum LIGHT
	+enum MASTERBIAS
	+enum MASTERDARK
	+enum MASTERFLAT
	+enum MASTERLIGHT
END-ENUM

\ decode the observation type to a string
BEGIN-ENUMS observationType
	+" Bias"
	+" Dark"
	+" Flat"
	+" Light"
	+" MasterBias"
	+" MasterDark"
	+" MasterFlat"
	+" MasterLight"
END-ENUMS

s"  " $value obs.object
s"  " $value obs.observer

: frames	( n --)
\ set the bias, dark, flat, light frame type
	-> obs.type
;

: frames? ( --)
	obs.type observationType
;

: object ( caddr u --)
	$-> obs.object
;
