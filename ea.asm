        processor 6502
        org $0700-6
        HEX     ff ff 00 07 00 07

        ;; wait for number seconds in {1}
        ;; no more than 255/60 seconds possible
        mac sleep

        lda #60*{1}               ;seconds
        jsr Wait

        endm
        
        ; write 16 bit address to dest
        ;;; (source,dest)
        mac store16
        lda #[{1}] & $ff    ; load low byte
        sta {2}             ; store low byte
        lda #[{1}] >> 8     ; load high byte
        sta [{2}]+1         ; store high byte
        endm
       ;; compare word in {1} with {2}
        mac cmp16
        lda {1}+1
        cmp {2}+1
        bne .done
        lda {1}
        cmp {2}
.done        
        endm

        mac cmp16Im

        lda {1}+1
        cmp #{2} >> 8     ; load high byte
        bne .done
        lda {1}
        cmp #[{2}] & $ff    ; load low byte
.done        
        endm

        mac move16

        lda [{1}]
        sta [{2}]
        lda [{1}]+1
        sta [{2}]+1

        endm

        ;; 16 bit add {1}+{2} result in {1}
        mac add16

        clc                     ;Ensure carry is clear
        lda [{1}]+0             ;Add the two least significant bytes
        adc [{2}]+0             ;
        sta [{1}]+0             ;... and store the result
        lda [{1}]+1             ;Add the two most significant bytes
        adc [{2}]+1             ;... and any propagated carry bit
        sta [{1}]+1             ;... and store the result    clc
        
        endm

        ;; {1} + {2} -> {1}
        mac add16Im

        clc
        lda {1}
        adc #[{2}]&$ff
        sta {1}
        lda {1}+1
        adc #[{2}]>>8
        sta {1}+1

        endm

        mac inc16
        inc [{1}]+0
        bne .done
        inc [{1}]+1
.done
        endm

;; EQUATES
P0HGT   equ       7            ;player 0 height ( 0 based )
MYPMB   equ       $1200
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

ZPSTRT  equ       $80
W0      equ       ZPSTRT+0
W1      equ       W0+2          ;PTR
P0Y     equ       W1+2
P0X     equ       P0Y+1
;; MAIN

        jsr SetPMG
        ;; install sys timer2 routine
        store16 MoveAll,CDTMA2
        
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
        ;; power pellet
        dc.b %00000000
        dc.b %00011000
        dc.b %00111100
        dc.b %00111100
        dc.b %00111100
        dc.b %00111100
        dc.b %00011000
        dc.b %00000000
