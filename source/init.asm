Init: 
	tst.w ADDR_MYSTERY_RESET
	bne .return
	tst.w ADDR_RESET
	bne .return

	; Write the TMSS if needed (this check borrowed from bigevilcorporation)
	move.b 0x00A10001, d0      ; grab genesis version number
	andi.b #0x0F, d0           ; The version is stored in last four bits, so mask it with 0F
	beq .skip                  ; If version is equal to 0, skip TMSS signature
	move.l #'SEGA', 0x00A14000 ; Move the string "SEGA" to 0xA14000
.skip
	
	; @@ TODO: Determine if I need to clear ram,
	; however this code below will trash stack.
	;Clear RAM
	;move.l #0, d0 
	;move.l #0, a0 
	;move.l #0x3fff, d1 
	
;.clear_ram_loop 
	;move.l d0, -(a0)
	;subq.l #1, d1
	;bne .clear_ram_loop 
	
	; Initialize VDP
	move.l #VDP_Init_Reg_Vals, a0 
	move.l #24, d0 
	move.l #0x00008000, d1 
	
.copyVDP_Reg
	move.b (a0)+, d1 	; move the register val into lowest byte of d1 
	move.w d1, ADDR_VDP_CONTROL 
	add.w #0x0100, d1 
	dbra d0, .copyVDP_Reg
	
	; Enable autoincrement as this will always be needed 
	move.w #(SET_VDP_REG_0F|2), ADDR_VDP_CONTROL	; Set autoincrement to 2 bytes
	
	move.w #0x8700, ADDR_VDP_CONTROL ; set background color to pal 0, color 8 
	
	; Initialize I/O 
	move.b #0, ADDR_CTRL1
	move.b #0, ADDR_CTRL2
	move.b #0, ADDR_EXP 
	
	; Load a blank tile, needed for clearing planes
	move.l #1, d0 
	lea BlankPattern, a0 
	move.l #0, a1 
	jsr LoadTiles
	
	; Load the game's tiles 
	move.l #(TITLE_TILES_COUNT), d0  ; param d0.l = tile count 
	lea TitleTiles, a0								    ; param a0.l = tile data pointer 
	move.l #(TITLE_TILE_INDEX*32), a1 				    ; param a1.l = vram address
	jsr LoadTiles
	
	move.l #(RED_PEG_TILES_WIDTH*RED_PEG_TILES_HEIGHT), d0 
	lea RedPegTiles, a0 
	move.l #(RED_PEG_TILE_INDEX*32), a1 
	jsr LoadTiles
	
	move.l #(BLUE_PEG_TILES_WIDTH*BLUE_PEG_TILES_HEIGHT), d0 
	lea BluePegTiles, a0 
	move.l #(BLUE_PEG_TILE_INDEX*32), a1 
	jsr LoadTiles
	
	move.l #(PURPLE_PEG_TILES_WIDTH*PURPLE_PEG_TILES_HEIGHT), d0 
	lea PurplePegTiles, a0 
	move.l #(PURPLE_PEG_TILE_INDEX*32), a1 
	jsr LoadTiles
	
	move.l #(GREEN_PEG_TILES_WIDTH*GREEN_PEG_TILES_HEIGHT), d0 
	lea GreenPegTiles, a0 
	move.l #(GREEN_PEG_TILE_INDEX*32), a1 
	jsr LoadTiles
	
	move.l #(SAVER_TILES_WIDTH*SAVER_TILES_HEIGHT), d0 
	lea SaverTiles, a0 
	move.l #(SAVER_TILE_INDEX*32), a1 
	jsr LoadTiles 
	
	; Load the game's palette
	move.l #1, d0 
	lea GamePalette, a0 
	jsr LoadPalette
	move.l #0, d0 
	lea (GamePalette+32), a0 
	jsr LoadPalette
	
	; Clearing scroll a plane map 
	move.l #ADDR_SCROLL_A_NAME_TABLE, a0 
	move.l #0, d0 
	jsr ClearMap
	
	; Clearing scroll b plane map 
	move.l #ADDR_SCROLL_B_NAME_TABLE, a0 
	move.l #0, d0 
	jsr ClearMap
	
	; Clearing window plane map 
	move.l #ADDR_WINDOW_NAME_TABLE, a0 
	move.l #0, d0 
	jsr ClearMap
	
.return 
	rts 