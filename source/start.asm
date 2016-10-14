; ------ SUBROUTINE ------
; LoadStart
;
; Loads graphics data necessary for displaying the 
; start screen. 
; ------------------------		
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
	
; ------ SUBROUTINE ------
; UpdateStart
;
; Checks if the user has pressed start to begin 
; the game.
; ------------------------		
UpdateStart:
	
    ; Update the frame counter in preparation 
    ; for seeding the random number generator 
    move.w FrameCounter, d0 
    addq.w #1, d0 
    move.w d0, FrameCounter
    
	; Check if the start button is down.
	; If so, transition to game
	move.w ButtonsDown, d0 
    move.w PrevDown, d1 
    not.w d1 
    or.w d1, d0 
	btst #BUTTON_START, d0
	bne .return 
    jsr SetRandSeed
	jsr LoadGame
	move.l #STATE_AIM, GameState
.return 
	rts 
    
SetRandSeed:

    move.w FrameCounter, d0 
    jsr SeedRandom
    rts 