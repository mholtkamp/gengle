; ++++++ STRUCT ++++++
; Peg  
;
; size  = 32 bytes 
; 
; 0(Peg)  = x position (24.8 long)
; 4(Peg)  = y position (24.8 long)
; 8(Peg)  = width (24.8 long)
; 12(Peg) = height (24.8 long)
; 16(Peg) = type (byte)
; 17(Peg) = active (byte)
; 18(Peg) = moving (byte)
; 19(Peg) = sprite index (byte)
; 20(Peg) = left bound (word)
; 22(Peg) = right bound (word)
; ++++++++++++++++++++
M_PEG_RECT         EQU 0 
M_PEG_X            EQU 0 
M_PEG_Y            EQU 4 
M_PEG_WIDTH        EQU 8 
M_PEG_HEIGHT       EQU 12 
M_PEG_TYPE         EQU 16 
M_PEG_ACTIVE       EQU 17
M_PEG_MOVING	   EQU 18 
M_PEG_SPRITE_INDEX EQU 19
M_PEG_LEFT_BOUND   EQU 20 
M_PEG_RIGHT_BOUND  EQU 22 


; ------ SUBROUTINE ------
; Peg_Init
;
; Initializes a peg struct with standard 
; starting values. Defaults active to 0 
; 
; Input:
;   a0.l = pointer to peg struct 
; ------------------------	
Peg_Init:

    move.l #PEG_INIT_X, M_PEG_X(a0) 
    move.l #PEG_INIT_Y, M_PEG_Y(a0)
    move.l #PEG_WIDTH, M_PEG_WIDTH(a0)
    move.l #PEG_HEIGHT, M_PEG_HEIGHT(a0)
    
    move.b #PEG_TYPE_BLUE, M_PEG_TYPE(a0)
    move.b #0, M_PEG_ACTIVE(a0)
    move.b #0, M_PEG_MOVING(a0)
    move.b #PEGS_SPRITE_INDEX, M_PEG_SPRITE_INDEX(a0)
    
    move.w #0, M_PEG_LEFT_BOUND(a0)
    move.w #0, M_PEG_RIGHT_BOUND(a0)
    
    rts 
    

; ------ SUBROUTINE ------
; Peg_InitSprite
;
; Initializes this peg's corresponding sprite 
; with the correct pattern, size, and position.
; 
; Input:
;   a0.l = pointer to peg struct 
; ------------------------	
Peg_InitSprite:

L_SELF     SET 0 
LVARS_SIZE SET 4 
    
    ; Setup local vars 
    sub.l #LVARS_SIZE, sp
    move.l a0, L_SELF(sp)
    
    ; Check if the sprite is active. 
    ; If it is not active, then we just need to place 
    ; the sprite offscreen and that is all. 
    move.b M_PEG_ACTIVE(a0), d0 
    cmpi.b #0, d0 
    bne .use_position 
    move.l #PEG_INIT_X, d1 
    move.l #PEG_INIT_Y, d2 
    jmp .set_position

.use_position
    move.l M_PEG_X(a0), d1 
    move.l M_PEG_Y(a0), d2 
    
.set_position
    clr.l d0 
    move.b M_PEG_SPRITE_INDEX(a0), d0
    asr.l #8, d1 
    asr.l #8, d2                ; shift the positions to convert them to integer from fixed
    jsr SetSpritePosition       ; put the sprite off screen
    
    ; Next, set the pattern based on the type of peg 
    move.l L_SELF(sp), a0 
    clr.l d0 
    move.b M_PEG_TYPE(a0), d0 
    cmpi.l #PEG_TYPE_BLUE, d0 
    beq .set_pattern_blue 
    cmpi.l #PEG_TYPE_RED, d0
    beq .set_pattern_red 
    cmpi.l #PEG_TYPE_PURPLE, d0 
    beq .set_pattern_purple 
    ; fall-through if type is something else (which should never happen)
    
.set_pattern_blue
    move.l #BLUE_PEG_TILE_INDEX, d1 
    jmp .set_pattern
.set_pattern_red 
    move.l #RED_PEG_TILE_INDEX, d1 
    jmp .set_pattern
.set_pattern_purple
    move.l #PURPLE_PEG_TILE_INDEX, d1 
    jmp .set_pattern
.set_pattern 
    clr.l d0 
    move.b M_PEG_SPRITE_INDEX(a0), d0 
    jsr SetSpritePattern
    
    ; Next set the dimensions 
    move.l L_SELF(sp), a0 
    move.l #SIZE_8, d1 
    move.l #SIZE_8, d2 
    clr.l d0 
    move.b M_PEG_SPRITE_INDEX(a0), d0 
    jsr SetSpriteSize 
    
    ; Lastly, set the palette to 1 
    move.l L_SELF(sp), a0 
    move.l #PEG_PALETTE, d1 
    clr.l d0 
    move.b M_PEG_SPRITE_INDEX(a0), d0 
    jsr SetSpritePalette 
    
.return
    ; remove local vars from stack 
    add.l #LVARS_SIZE, sp
    rts 
    
; ------ SUBROUTINE ------
; Peg_UpdateSprite
;
; Update's this peg's corresponding sprite's 
; position based on x,y. This will not hide
; the sprite if the peg is inactive.
; Use InitSprite for the purpose of hiding sprite.
; 
; Input:
;   a0.l = pointer to peg struct 
; ------------------------	
Peg_UpdateSprite:
    ; Update the position of sprite, and that is all.
    move.l M_PEG_X(a0), d1 
    move.l M_PEG_Y(a0), d2 
    asr.l #8, d1 
    asr.l #8, d2                ; shift the positions to convert them to integer from fixed
    clr.l d0 
    move.b M_PEG_SPRITE_INDEX(a0), d0 
    jsr SetSpritePosition

    rts 

; ------ SUBROUTINE ------
; Peg_Consume
;
; Deactivates the peg and adds to the score
; based on RedPegCount
; 
; Input:
;   a0.l = pointer to peg struct 
; ------------------------	
Peg_Consume:

    ; Now mark the peg as active and init the sprite 
    ; so that it goes offscreen 
    move.b #0, M_PEG_ACTIVE(a0)
    
    jsr Peg_InitSprite
    
    ; Check if peg was a red peg, if so, dec the 
    ; global red peg count 
    move.b M_PEG_TYPE(a0), d1
    cmpi.b #PEG_TYPE_RED, d1 
    bne .blue_peg  
    move.l RedPegCount, d1 
    subq.l #1, d1 
    move.l d1, RedPegCount      ; reduce the number of red pegs 
    
    ; Add red peg score 
    add.l #RED_PEG_SCORE, Score 
    jmp .return 
    
.blue_peg 
    move.l RedPegCount, d0
    cmpi.l #LOW_RED, d0 
    bgt .not_low 
    
    ; Only 1 or 2 red pegs left. Add 4 points 
    addi.l #BLUE_PEG_LOW_SCORE, Score 
    jmp .return 
    
.not_low 
    cmpi.l #MID_RED, d0 
    bgt .not_mid 
    addi.l #BLUE_PEG_MID_SCORE, Score 
    jmp .return 
    
.not_mid 
    ; Okay, so there are still a lot of red pegs on the 
    ; board. Only reward 1 point.
    addi.l #BLUE_PEG_HIGH_SCORE, Score 
    
.return 
    
    jsr DrawScore 
    rts 
