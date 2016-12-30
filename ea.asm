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

SMYPMB  equ       $80           ;PTR
W0      equ       $82
W1      equ       $84           ;PTR

foo:    
        jsr SetPMG
.1
        stx 712
        sleep 1
        inx
        jmp .1
        rts

SetPMG SUBROUTINE        
        store16 MYPMB,SMYPMB
        lda SMYPMB+1
        sta PMBASE

        ;; clear all PM ram
        move16 SMYPMB,W0
        store16 MYPMB+1024,W1
        ldy #0
.0        
        lda #129
        sta (W0),y
        inc16 W0
        cmp16 W0,W1
        bne .0

        ;; turn on DMA, set color and position
        lda #$2e
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

