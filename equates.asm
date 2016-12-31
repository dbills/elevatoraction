;; EQUATES
P0HGT   equ       7            ;player 0 height ( 0 based )
PMBASE  equ       $D407         ;54279
SDMCTL  equ       $22F          ;559
GRATCL  equ       $D01D         ;53277
SIZEP0  equ       $D008         ;53256
HPOS0   equ       $D000         ;53248
PCOLR0  equ       $2C0          ;704
JIFFYH  equ       18       
JIFFYM  equ       19
JIFFYL  equ       20
STICK0  equ       632
CDTMV1  equ       $218          ;system timer1
CDTMV2  equ       $21a          ;system timer2
CDTMA2  equ       $228          ; timer2 addr
SETVBV  equ       $e45c
SDLST   equ       $230          ;dlist shadow
NMIEN   equ       $d40e         ;nmi enable
;
; Equates
;
; Without these, the program won't assemble properly
;
ICCOM  equ  $342		; the COMMAND byte in the IOCB
ICBAL  equ  $344		; the low byte of the buffer address (filename)
ICBLL  equ  $348		; the low byte of the buffer length
ICAX1  equ  $34A		; auxiliary byte 1: type
ICAX2  equ  $34B		; auxiliary byte 2: mode
;
CIO     equ  $E456		; Central Input/Output routine
ROWCRS  equ  84		; ROW CuRSor—y position
COLCRS  equ  85		; COLumn CuRSor—x position
ATACHR  equ  763		; where line color goes for DRAWTO
