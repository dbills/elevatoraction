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
;; MAIN
        ;jsr SetPMG
        ;; install sys timer2 routine
        ;store16 MoveAll,CDTMA2
        ;; install DLIST

        lda SDLST               ;save existing DL
        pha
        lda SDLST+1
        pha

        store16 MYDL,SDLST

        sleep 1
        sleep 1
        sleep 1
        sleep 1
        sleep 1


        pla
        sta SDLST+1
        pla
        sta SDLST
        rts
        
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

;; atascii "S:"
SNAME:                          
        dc.b $53 
        dc.b $3A
        dc.b $9b
;
; CLOSE channel
;
; Parameter: X register holds IOCB number
; On exit: Y register holds error code
;
CLOSE   SUBROUTINE
        LDA #12                	; close command
        STA ICCOM,X		; in place
        JMP CIO			; do the real work

;
;
; OPEN channel,type,mode,file
;
; Parameters: X register holds IOCB number
;		 A register holds type
;		 Y register holds mode
;		 the address of the file/device
;		 name must already be set up
;		 in the IOCB–
; On exit:		Y register holds error code
;



OPEN     SUBROUTINE
        STA ICAX1,x		; the type value
        TYA 
        sta ICAX2,x
        LDA #3		; OPEN command
        sta ICCOM,x
        JMP CIO		; the real work
;
;
;GRAPHICS mode
;
;Parameter: A register holds desired mode
;On exit: Y register holds error code
;
GRAPHICS        SUBROUTINE
                PHA			; save the mode for a moment
                LDX #$60		; always use IOCB #6
                JSR CLOSE		; be sure it is closed
                LDX #$60		; the same IOCB again
                LDA #SNAME & $FF        ; the S device name
                sta ICBAL,x            ; must be put in place
                LDA #SNAME / $100	; before we go further
                STA ICBAL + 1,x	; (take this part on faith)
                PLA			; recover the GRAPHICS mode
                TAY			; put it where OPEN wants it
                AND #16 + 32            ; isolate the text window and no-clear bits
                EOR #16		; flip state of the text window bit
                ORA #12		; allow both input and output
                JMP OPEN		; do this part of the work
;
;
;PUT channel,byte
;
;Parameters: A register holds byte to output
;		 X register holds channel number
; On exit: Y register holds error code
;
PUT     SUBROUTINE
        TAY			; save the byte here for a moment
        LDA #0
        STA ICBLL,x		; $0000 to length
        STA ICBLL + 1,x	; as noted last month
        LDA #11		; the command value
        STA ICCOM,x
        TYA			; data byte back where CIO wants it
        JMP CIO
;
;
; byte = GET( channel )
;
; Parameter: X register holds IOCB number
;On exit: A register holds byte from GET call
;
GET     SUBROUTINE
        LDA #0
        STA ICBLL,x             ; $0000 to length…
        STA ICBLL + 1,x	; as noted last month
        LDA #7		; the command value
        STA ICCOM,x           ; where CIO wants it
        JMP CIO		; believe it or else, that's all
;
;
;PLOT x,y,color
;
; Parameters: A register holds color
;		 X register holds x location
;		 Y register holds y location
; NOTE: not for use with GR.8 or GR.24
;
PLOT    SUBROUTINE
        STX COLCRS		;see my August column
        STY ROWCRS		;these are just POKEs
        LDX #$60	          ;the S: graphics channel
        JMP PUT		;color is already in A
;
;
;byte = LOCATE( x,y )
;
;Parameters: X register holds x location
;		 Y register holds y location
;On exit: A register holds color of point at (x,y)
;
LOCATE  SUBROUTINE
        STX COLCRS		;again, see column
        STY ROWCRS		;from two months ago
        LDX #$60	          ;the S: graphics channel
        JMP GET		;color returned in A
;
;
;DRAWTO x, y, color
;
;Parameters: A register holds color
;		 X register holds x location
;	  Y register holds y location
; NOTE: not for use with GR.8 or GR.24
;
DRAWTO  SUBROUTINE
        STX COLCRS		; once more: see the article
        STY ROWCRS		; from two months ago
        STA ATACHR		; location 763, also in that article
        LDX #$60	          ; again, we use IOCB #6
        LDA #17		; the XIO number for DRAWTO
        STA ICCOM,x		; is actually the command number
        JMP CIO		; and that's all we really need to do

MYDL
        dc.b $70
        dc.b $70
        dc.b $70
        dc.b $4D
        dc.b SCREEN1&$ff
        dc.b SCREEN1>>8
        REPEAT 192/2
        dc.b $d                 ;graphics 7
        REPEND
        dc.b $41
        dc.b MYDL&$ff
        dc.b MYDL>>8

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

        org $1600
ROWTBL
REPI set 0
        REPEAT 96
        dc.w SCREEN1 + 96 * REPI
REPI set REPI+1
        REPEND

        org $2000
SCREEN1
        REPEAT 40*96
        dc.b 1
        REPEND
