	include "include/constants.inc"

	ORG 0
; Header data retrieved from https://bigevilcorporation.co.uk/2012/02/28/sega-megadrive-1-getting-started/
; What a life-saver!
; ******************************************************************
; Sega Megadrive ROM header
; ******************************************************************
	dc.l   0x00FFE000      ; Initial stack pointer value
	dc.l   EntryPoint      ; Start of program
	dc.l   Exception       ; Bus error
	dc.l   Exception       ; Address error
	dc.l   Exception       ; Illegal instruction
	dc.l   Exception       ; Division by zero
	dc.l   Exception       ; CHK exception
	dc.l   Exception       ; TRAPV exception
	dc.l   Exception       ; Privilege violation
	dc.l   Exception       ; TRACE exception
	dc.l   Exception       ; Line-A emulator
	dc.l   Exception       ; Line-F emulator
	dc.l   Exception       ; Unused (reserved)
	dc.l   Exception       ; Unused (reserved)
	dc.l   Exception       ; Unused (reserved)
	dc.l   Exception       ; Unused (reserved)
	dc.l   Exception       ; Unused (reserved)
	dc.l   Exception       ; Unused (reserved)
	dc.l   Exception       ; Unused (reserved)
	dc.l   Exception       ; Unused (reserved)
	dc.l   Exception       ; Unused (reserved)
	dc.l   Exception       ; Unused (reserved)
	dc.l   Exception       ; Unused (reserved)
	dc.l   Exception       ; Unused (reserved)
	dc.l   Exception       ; Spurious exception
	dc.l   Exception       ; IRQ level 1
	dc.l   Exception       ; IRQ level 2
	dc.l   Exception       ; IRQ level 3
	dc.l   HBlankInterrupt ; IRQ level 4 (horizontal retrace interrupt)
	dc.l   Exception       ; IRQ level 5
	dc.l   VBlankInterrupt ; IRQ level 6 (vertical retrace interrupt)
	dc.l   Exception       ; IRQ level 7
	dc.l   Exception       ; TRAP #00 exception
	dc.l   Exception       ; TRAP #01 exception
	dc.l   Exception       ; TRAP #02 exception
	dc.l   Exception       ; TRAP #03 exception
	dc.l   Exception       ; TRAP #04 exception
	dc.l   Exception       ; TRAP #05 exception
	dc.l   Exception       ; TRAP #06 exception
	dc.l   Exception       ; TRAP #07 exception
	dc.l   Exception       ; TRAP #08 exception
	dc.l   Exception       ; TRAP #09 exception
	dc.l   Exception       ; TRAP #10 exception
	dc.l   Exception       ; TRAP #11 exception
	dc.l   Exception       ; TRAP #12 exception
	dc.l   Exception       ; TRAP #13 exception
	dc.l   Exception       ; TRAP #14 exception
	dc.l   Exception       ; TRAP #15 exception
	dc.l   Exception       ; Unused (reserved)
	dc.l   Exception       ; Unused (reserved)
	dc.l   Exception       ; Unused (reserved)
	dc.l   Exception       ; Unused (reserved)
	dc.l   Exception       ; Unused (reserved)
	dc.l   Exception       ; Unused (reserved)
	dc.l   Exception       ; Unused (reserved)
	dc.l   Exception       ; Unused (reserved)
	dc.l   Exception       ; Unused (reserved)
	dc.l   Exception       ; Unused (reserved)
	dc.l   Exception       ; Unused (reserved)
	dc.l   Exception       ; Unused (reserved)
	dc.l   Exception       ; Unused (reserved)
	dc.l   Exception       ; Unused (reserved)
	dc.l   Exception       ; Unused (reserved)
	dc.l   Exception       ; Unused (reserved)
 
	dc.b "SEGA GENESIS    "                                 ; Console name
	dc.b "(C)SEGA 1992.SEP"                                 ; Copyrght holder and release date
	dc.b "GENGLE                                          " ; Domestic name
	dc.b "GENGLE                                          " ; International name
	dc.b "GM XXXXXXXX-XX"                                   ; Version number
	dc.w 0x0000                                             ; Checksum
	dc.b "J               "                                 ; I/O support
	dc.l 0x00000000                                         ; Start address of ROM
	dc.l __end                                              ; End address of ROM
	dc.l 0x00FF0000                                         ; Start address of RAM
	dc.l 0x00FFFFFF                                         ; End address of RAM
	dc.l 0x00000000                                         ; SRAM enabled
	dc.l 0x00000000                                         ; Unused
	dc.l 0x00000000                                         ; Start address of SRAM
	dc.l 0x00000000                                         ; End address of SRAM
	dc.l 0x00000000                                         ; Unused
	dc.l 0x00000000                                         ; Unused
	dc.b "                                        "         ; Notes (unused)
	dc.b "JUE             "                                 ; Country codes


EntryPoint:
	tst.w ADDR_MYSTERY_RESET
	bne Main
	tst.w ADDR_RESET
	bne Main
	
	;Clear RAM
	move.l #0, d0 
	move.l #0, a0 
	move.l #0x3fff, d1 
	
.clear_ram_loop 
	move.l d0, -(a0)
	dbra d1, .clear_ram_loop 
	
	; First, write the TMSS so that the VDP doesn't get locked
	move.l #'SEGA', ADDR_TMSS
	
	; Initialize VDP
	lea VDP_Init_Reg_Vals, a0 
	move.l #24, d0 
	move.l #0x00008000, d1 
	
.CopyVDP 
	move.b (a0)+, d1 	; move the register val into lowest byte of d1 
	move.w d1, ADDR_VDP_CONTROL 
	add.w #0x0100, d1 
	dbra d0, .CopyVDP
	
	; Initialize I/O 
	move.b #0, ADDR_CTRL1
	move.b #0, ADDR_CTRL2
	move.b #0, ADDR_EXP 
	
	
Main:

	move.l #0xF, d0 ; Move 15 into register d0
	move.l d0, d1   ; Move contents of register d0 into d1
	jmp Main        ; Jump back up to 'Loop'
 
HBlankInterrupt:
VBlankInterrupt:
	rte   ; Return from Exception
 
Exception:
	rte   ; Return from Exception
	

; Initial register values to be sent to VDP, thanks to Big Evil Corporation
VDP_Init_Reg_Vals:
   dc.b 0x20 ; 0: Horiz. interrupt on, plus bit 2 (unknown, but docs say it needs to be on)
   dc.b 0x74 ; 1: Vert. interrupt on, display on, DMA on, V28 mode (28 cells vertically), + bit 2
   dc.b 0x30 ; 2: Pattern table for Scroll Plane A at 0xC000 (bits 3-5)
   dc.b 0x40 ; 3: Pattern table for Window Plane at 0x10000 (bits 1-5)
   dc.b 0x05 ; 4: Pattern table for Scroll Plane B at 0xA000 (bits 0-2)
   dc.b 0x70 ; 5: Sprite table at 0xE000 (bits 0-6)
   dc.b 0x00 ; 6: Unused
   dc.b 0x00 ; 7: Background colour - bits 0-3 = colour, bits 4-5 = palette
   dc.b 0x00 ; 8: Unused
   dc.b 0x00 ; 9: Unused
   dc.b 0x00 ; 10: Frequency of Horiz. interrupt in Rasters (number of lines travelled by the beam)
   dc.b 0x08 ; 11: External interrupts on, V/H scrolling on
   dc.b 0x81 ; 12: Shadows and highlights off, interlace off, H40 mode (40 cells horizontally)
   dc.b 0x34 ; 13: Horiz. scroll table at 0xD000 (bits 0-5)
   dc.b 0x00 ; 14: Unused
   dc.b 0x00 ; 15: Autoincrement off
   dc.b 0x01 ; 16: Vert. scroll 32, Horiz. scroll 64
   dc.b 0x00 ; 17: Window Plane X pos 0 left (pos in bits 0-4, left/right in bit 7)
   dc.b 0x00 ; 18: Window Plane Y pos 0 up (pos in bits 0-4, up/down in bit 7)
   dc.b 0x00 ; 19: DMA length lo byte
   dc.b 0x00 ; 20: DMA length hi byte
   dc.b 0x00 ; 21: DMA source address lo byte
   dc.b 0x00 ; 22: DMA source address mid byte
   dc.b 0x00 ; 23: DMA source address hi byte, memory-to-VRAM mode (bits 6-7)
 
__end    ; Very last line, end of ROM address