	IF ~DEF(RED_PEGS_TILES)
RED_PEG_TILES SET 1

RED_PEG_TILES_WIDTH EQU $1
RED_PEG_TILES_HEIGHT EQU $1

RedPegTiles:
	dc.l	$00222200
	dc.l	$02111120
	dc.l	$21111112
	dc.l	$21111112
	dc.l	$21111112
	dc.l	$21111112
	dc.l	$02111120
	dc.l	$00222200

	ENDC 