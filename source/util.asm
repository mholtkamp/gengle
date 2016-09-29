	INCLUDE "include/constants.inc"
	
	SECTION UTIL_SECTION ORG($1000)
	
	
;UTIL_CODE_GROUP	GROUP ORG($1000)
	
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
	
	; restore regs 
	move.l (sp)+, a1
	move.l (sp)+, a0 
	move.l (sp)+, d0 
	
	; Set VDP command on VDP control port 
	move.l d1, ADDR_VDP_CONTROL
	
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
	
	dbra d0, .pattern_copy_loop
	
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