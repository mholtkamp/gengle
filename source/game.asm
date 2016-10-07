LoadGame:
	
	move.l #0, d0 
	move.l #ADDR_SCROLL_A_NAME_TABLE, a0
	jsr ClearMap
	
	rts
	
UpdateAim:

	move.w ButtonsDown, d0 
	btst #BUTTON_A, d0 
	bne .return 
	move.l #STATE_START, GameState
	jsr LoadStart
.return 
	rts 
	
UpdateResolve:

	rts
	