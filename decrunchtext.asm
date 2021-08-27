!to "starhawxdisk.prg",cbm

;Link the Exomizer SFX crunched program here
*=$0801
!bin "starhawx.exo",,2

;Black the screen 
lda #0
sta $d020
sta $d021
;-------------------------------
ldx #$00  ;If using KERNAL RAM, 
clrscrn   ;simply use JSR $E544 
lda #$20  ;instead of this
sta $0400,x
sta $0500,x
sta $0600,x
sta $06e8,x
inx
bne clrscrn
;--------------------------------

;The decrunch text output routine 

ldx #decrunchtextend-decrunchtext
maketext 
lda decrunchtext,x 
sta $0400,x ;or where ever you wish to place it
lda #$0f 
sta $d800,x 
dex
bpl maketext

;Always terminate with an RTS
rts 

!ct scr ;If using C64 studio

;The decrunch text
decrunchtext
!text "-=> brought to you by zzap 64 & tnd! <=-"
decrunchtextend
!byte 32