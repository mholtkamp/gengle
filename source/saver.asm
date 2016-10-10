; ++++++ STRUCT ++++++
; Saver  
;
; size  = 32 bytes 
; 
; 0(Saver)  = x position (24.8 long)
; 4(Saver)  = y position (24.8 long)
; 8(Saver)  = width (24.8 long)
; 12(Saver) = height (24.8 long)
; 16(Saver) = x velocity (24.8)
; ++++++++++++++++++++
M_SAVER_RECT         EQU 0 
M_SAVER_X            EQU 0 
M_SAVER_Y            EQU 4 
M_SAVER_WIDTH        EQU 8 
M_SAVER_HEIGHT       EQU 12 
M_SAVER_XVEL         EQU 16 

; ------ SUBROUTINE ------
; Saver_Init
;
; Initializes a saver struct with 
; default stating values.
; 
; Input:
;   a0.l = pointer to saver struct 
; ------------------------	
Saver_Init:

    move.l #SAVER_INIT_X, M_SAVER_X(a0)
    move.l #SAVER_INIT_Y, M_SAVER_Y(a0)
    move.l #SAVER_WIDTH, M_SAVER_WIDTH(a0)
    move.l #SAVER_HEIGHT, M_SAVER_HEIGHT(a0)
    move.l #SAVER_XVEL, M_SAVER_XVEL(a0)

    rts 
 
; ------ SUBROUTINE ------
; Saver_InitSprite
;
; Initializes this savers's corresponding sprite 
; with the correct pattern, size, and position.
; 
; Input:
;   a0.l = pointer to saver struct 
; ------------------------	 
Saver_InitSprite:

    move.l #SAVER_SPRITE_INDEX, d0 
    move.l M_SAVER_X(a0), d1 
    move.l M_SAVER_Y(a0), d2 
    asr.l #8, d1 
    asr.l #8, d2 
    subi.l #SAVER_RECT_OFFSET_X, d1 
    subi.l #SAVER_RECT_OFFSET_Y, d2 
    jsr SetSpritePosition
    
    move.l #SAVER_SPRITE_INDEX, d0 
    move.l #SIZE_32, d1 
    move.l #SIZE_16, d2 
    jsr SetSpriteSize 
    
    move.l #SAVER_SPRITE_INDEX, d0 
    move.l #SAVER_TILE_INDEX, d1 
    jsr SetSpritePattern 
    
    move.l #SAVER_SPRITE_INDEX, d0 
    move.l #SAVER_PALETTE, d1 
    jsr SetSpritePalette 
    
    rts 
    
; ------ SUBROUTINE ------
; Saver_Update
;
; Moves the saver based on it's x velocity.
; It the saver hits the edge of the screen then
; its xvelocity will be reversed. If the saver 
; overlaps the ball, then it will set state to 
; STATE_AIM (and thus, not reduce BallCount)
; 
; Input:
;   a0.l = pointer to saver struct 
; ------------------------	 
Saver_Update

    move.l M_SAVER_XVEL(a0), d0 
    move.l M_SAVER_X(a0), d1 
    add.l d0, d1                ; d1 = updated x position 
    
    cmpi.l #SAVER_LEFT_BOUND, d1 
    bgt .check_right 
    
    ; clamp the position to 0 
    move.l #SAVER_LEFT_BOUND, d1
    ; reverse the direction of velocity 
    move.l #(SAVER_XVEL), d0    
    
    jmp .update_properties
    
.check_right

    cmpi.l #SAVER_RIGHT_BOUND, d1 
    blt .update_properties
    
    ; clamp the position to 0 
    move.l #SAVER_RIGHT_BOUND, d1
    ; reverse the direction of velocity 
    move.l #(-SAVER_XVEL), d0    
    ; jmp .update_properties
    
.update_properties
    move.l d0, M_SAVER_XVEL(a0)
    move.l d1, M_SAVER_X(a0)
    
    ; Update the sprite to match the x/y pos
    move.l a0, -(sp)
    jsr Saver_UpdateSprite
    move.l (sp)+, a0 

    ; Lastly, check to see if the ball is overlapping this saver.
    ; If so, set state to aim
    lea Ball, a1 
    jsr Rect_OverlapsRect
    tst.l d0 
    beq .return 
    
    ; Change the sate to Aim state to spare a ball.
    move.l #STATE_AIM, GameState
    
.return 
    rts
    
; ------ SUBROUTINE ------
; Saver_UpdateSprite:
;
; Updates the saver's corresponding sprite with 
; the current x/y position of the saver.
; 
; Input:
;   a0.l = pointer to saver struct 
; ------------------------	   
Saver_UpdateSprite:
	move.l #SAVER_SPRITE_INDEX, d0 
	move.l M_SAVER_X(a0), d1
    move.l M_SAVER_Y(a0), d2 
	lsr.l #8, d1 				;convert from int to fixed 
	lsr.l #8, d2 				;convert from int to fixed 
    subi.l #SAVER_RECT_OFFSET_X, d1 
    subi.l #SAVER_RECT_OFFSET_Y, d2 
	jsr SetSpritePosition
    rts 