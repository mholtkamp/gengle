	IF ~DEF(PURPLE_PEG_TILES)
PURPLE_PEG_TILES SET 1 

PURPLE_PEG_TILES_WIDTH  EQU $2
PURPLE_PEG_TILES_HEIGHT EQU $2

PurplePegTiles:
* --------------------------
	dc.l	$00000888
	dc.l	$00088888
	dc.l	$00888777
	dc.l	$08877777
	dc.l	$08877777
	dc.l	$88777777
	dc.l	$88777777
	dc.l	$88777777

* --------------------------
	dc.l	$88777777
	dc.l	$88777777
	dc.l	$88777777
	dc.l	$08877777
	dc.l	$08877777
	dc.l	$00888777
	dc.l	$00088888
	dc.l	$00000888

* --------------------------
	dc.l	$88800000
	dc.l	$88888000
	dc.l	$77788800
	dc.l	$77777880
	dc.l	$77777880
	dc.l	$77777788
	dc.l	$77777788
	dc.l	$77777788

* --------------------------
	dc.l	$77777788
	dc.l	$77777788
	dc.l	$77777788
	dc.l	$77777880
	dc.l	$77777880
	dc.l	$77788800
	dc.l	$88888000
	dc.l	$88800000

* --------------------------

	ENDC