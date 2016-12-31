        processor 6502
        org $0700-6
        HEX     ff ff 00 07 00 07

        INCLUDE "macros.asm"
        INCLUDE "equates.asm"



ZPSTRT  equ       $80
W0      equ       ZPSTRT+0
W1      equ       W0+2          ;PTR
P0Y     equ       W1+2
P0X     equ       P0Y+1
S0      equ       P0X+1
;; MAIN
        ;jsr SetPMG
        ;; install sys timer2 routine
        ;store16 MoveAll,CDTMA2
        ;; install DLIST

        move16 SDLST,W1
        
        disvbi        
        store16 MYDL,SDLST
        envbi

        sleep 1
        sleep 1
        sleep 1
        sleep 1
        sleep 1


        disvbi
        move16 W1,SDLST
        envbi

        brk
        
        lda #$80
        sta P0X
        sta P0Y
        lda #60
        sta CDTMV2
.1
        jmp .1 
        rts

MoveAll SUBROUTINE      
        jsr ReadJoy
        lda P0X 
;        sta 712
        sta HPOS0               
        ldy P0Y 
        jsr DrawP
        lda #1
        sta CDTMV2
        rts


SetPMG SUBROUTINE        
        lda #$12
        sta PMBASE

        ;; clear all PM ram
        store16 MYPMB+$200,W0
        store16 MYPMB+$400,W1
        ldy #0
.0        
        lda #129
        sta (W0),y
        inc16 W0
        cmp16 W0,W1
        bne .0

        ;; turn on DMA, set color and position
        lda SDMCTL
        ora #24
        sta SDMCTL
        lda #3
        sta GRATCL
        lda #128
        sta HPOS0
        lda #88
        sta PCOLR0
        lda #0
        sta SIZEP0

        rts
        
Wait    SUBROUTINE
        clc
        adc JIFFYL
.gettime        
        cmp JIFFYL
        bne .gettime
        rts

;; Y = Y location ( at bottom )
;; Uses X,A
DrawP   SUBROUTINE
        ldx #P0HGT
.1
        lda MYPMB,x
        sta MYPMB+$200,y
        dey
        dex
        bpl .1
        rts
        
ReadJoy SUBROUTINE
        lda STICK0
        cmp #14
        beq .up
        cmp #13
        beq .down
        cmp #11
        beq .left
        cmp #7
        beq .right
        rts
.up
        inc P0Y
        rts
.left
        dec P0X
        rts
.right
        inc P0X
        rts
.down   
        dec P0Y
        rts

        org $1200
MYDL
        dc.b $70
        dc.b $70
        dc.b $70
        dc.b $4D
        dc.b SCREEN1&$ff
        dc.b SCREEN1>>8
        REPEAT 192/2-1
        dc.b $d                 ;graphics 7
        REPEND
        dc.b $41
        dc.b MYDL&$ff
        dc.b MYDL>>8
MYPMB
        org $1600
        ;; power pellet
        dc.b %00000000
        dc.b %00011000
        dc.b %00111100
        dc.b %00111100
        dc.b %00111100
        dc.b %00111100
        dc.b %00011000
        dc.b %00000000

        org $2000


SCREEN1
        REPEAT 40*96
        dc.b 1
        REPEND
ROWTBL
REPI set 0
        REPEAT 96
        dc.w SCREEN1 + 96 * REPI
REPI set REPI+1
        REPEND
