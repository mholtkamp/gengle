	IF ~DEF(SAVER_TILES)
SAVER_TILES SET 1 

SAVER_TILES_WIDTH   EQU $4
SAVER_TILES_HEIGHT	EQU $2

SaverTiles:
* --------------------------
	dc.l	$00000000
	dc.l	$00000000
	dc.l	$00000000
	dc.l	$00000000
	dc.l	$00000000
	dc.l	$00000000
	dc.l	$F0000000
	dc.l	$FF000000

* --------------------------
	dc.l	$FFF00000
	dc.l	$FFFEEEEE
	dc.l	$FFF00E00
	dc.l	$FFFEEEEE
	dc.l	$FFF00E00
	dc.l	$FFFEEEEE
	dc.l	$FFFFFFFF
	dc.l	$0FFFFFFF

* --------------------------
	dc.l	$00000000
	dc.l	$00000000
	dc.l	$00000000
	dc.l	$00000000
	dc.l	$00000000
	dc.l	$00000000
	dc.l	$00000000
	dc.l	$00000000

* --------------------------
	dc.l	$00000000
	dc.l	$EEEEEEEE
	dc.l	$E00E00E0
	dc.l	$EEEEEEEE
	dc.l	$E00E00E0
	dc.l	$EEEEEEEE
	dc.l	$FFFFFFFF
	dc.l	$FFFFFFFF

* --------------------------
	dc.l	$00000000
	dc.l	$00000000
	dc.l	$00000000
	dc.l	$00000000
	dc.l	$00000000
	dc.l	$00000000
	dc.l	$00000000
	dc.l	$00000000

* --------------------------
	dc.l	$00000000
	dc.l	$EEEEEEEE
	dc.l	$0E00E00E
	dc.l	$EEEEEEEE
	dc.l	$0E00E00E
	dc.l	$EEEEEEEE
	dc.l	$FFFFFFFF
	dc.l	$FFFFFFFF

* --------------------------
	dc.l	$00000000
	dc.l	$00000000
	dc.l	$00000000
	dc.l	$00000000
	dc.l	$00000000
	dc.l	$00000000
	dc.l	$0000000F
	dc.l	$000000FF

* --------------------------
	dc.l	$00000FFF
	dc.l	$EEEEEFFF
	dc.l	$00E00FFF
	dc.l	$EEEEEFFF
	dc.l	$00E00FFF
	dc.l	$EEEEEFFF
	dc.l	$FFFFFFFF
	dc.l	$FFFFFFF0

* --------------------------

	ENDC 
