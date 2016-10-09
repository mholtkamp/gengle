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
	lea Ball, a0 
	move.l M_BALL_X(a0), d0 
	cmpi.l #LEFT_BOUND, d0 
	blt .bounce_left
	cmpi.l #RIGHT_BOUND, d0 
	bgt .bounce_right
	jmp .update_sprite 
	
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
	; jmp .update_sprite
	
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
	
