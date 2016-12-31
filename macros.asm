    ;; move word index by Y, does correct pointer
    ;; arithmetic for 'word'
    ;; move16y source[Y],dest
    mac move16y
    tya
    pha
    asl                         ; x*2 since it's a word
    tay
    lda [{1}],y
    sta [{2}]
    iny
    lda [{1}],y
    sta [{2}]+1
    pla
    tay
    endm
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
        ;; divide by 4 with remainder
        ;; {1} Remainder location
        ;; uses Y, Y=0 on exit
        mac div4

        ldy #0
        sty {1}
        lsr
        rol {1}                 ;build remainder
        lsr
        rol {1}                 ;build remainder
        
        endm