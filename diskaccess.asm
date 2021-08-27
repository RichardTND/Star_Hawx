
dname:  !text "S:"
fname:  !text "--HALL OF FAME--"
fnamelen = *-fname
dnamelen = *-dname


SaveHiScore:
      
      jsr DisableInts 
    
      jsr savefile
SkipHiScoreSaver      
      lda #$35 
      sta $01

      jmp titlescreen
      
LoadHiScores:
      
      jsr DisableInts 
      jsr loadfile
SkipHiScoreLoader:
      lda #$35
      sta $01
      rts
DisableInts:
      sei 
      
      lda #$48 
      sta $fffe 
      lda #$ff 
      sta $ffff 
      lda #$31
      sta $0314
      lda #$ea
      sta $0315
      lda #0
      sta $d019 
      sta $d01a 
      sta $d015 
      lda #$81 
      sta $dc0d
      sta $dd0d
      ldx #$00 
clrsid:   lda #0 
      sta $d400,x
      inx
      cpx #$18 
      bne clrsid 
      lda #$0b 
      sta $d011 
      lda #$36 
      sta $01 
      cli 
      jsr $ff81 ;Init screen RAM
      jsr $ff84 ;Init CIA and IRQ
      lda #0
      sta $d020
      sta $d021
      rts 
      
savefile:
      ldx $ba
      cpx #$08 
      bcc skipsave 
      lda #$0f 
      tay
      jsr $ffba
      jsr resetdevice
      lda #dnamelen 
      ldx #<dname 
      ldy #>dname 
      jsr $ffbd 
      jsr $ffc0
      lda #$0f 
      jsr $ffc3 
      jsr $ffcc
      
      lda #$0f 
      ldx $ba 
      tay
      jsr $ffba 
      jsr resetdevice
      lda #fnamelen 
      ldx #<fname 
      ldy #>fname 
      jsr $ffbd 
      lda #$fb 
      ldx #<hiscorestart
      ldy #>hiscorestart
      stx $fb 
      sty $fc 
      ldx #<hiscoreend
      ldy #>hiscoreend
      jsr $ffd8
skipsave:
      rts
      
loadfile:
      ldx $ba 
      cpx #$08 
      bcc skipload 
      
      lda #$0f 
      tay 
      jsr $ffba 
      jsr resetdevice 
      lda #fnamelen 
      ldx #<fname 
      ldy #>fname
      jsr $ffbd
      lda #$00 
      jsr $ffd5 
      bcc loaded
      jsr savefile
loaded:
skipload: rts

resetdevice:
      lda #$01 
      ldx #<initdrive
      ldy #>initdrive
      jsr $ffbd 
      jsr $ffc0 
      lda #$0f 
      jsr $ffc3 
      jsr $ffcc
      rts
      
initdrive:
      !text "I:"

      rts