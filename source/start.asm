
LoadStart:
	; Clearing scroll a plane map 
	move.l #ADDR_SCROLL_A_NAME_TABLE, a0 
	move.l #5, d0 
	jsr ClearMap
	
	; Load the map 
	move.l #TITLE_MAP_WIDTH, d0 
	move.l #TITLE_MAP_HEIGHT, d1 
	move.l #1, d2 
	move.l #(TITLE_TILE_INDEX), d3 
	lea TitleMap, a0 
	move.l #TITLE_ADDR, a1
	jsr LoadMap
    
    jsr ResetAllSprites
	
	rts 
	
	
UpdateStart:
	
	; Check if the start button is down.
	; If so, transition to game
	move.w ButtonsDown, d0 
	btst #BUTTON_START, d0
	bne .return 
	jsr LoadGame
	move.l #STATE_AIM, GameState
.return 
	rts 