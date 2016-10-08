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
	
	
.return 
	rts 
	
UpdateResolve:

	rts
	