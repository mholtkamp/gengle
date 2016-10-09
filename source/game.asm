; ------ SUBROUTINE ------
; LoadGame
;
; Changes the scroll A map to the game map. 
; Initializes important game variables.
; Should be called before starting a new game
; from level 0.
; ------------------------	
LoadGame:
	
	; Clear the background 
	move.l #0, d0 
	move.l #ADDR_SCROLL_A_NAME_TABLE, a0
	jsr ClearMap
	
	; @@ TODO: Load the scrolling background here
	
	; Reset aim angle 
	move.l #AIM_START_ANGLE, AimAngle 
	move.l #0, Level
	
	rts
	
; ------ SUBROUTINE ------
; UpdateAim
;
; Updates the aim angle based on user input.
; Sets the ball based on the aim angle. 
; Will launch ball and enter the resolve state 
; if the user pressed A. 
; Should only be called in STATE_AIM
; ------------------------	
UpdateAim:

	move.w ButtonsDown, d0 
	move.l AimAngle, d1
	
	btst #BUTTON_LEFT, d0 
	bne .check_right
	addi.l #AIM_ANGLE_DELTA, d1 
	jmp .clamp_aim_angle
.check_right
	btst #BUTTON_RIGHT, d0 
	bne .clamp_aim_angle
	subi.l #AIM_ANGLE_DELTA, d1 
	
.clamp_aim_angle
	cmpi.l #AIM_ANGLE_MIN, d1 
	bgt .check_clamp_max
	move.l #AIM_ANGLE_MIN, d1 
	jmp .save_aim_angle
.check_clamp_max
	cmpi.l #AIM_ANGLE_MAX, d1 
	blt .save_aim_angle 
	move.l #AIM_ANGLE_MAX, d1 
	
.save_aim_angle
	move.l d1, AimAngle 
	
	jsr _PositionBall
	jsr _CheckLaunch

.return 
	rts 
	
; ------ SUBROUTINE ------
; _PositionBall
;
; Private subroutine that positions the ball 
; based on the current AimAngle.
; ------------------------	
_PositionBall:
	
	; Get delta x from center 
	move.l #(AIM_RADIUS>>8), d0 		
	move.l AimAngle, d1 			; load global var AimAngle into d1 
	lsr.l #8, d1 					; convert from fixed to int 
	
	lea CosTable, a0 
	lsl.l #1, d1 					; multiply angle by 2 to get word-offset into table 
	add.l d1, a0 					; a0 pointing at cos((int)AimAngle)
	move.w (a0), d1 				; d1 = 8.8 cos value 
	
	muls d0, d1 					; d1 = AIM_RADIUS * cos(AimAngle) = DeltaX * 256 
	
	move.l #AIM_CENTER_X, d2 
	add.l d2, d1 					; d1 = ball x pos. (x = AIM_CENTER_X + DeltaX)
	

	; Get delta y from center 
	move.l AimAngle, d2 			; load global var AimAngle into d2 
	lsr.l #8, d2 					; convert from fixed to int 
	
	lea SinTable, a0 
	lsl.l #1, d2 					; multiply angle by 2 to get word-offset into table 
	add.l d2, a0 					; a0 pointing at sin((int)AimAngle)
	move.w (a0), d2 				; d2 = 8.8 sin value 
	
	muls d0, d2 					; d2 = AIM_RADIUS * sin(AimAngle) = DeltaX * 256 
	
	move.l #AIM_CENTER_Y, d3 
	add.l d3, d2 					; d3 = ball y pos. (y = AIM_CENTER_Y + DeltaX)
	
	; Update the ball position
	lea Ball, a0 
	move.l d1, M_BALL_X(a0)
	move.l d2, M_BALL_Y(a0)
	jsr Ball_UpdateSprite

.return 

	rts 

; ------ SUBROUTINE ------
; _CheckLaunch
;
; Private subroutine that checks if the user 
; has pressed the A button to launch the ball.
; If A is pressed, the ball's x/y velocity is 
; is set and the game state is changed to 
; STATE_RESOLVE. 
; This subroutine should only be called from 
; UpdateAim
; ------------------------	
_CheckLaunch:

	move.w ButtonsDown, d0 
	btst #BUTTON_A, d0 
	bne .return 
	
	; Set the ball's x/y velocity
	; First find the x-component of velocity 
	move.l #(LAUNCH_SPEED), d0 		; d0 = LAUNCH_SPEED in fixed 24.8
	move.l AimAngle, d1 			; load global var AimAngle into d1 
	asr.l #8, d1 					; convert from fixed to int 
	lea CosTable, a0 
	asl.l #1, d1 					; mult by 2 to get word-offset into table 
	add.l d1, a0 					; find the cos value. The angle should already be in range 5-175.
	
	move.w (a0), d1 				; d1 = 8.8 value 
	muls d0, d1						; mult to get the xvel component of LAUNCH_SPEED
	
	asr.l #8, d1 					; result is in 16.16 format. shift right to get into 24.8
	move.l d1, d2					; d2 = xvel component 
	
	; Next find the y component of velocity 
	move.l AimAngle, d1 
	asr.l #8, d1 
	lea SinTable, a0 
	asl.l #1, d1 
	add.l d1, a0 
	
	move.w (a0), d1 
	muls d0, d1 
	
	asr.l #8, d1 					; convert from 16.16 to 24.8 
	move.l d1, d3					; d3 = yvel component
	
	; Update the ball struct's new xvel and yvel 
	lea Ball, a0 
	move.l d2, M_BALL_XVEL(a0)
	move.l d3, M_BALL_YVEL(a0)
	
	; Change the game state 
	move.l #STATE_RESOLVE, GameState
	
.return 
	rts 

; ------ SUBROUTINE ------
; UpdateResolve
;
; Will update the game physics, resolve collisions
; that occur between the ball and pegs. Will change 
; state to STATE_AIM if the ball falls below 
; FALLOUT_Y or if the ball collides with the saver. 
; Will change state to STATE_LOSE if the player
; has no more lives. Will change state to 
; STATE_WIN if all orange pegs are cleared on level
; NUM_LEVELS-1.
; ------------------------	
UpdateResolve:

	lea Ball, a0 
	jsr Ball_Update 
	rts
	