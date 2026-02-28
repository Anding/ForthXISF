
: XISF.spawn { image | newImage }
\ spawn a new image from an existing image
\ allocate storage but do not copy pixel data
\ the new image will take a reference to the FITS map of the existing image
    image IMAGE_WIDTH @ image IMAGE_HEIGHT @ image IMAGE_DEPTH @ allocate-image -> newImage
    image FITS_MAP @ newImage FITS_MAP ! 
    image IMAGE_STATISTICS @ newImage IMAGE_STATISTICS !     
    newImage
;

