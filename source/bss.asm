Pegs EQU ADDR_WORK_RAM 
Ball EQU (Pegs+MAX_PEGS*PEG_DATA_SIZE)
Saver EQU (Ball+BALL_DATA_SIZE)

; All global variables are assumed to be longs even if not
; used as such in the program.
ButtonsDown EQU (Saver+SAVER_DATA_SIZE)
GameState EQU (ButtonsDown+4)
VblankFlag EQU (GameState+4)
AimAngle EQU (VblankFlag+4)
Level EQU (AimAngle+4) 
BallCount EQU (Level+4)

