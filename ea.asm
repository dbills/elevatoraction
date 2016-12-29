        processor 6502
        org $0700
        HEX ff ff 00 06 00 07
foo:    
        lda #2
        sta 712
        rts
        
