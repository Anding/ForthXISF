\ buffer operations

\ descriptor data structure for an buffer
BEGIN-STRUCTURE
					BUFFER_DESCRIPTOR
	4 	+FIELD	BUFFER_SIZE				\ size of the buffer in bytes
	4 	+FIELD 	BUFFER_POINTER			\ pointer to the current write location
	0 	+FIELD 	BUFFER_ADDR				\ address of the buffer
END-STRUCTURE


: write-buffer ( addr n buf --)
\ write (type) a string to the buffer and advance the buffer pointer
\ bounds checked
;

: buffer_used ( buf -- x)
\ used buffer bytes
;

: buffer_free ( bux -- x)
\ free buffer bytes
;

: reset-buffer ( buf --)
\ reset the buffer_pointer
;