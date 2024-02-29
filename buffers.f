\ buffer operations

\ descriptor data structure for an buffer
BEGIN-STRUCTURE	BUFFER_DESCRIPTOR
	4 	+FIELD	BUFFER_SIZE				\ size of the buffer in bytes
	4 	+FIELD 	BUFFER_POINTER			\ pointer to the current write location
	0 	+FIELD 	BUFFER_ADDR				\ the buffer itself immediately follows the descriptor
END-STRUCTURE

: buffer_used ( buf -- x)
\ used buffer bytes
	dup >R BUFFER_POINTER @
	R> BUFFER_ADDR -
;

: buffer_free ( bux -- x)
\ free buffer bytes
	dup >R BUFFER_SIZE @
	R> buffer_used -
;

: reset-buffer ( buf --)
\ reset the buffer_pointer
\ zero the buffer
	dup >R BUFFER_ADDR
	R@ BUFFER_POINTER !
	R@ BUFFER_ADDR R> BUFFER_SIZE @ ERASE
;

: write-buffer ( addr n buf -- n')
\ write (type) a string to the buffer and advance the buffer pointer
\ bounds checked
	>R 								( addr n R: buf)
	R@ buffer_free over < if drop R@ buffer_free then	( addr n' R: buf) \ clip to available space
	dup -rot							( n' addr n' R: buf)
	R@ BUFFER_POINTER @ swap 	( n' addr addr2 n') move 
	dup R> BUFFER_POINTER +!
;
