
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
	; Set the status register to turn on supervisor mode 
	move #0x2000, sr
	
	jsr Init
	jsr LoadStart
	move.l #STATE_START, GameState
	
Main_Loop:

	jsr WaitVblank
	jsr UpdateButtons
	
	; The subroutine pointer method:
	; TODO: Reincorporate this code. remove if checks below.
	;move.l GameState, d0 
	;lsl.l #2, d0 
	;lea UpdatePointers, a0 
	;add.l d0, a0 
	;jsr (a0)
	
	move.l GameState, d0 
	cmpi.l #STATE_START, d0 
	bne .check_aim
	jsr UpdateStart
	jmp Main_Loop

.check_aim
	cmpi.l #STATE_AIM, d0 
	bne .check_resolve 
	jsr UpdateAim
	jmp Main_Loop
	
.check_resolve
	cmpi.l #STATE_RESOLVE, d0 
	bne .check_lose 
	jsr UpdateResolve 
	jmp Main_Loop
	
.check_lose 
	cmpi.l #STATE_LOSE, d0 
	bne .check_win 
	move.l #STATE_START, GameState
	jmp Main_Loop
	
.check_win
	
	jmp Main_Loop        ; go to next iteration of game loop
 
HBlankInterrupt:
	rte 
	
VBlankInterrupt:
	move.l #1, VblankFlag
	rte   ; Return from interrupt
 
Exception:
	rte   ; Return from interrupt
	

Z80Data:
   dc.w 0xaf01, 0xd91f
   dc.w 0x1127, 0x0021
   dc.w 0x2600, 0xf977
   dc.w 0xedb0, 0xdde1
   dc.w 0xfde1, 0xed47
   dc.w 0xed4f, 0xd1e1
   dc.w 0xf108, 0xd9c1
   dc.w 0xd1e1, 0xf1f9
   dc.w 0xf3ed, 0x5636
   dc.w 0xe9e9, 0x8104
   dc.w 0x8f01

PSGData:
   dc.w 0x9fbf, 0xdfff
   
; Initial register values to be sent to VDP, thanks to Big Evil Corporation
VDP_Init_Reg_Vals:
   dc.b 0x04 ; 0: Horiz. interrupt on, plus bit 2 (unknown, but docs say it needs to be on). Palette mode
   dc.b 0x74 ; 1: Vert. interrupt on, display on, DMA on, V28 mode (28 cells vertically), + bit 2
   dc.b 0x30 ; 2: Pattern table for Scroll Plane A at 0xC000 (bits 3-5)
   dc.b 0x20 ; 3: Pattern table for Window Plane at 0x8000 (bits 1-5)
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
   
;UpdatePointers:
;   dc.l UpdateStart
;   dc.l UpdateAim
   
   
	EVEN
BlankPattern:

	dc.l 0x00000000	; Nothing 
	dc.l 0x00000000
	dc.l 0x00000000
	dc.l 0x00000000
	dc.l 0x00000000
	dc.l 0x00000000
	dc.l 0x00000000
	dc.l 0x00000000
   
    ; CODE includes 
   	INCLUDE "source/constants.asm"
    INCLUDE "source/palette.asm"
	INCLUDE "source/util.asm"
	INCLUDE "source/start.asm"
	INCLUDE "source/init.asm"
	INCLUDE "source/game.asm"
	INCLUDE "source/tables.asm"
	INCLUDE "source/ball.asm"
    INCLUDE "source/peg.asm"
    INCLUDE "source/rect.asm"
	
	; TILE includes 
	EVEN
	INCLUDE "tiles/title.asm"
	INCLUDE "tiles/red_peg.asm"
	INCLUDE "tiles/blue_peg.asm"
	INCLUDE "tiles/green_peg.asm"
	INCLUDE "tiles/purple_peg.asm"
	INCLUDE "tiles/saver.asm"
	
	; MAP includes 
	EVEN 
	INCLUDE "maps/title.asm"
	
	; Level includes 
	EVEN 
	INCLUDE "levels/level0.asm"
	INCLUDE "levels/levels.asm"
	
	; BSS addresses 
	INCLUDE "source/bss.asm"
	

__end    ; Very last line, end of ROM address