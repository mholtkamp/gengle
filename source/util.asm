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
	;move.b #GET_CONTROLLER_HIGH, ADDR_CONTROLLER_DATA_PORT
	
	; Move the contents of d0 into ButtonsDown 
	move.w d0, ButtonsDown
	
	rts 

