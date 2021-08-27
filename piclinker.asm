;Star Hawx picture linker (For disk version only)

vid = $3f40
col = $4328
bg = $4710
!to "piclinker.prg",cbm
  *=$0801
  !basic 2061
  
  *=$080d
  jsr detectmode
  sei

  lda #$00
  sta $d011
  sta ntsctimer
  ldx #$00
.draw
  lda vid,x
  sta $0400,x
  lda vid+$100,x
  sta $0500,x
  lda vid+$200,x
  sta $0600,x
  lda vid+$2e8,x
  sta $06e8,x
  lda col,x
  sta $d800,x
  lda col+$100,x
  sta $d900,x
  lda col+$200,x
  sta $da00,x
  lda col+$2e8,x
  sta $dae8,x
  inx
  bne .draw
  lda bg
  sta $d020
  sta $d021
  ldx #<irq
  ldy #>irq
  stx $0314
  sty $0315
  lda #$2e
  sta $d012
  lda #$7f
  sta $dc0d
  sta $dd0d
  lda #$3b
  sta $d011
  lda #$01
  sta $d019
  sta $d01a
  lda #0
  jsr $1000
  cli
  lda #$18
  sta $d018
  sta $d016
  lda #$03
  sta $dd00
.loop  
  lda #16
  bit $dc01
  bne .loop1
  jmp exit
.loop1
  lda #16
  bit $dc00
  bne .loop
exit  
  lda #$0b 
  sta $d011
  sei
  lda #$00
  sta $d019
  sta $d01a
  lda #$81
  sta $dc0d
  sta $dd0d
  ldx #$31
  ldy #$ea
  stx $0314
  sty $0315
  ldx #$00
.silence
  lda #$00
  sta $d400,x
  inx
  cpx #$18
  bne .silence
  lda #$14
  sta $d018
  lda #$08
  sta $d016
  ldx #$00
.copytransfer
  lda transfer,x
  sta $0400,x
  lda #$00
  sta $d800,x
  sta $d900,x
  sta $da00,x
  sta $dae8,x
  inx 
  bne .copytransfer
  lda #$1b 
  sta $d011 
  lda #0
  sta $0800
  cli
  jmp $0400
transfer 
  sei
  lda #$34
  sta $01
.loop2
  ldx #$00
.loop3
  lda $4800,x
  sta $0801,x
  inx
  bne .loop3
  inc $0409
  inc $040c
  lda $0409
  bne .loop2
  lda #$37
  sta $01
  cli
  jmp $080d
  
  
  
irq 
    inc $d019
    lda $dc0d
    sta $dd0d
    lda #$f8
    sta $d012
    jsr musicplayer
    jmp $ea7e
    
musicplayer
   
  lda system
  cmp #1
  beq pal
  inc ntsctimer
  lda ntsctimer
  cmp #6
  bne pal
  jmp resetzaxtime
pal jsr $1003
  rts
resetzaxtime
  lda #0
  sta ntsctimer
  rts
  
    
detectmode
    lda $02a6
    sta system
    rts
system !byte 0
ntsctimer !byte 0
  
*=$1000
    !bin "starhawxloadertune.prg",,2
*=$2000
    !bin "starhawxpic.prg",,2
*=$4800
    !bin "starhawx.prg",,2
  