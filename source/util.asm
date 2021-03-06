; ------ SUBROUTINE ------
; LoadTiles
;
; Loads tiles into VRAM at a given tile vram address
; If loading at a tile index, then the vram address is
; TILE_INDEX * 0x20 
;
; Input:
;   d0.l = number of TILEs to load 
;   a0.l = pointer to tile data (source)
;   a1.l = vram memory location  (destination)
; ------------------------
LoadTiles:
	
	; save current regs
	move.l d0, -(sp)
	move.l a0, -(sp)
	move.l a1, -(sp)

	; Make a call to generate the correct VDP command 
	move.l #VRAM_WRITE, d0  ; d0 = VDP operation
	move.l a1, a0 			; a0 = vram memory location 
	jsr GenerateVDPCommand  ; d1 = vdp command long 
	
	; Set VDP command on VDP control port 
	move.l d2, ADDR_VDP_CONTROL
	
	; restore regs 
	move.l (sp)+, a1
	move.l (sp)+, a0 
	move.l (sp)+, d0 
	
	; Prepare for pixel copy loop 
	; a0 = pattern pixel data pointer already
	; d0 = number of patterns already (for loop counter)
.pattern_copy_loop

	; Unrolling the loop for that precious overhead reduction
	move.w (a0)+, ADDR_VDP_DATA
	move.w (a0)+, ADDR_VDP_DATA
	move.w (a0)+, ADDR_VDP_DATA
	move.w (a0)+, ADDR_VDP_DATA
	move.w (a0)+, ADDR_VDP_DATA
	move.w (a0)+, ADDR_VDP_DATA
	move.w (a0)+, ADDR_VDP_DATA
	move.w (a0)+, ADDR_VDP_DATA
	move.w (a0)+, ADDR_VDP_DATA
	move.w (a0)+, ADDR_VDP_DATA
	move.w (a0)+, ADDR_VDP_DATA
	move.w (a0)+, ADDR_VDP_DATA
	move.w (a0)+, ADDR_VDP_DATA
	move.w (a0)+, ADDR_VDP_DATA
	move.w (a0)+, ADDR_VDP_DATA
	move.w (a0)+, ADDR_VDP_DATA
	
	subq.l #1, d0
	bne .pattern_copy_loop
	
	rts

	
; ------ SUBROUTINE ------
; LoadPalette
;
; Loads a palette of 16 words into CRAM at the
; given palette index. 
;
; Input:
;   d0.l = palette index 
;   a0.l = pointer to palette (source)
; ------------------------	
LoadPalette:
	
	; First, the VDP command long needs to be generated.
	move.l d0, -(sp)
	move.l a0, -(sp)
	
	move.l d0, d1 
	move.l #CRAM_WRITE, d0
	lsl.l #5, d1 
	move d1, a0 		; address = palette index * 32 
	jsr GenerateVDPCommand
	
	move.l d2, ADDR_VDP_CONTROL
	
	move.l (sp)+, a0 
	move.l (sp)+, d0 
	
	move.l #16, d0 
	
.copy_loop
	move.w (a0)+, d1 
	move.w d1, ADDR_VDP_DATA
	subq.l #1, d0
	bne .copy_loop
	
	rts 
	
	
; ------ SUBROUTINE ------
; LoadMap
;
; Loads a map into VRAM at the specified address.
; Map data should be one word per map entry. 
;
; Input:
;   d0.l = map width
;   d1.l = map height
;   d2.l = color palette to use (0-3)
;   d3.l = tile index to offset all map entries
;   a0.l = pointer to map source data (source)
;   a1.l = pointer to VRAM location (destination)
; ------------------------	
LoadMap:

	; shift the color palette to place the bits in the correct location
	; that the pattern name expects (bits 14/13)
	andi.w #3, d2 		; in case more bits than 1/0 were set
	ror.w #3, d2 		; bits 1/0  to 14/13
	
	; Make a copy of map width so we can restore the 
	; counter between filling rows into VRAM
	move.l d0, d4
	
.loop_row
	; save registers
	move.l d0, -(sp)
	move.l d1, -(sp)
	move.l d2, -(sp)
	move.l d3, -(sp)
	move.l d4, -(sp)
	move.l a0, -(sp)
	move.l a1, -(sp)
	
	; generate the vdp command needed to write to vram
	move.l #VRAM_WRITE, d0 
	move.l a1, a0 
	jsr GenerateVDPCommand
	move.l d2, ADDR_VDP_CONTROL		; let VDP know that we are going to write to VRAM
	
	; restore registers from stack 
	move.l (sp)+, a1
	move.l (sp)+, a0
	move.l (sp)+, d4 
	move.l (sp)+, d3 
	move.l (sp)+, d2 
	move.l (sp)+, d1
	move.l (sp)+, d0 

.loop 
	move.w (a0)+, d5 
	add.w d3, d5					; offset the map entry value
	move.w d5, ADDR_VDP_DATA
	subq.l #1, d0
	bne .loop 
	
	; end of map row
	move.l d4, d0 		; restore map width in hori counter 
	adda.l #(2*PLANE_WIDTH), a1 	; make a1 point to one row below in VRAM 
	subq.l #1, d1
	bne .loop_row 
	
	rts 
	
; ------ SUBROUTINE ------
; ClearMap
;
; Sets the pattern number for each entry in the table to the given
; pattern number.
;
; Input:
;   d0.l = pattern number 
;   a0.l = address of map to clear
; ------------------------
ClearMap:

	; push current reg values 
	move.l d0, -(sp)
	move.l a0, -(sp)
	
	; Get VDP command and then write to control port
	move.l #VRAM_WRITE, d0 
	jsr GenerateVDPCommand
	move.l d2, ADDR_VDP_CONTROL
	
	; Restore registers
	move.l (sp)+, a0 
	move.l (sp)+, d0 
	
	; loop counter = num of entries to clear = width*height = 64*32
	move.l #(PLANE_WIDTH*PLANE_HEIGHT), d1 
	
.loop
	move.w d0, ADDR_VDP_DATA
	subq.l #1, d1 
	bne .loop 
	
	rts
	
; ------ SUBROUTINE ------
; GenerateVDPCommand
;
; Generate a VDP command based on 
; The operation id and the address of interest
;
; Input:
;   d0.l = VDP operation id 
;   a0.l = address of interest 
;
; Output:
;	d2.l = VDP command 
; ------------------------
GenerateVDPCommand:

	clr.l d2
	clr.l d3 
	
	; a0 was used as a param since the caller is giving an address,
	; but it is probably better to place it in a data register and 
	; to not think of it as a valid address
	move.l a0, d1 
	
	; First copy the lower operation byte into d2
	; and then shift it to the correct location (only C1 + C0)
	move.b d0, d2 		; d2 will store the operation portion of command  long word 
	swap.w d2 			; swap to the upper byte 
	lsl.l #8, d2 
	lsl.l #6, d2 		; C1 + C0 in the most sig bits of long
	
	; now get the higher bits of the operation in the lower word of d2 
	move.b d0, d2 
	andi.b #$fc, d2 
	lsl.b #2, d2 	;only shift .b so that the C0+C1 bits dont get shifted out of register

	; Next move the vram address into d3 but rearrange it into the weird-ass VDP format 
	move.l d1, d3 
	and.l #$00003fff, d3 
	swap.w d3 			; now A13-A0 is in the upper word with 2 MSBs cleared 
	
	move.w d1, d3 		; now the address is in d3's lower word again 
	lsr.w #8, d3 		; but we want A15+A14 to be in bit 1+0 
	lsr.w #6, d3 		; now A15+A14 are in the two LSBs
	
	; So now, d2 has the operation bits
	;         d3 has the address bits 
	; Just need to or them together 
	or.l d3, d2 		; d2 = VDP command long 
	
	rts
	
; ------ SUBROUTINE ------
; UpdateButtons
;
; Grabs the state of buttons from the controller.
; This subroutine places the updated values in the ButtonsDown
; word in BSS memory. Status of an individual button can be
; checked by using btst.w #BUTTON_X, ButtonsDown
; If the bit is set, then that button is down.
; If cleared, then that button is up.
; ------------------------
UpdateButtons:
	
    ; Save previous button states so you can 
    ; easily tell if a button was just pressed this frame.
    move.w ButtonsDown, PrevDown 
    
    clr.l d0 
    
	; Request the high part of controller status word 
	; nop's are put in to account for the delay
	move.b #GET_CONTROLLER_HIGH, ADDR_CONTROLLER_DATA_PORT
	nop 
	nop
	nop
	nop
	move.b ADDR_CONTROLLER_DATA_PORT, d0 
	rol.w #8, d0 			; place this byte into the high part of d0 
	
	; Request the low part of controller status word 
	; nop's are put in to account for the delay
	move.b #GET_CONTROLLER_LOW, ADDR_CONTROLLER_DATA_PORT
	nop 
	nop
	nop
	nop
	move.b ADDR_CONTROLLER_DATA_PORT, d0 
	
	; Move the contents of d0 into ButtonsDown 
	move.w d0, ButtonsDown
	
	rts 

; ------ SUBROUTINE ------
; WaitVblank
;
; Do not return from subroutine until the the vblank flag 
; is set by the vertical blank interrupt handler
; ------------------------
WaitVblank:

	; Keep checking if the vblank flag has been set
	move.l VblankFlag, d0 
	cmpi.l #1, d0 
	bne WaitVblank
	
	; The vblank flag was set, clear it and return 
	move.l #0, VblankFlag
	rts 

; ------ SUBROUTINE ------
; ResetAllSprites
;
; Places all the genesis sprites offscreen at position 
; x = SPRITE_DISABLE_X, y = SPRITE_DISABLE_Y
; This effectively disables the sprites.
; Apparently there is some weird masking property that gets 
; triggered when the sprites x position is 0. Haven't looked 
; into this, but this is the reason I currently do not have the 
; x position set to 0.
; ------------------------	
ResetAllSprites:
	
	; generate the VDP command for writing to sprite attribute table 
	move.l #VRAM_WRITE, d0 
	move.l #ADDR_SPRITE_NAME_TABLE, a0 
	jsr GenerateVDPCommand
	
	; Set VDP command on VDP control port 
	move.l d2, ADDR_VDP_CONTROL
	
	; loop through all sprites and put them off screen
	move.l #0, d0 
	move.l #ADDR_SPRITE_NAME_TABLE, a0 
	clr.l d1 
	
.loop 
	; set the vertical position to SPRITE_DISABLE_Y 
	move.w #SPRITE_DISABLE_Y, ADDR_VDP_DATA 	; RESET vertical position of sprite 
	move.w d0, d1 			; get the sprite index 
	addq.w #1, d1 			; increment by 1 to get the index of next sprite in link list 
	ori.w #$0000, d1 		; or with vert size = 1, hori size = 1 for default size (8x8 pixels)
	move.w d1, ADDR_VDP_DATA					; RESET hori/vert size and link number 
	move.w #$2037, ADDR_VDP_DATA				; RESET (prio=0, pal=1, flips=0, pattern = RED_PEG_TILE_INDEX)
	move.w #SPRITE_DISABLE_X, ADDR_VDP_DATA		; RESET horizontal position of sprite 
	
	; increment counter and branch if less than num sprites 
	addq.l #1, d0 
	cmpi.l #MAX_SPRITES, d0 
	bne .loop 
	
	; Set the link of the last sprite to 0
	move.l #VRAM_WRITE, d0 
	move.l #(ADDR_SPRITE_NAME_TABLE+8*79+2), a0 
	jsr GenerateVDPCommand
	
	; Set VDP command on VDP control port 
	move.l d2, ADDR_VDP_CONTROL
	
	move.w #$0500, ADDR_VDP_DATA ; set link to 0 (finished)
	
	rts 

; ------ SUBROUTINE ------
; SetSpritePosition
;
; Positions the sprite with the given index at 
; the on-screen positions in x = d1, y = d2 
; 
; Input:
;   d0.l = sprite index (0-79)
;   d1.l = on-screen x-pos 
;   d2.l = on-screen y-pos 
; ------------------------	
SetSpritePosition:
	; first get the true sprite coordinates, not the screen coords 
	addi.l #128, d1 
	addi.l #128, d2 
	
	; figure out the VRAM address that we need to write the YPOS to 
	lsl.l #3, d0 	; mult the index by 3 to get the offset in bytes into table.
	move.l #VDP_COM_WRITE_SPRITE, d3 		; the vdp command for writing to first entry in sprite table 
	swap.w d0 								; swap d0 to get the byte offset into the upper word 
	add.l d0, d3 
	move.l d3, ADDR_VDP_CONTROL				; let the VDP know we are going to write to the sprite attrib location 
	
	move.w d2, ADDR_VDP_DATA				; write the new y pos 
	
	; calculate the VRAM address that we need to write to the XPOS 
	; d3 already contains the command for writing to ypos, so we just need to 
	; offset it by 6 bytes to point to the xpos attribute. 
	addi.l #$00060000, d3 
	move.l d3, ADDR_VDP_CONTROL 
	
	move.w d1, ADDR_VDP_DATA				; write the new x pos 
	
	rts 
	
; ------ SUBROUTINE ------
; SetSpritePattern
;
; Assigns the given pattern index to the sprite at
; the provided index 
; 
; Input:
;   d0.l = sprite index (0-79)
;   d1.l = sprite pattern (0-2047)
; ------------------------	
SetSpritePattern:
	move.l #VDP_COM_READ_SPRITE, d3 
	lsl.l #3, d0 
	addq.l #4, d0 			; add 4 to get the word containing pattern 
	swap.w d0 
	add.l d0, d3 
	
	move.l d3, ADDR_VDP_CONTROL
	
	move.w ADDR_VDP_DATA, d2 		; read word value for pattern word 
	andi.w #$f800, d2 				; mask off the old pattern value 
	andi.w #$07ff, d1 				; make sure that the pattern is in range 0-2047 
	add.w d1, d2 					; d2 = word with new pattern in bits 0-10
	
	move.l #VDP_COM_WRITE_SPRITE, d3 ; place the sprite write command in d3 because we are writing the new word 
	add.l d0, d3 					; d0 still contains the offset into sprite table of pattern word 
	
	move.l d3, ADDR_VDP_CONTROL 	; preparing to write new pattern word for this sprite 
	
	move.w d2, ADDR_VDP_DATA 		; do the write 
	
	rts 

; ------ SUBROUTINE ------
; SetSpriteSize
;
; Sets the sprites dimensions.
; 
; Input:
;   d0.l = sprite index (0-79)
;   d1.l = sprite width (0-3)
;   d2.l = sprite height (0-3)
; ------------------------	
SetSpriteSize:

	move.l #VDP_COM_READ_SPRITE, d3 
	lsl.l #3, d0 
	addq.l #2, d0				; add 2 to get the word containing dimensions
	swap.w d0 
	add.l d0, d3 				; d3 command to read where we want 
	
	andi.l #$0003, d1 			; ensure that width is 0-3 
	andi.l #$0003, d2 			; ensure that height is 0-3 
	lsl.w #8, d2 				; shift over the height to correct position
	lsl.w #8, d1 				
	lsl.w #2, d1 				; move the witdh bits over by 10 to get them into proper position 
	
	add.w d2, d1 				; d1 = the new bits to write into dimension word 
	
	move.l d3, ADDR_VDP_CONTROL
	
	move.w ADDR_VDP_DATA, d4 	; d4 = current dimension word 
	andi.w #$f0ff, d4			; mask away the old dimensions 
	add.w d1, d4 				; d4 = new dim word 
	
	move.l #VDP_COM_WRITE_SPRITE, d3 
	add.l d0, d3 				; prepare to write dim word 
	
	move.l d3, ADDR_VDP_CONTROL
	
	move.w d4, ADDR_VDP_DATA
	
	rts 

; ------ SUBROUTINE ------
; SetSpritePalette
;
; Sets the sprite's palette
; 
; Input:
;   d0.l = sprite index (0-79)
;   d1.l = sprite palette (0-3)
; ------------------------	
SetSpritePalette:

	move.l #VDP_COM_READ_SPRITE, d3 
	lsl.l #3, d0 
	addq.l #4, d0 
	swap.w d0 
	add.l d0, d3 			; d3 = read command 
	
	andi.l #$3, d1 			; sanitize new palette, make sure it is between 0-3 
	ror.w #3, d1 			; rotate the bits to put them in the proper place for palette word 
	
	move.l d3, ADDR_VDP_CONTROL 
	
	move.w ADDR_VDP_DATA, d4 
	andi.w #$9fff, d4 			; mask off old palette 
	add.w d1, d4 				; add the new palette in bits 14/13 
	
	move.l #VDP_COM_WRITE_SPRITE, d3  
	add.l d0, d3 
	
	move.l d3, ADDR_VDP_CONTROL 
	move.w d4, ADDR_VDP_DATA
	
	rts 

; ------ SUBROUTINE ------
; SeedRandom
;
; Seeds the random number generator with 
; a given word 
; 
; Input:
;   d0.w = seed 
; ------------------------	
SeedRandom:
    move.w d0, RandVal
    rts 
    
; ------ SUBROUTINE ------
; Random
;
; Returns a byte between
; 
; Output:
;   d0.b = random value (0-255)
; ------------------------	
Random:
    ; Multiply some magic number 
    move.w RandVal, d0 
    move.w #RAND_MULTIPLIER, d1 
    mulu d1, d0 
    
    ; Add some magic number 
    addi.w #RAND_ADDER, d0 
    
    ; Save this as the new random value
    move.w d0, RandVal
    
    ; d0.b will contain a random number 
    ; but mask away other bytes just for safety 
    andi.l #$000000ff, d0 
    
    rts 