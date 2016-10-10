; ++++++ STRUCT ++++++
; Ball 
;
; size  = 32 bytes 
; 
; 0(Ball)  = x position (24.8)
; 4(Ball)  = y position (24.8)
; 8(Ball)  = width (24.8)
; 12(Ball) = height (24.8)
; 16(Ball) = x velocity (24.8)
; 20(Ball) = y velocity (24.8)
; ++++++++++++++++++++
M_BALL_RECT   EQU 0 
M_BALL_X      EQU 0 
M_BALL_Y      EQU 4 
M_BALL_WIDTH  EQU 8 
M_BALL_HEIGHT EQU 12 
M_BALL_XVEL   EQU 16 
M_BALL_YVEL   EQU 20 

; ------ SUBROUTINE ------
; Ball_Init
;
; Initializes a ball struct with standard 
; starting values
; 
; Input:
;   a0.l = pointer to ball struct 
; ------------------------	
Ball_Init:
	move.l #0, M_BALL_X(a0)
	move.l #0, M_BALL_Y(a0)
	move.l #BALL_WIDTH, M_BALL_WIDTH(a0)
	move.l #BALL_HEIGHT, M_BALL_HEIGHT(a0)
	move.l #0, M_BALL_XVEL(a0)
	move.l #0, M_BALL_YVEL(a0)
	rts 

; ------ SUBROUTINE ------
; Ball_Update
;
; Applies gravity to the ball. Updates the position
; of the ball. And handles conflicts with any pegs.
; 
; Input:
;   a0.l = pointer to ball struct 
; ------------------------	
Ball_Update:

	; Apply gravity 
	move.l M_BALL_YVEL(a0), d0 
	move.l #GRAVITY, d1 
	add.l d1, d0 
	move.l d0, M_BALL_YVEL(a0)
	
	; Update the position of ball
	move.l M_BALL_XVEL(a0), d0 
	move.l M_BALL_X(a0), d1 
	add.l d0, d1 
	move.l d1, M_BALL_X(a0)
	
	move.l M_BALL_YVEL(a0), d0 
	move.l M_BALL_Y(a0), d1 
	add.l d0, d1 
	move.l d1, M_BALL_Y(a0)
	
	; Check if ball goes past left or right bounds 
	move.l M_BALL_X(a0), d0 
	cmpi.l #LEFT_BOUND, d0 
	blt .bounce_left
	cmpi.l #RIGHT_BOUND, d0 
	bgt .bounce_right
	jmp .check_collisions 
	
.bounce_left
	move.l #LEFT_BOUND, M_BALL_X(a0)
	jmp .reverse_xvel
	
.bounce_right 
	move.l #RIGHT_BOUND, M_BALL_X(a0)
	; jmp .reverse_xvel

.reverse_xvel
	move.l M_BALL_XVEL(a0), d0 
	neg.l d0 
	move.l d0, M_BALL_XVEL(a0)
    
.check_collisions
    ; Lastly, check for any peg collisions 
    move.l a0, -(sp)            ; save a0
    jsr _Ball_CheckPegCollisions
    move.l (sp)+, a0              ; restore a0 
    
.update_sprite
	; Update sprite 
	jsr Ball_UpdateSprite
	
	rts 

; ------ SUBROUTINE ------
; Ball_UpdateSprite
;
; Updates this ball's corresponding sprite with 
; the current x/y position of the ball.
; 
; Input:
;   a0.l = pointer to ball struct 
; ------------------------	
Ball_UpdateSprite:
	move.l #BALL_SPRITE_INDEX, d0 
	move.l M_BALL_X(a0), d1
	lsr.l #8, d1 				;convert from int to fixed 
	move.l M_BALL_Y(a0), d2 
	lsr.l #8, d2 				;convert from int to fixed 
	jsr SetSpritePosition
	rts 

; ------ SUBROUTINE ------
; _Ball_CheckPegCollisions
;
; Private subroutine that iterates through 
; the peg list and checks if the ball is
; overlapping any pegs. Handles collision 
; when ball is overlapping a peg.
;
; Input:
;   a0.l = pointer to ball struct 
; ------------------------		
_Ball_CheckPegCollisions:
    
REGS REG a0/a1/d0 

    lea Pegs, a1            ; get the peg array 
    clr.l d0                ; d0 = loop counter 
    
.loop
    
    move.b M_PEG_ACTIVE(a1), d1 
    tst.b d1
    beq .continue           ; continue if peg is inactive 
    
    ; Otherwise, peg is active. So check if the ball 
    ; is hitting it. 
    ; save regs 
    movem.l REGS, -(sp) 
    jsr Rect_OverlapsRect
    move.l d0, d1           ; save result in d1 
    ; restore regs 
    movem.l (sp)+, REGS
    
    tst.l d1 
    beq .continue 

    ; @@ TODO: Add complex collision 
    move.l #(-2*TO_FIXED), M_BALL_YVEL(a0)       ; boost the ball upwards
    move.b #0, M_PEG_ACTIVE(a1)
    movem.l REGS, -(sp) 
    move.l a1, a0 
    jsr Peg_InitSprite
    movem.l (sp)+, REGS 
    
.continue
    adda.l #PEG_DATA_SIZE, a1 
    addq.l #1, d0 
    cmp.l LevelPegCount, d0 
    bne .loop 
    
    rts 
