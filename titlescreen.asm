 rt = $0340
 
          ;Init necessary hardware. Disable 
          ;interrupts 
          
          lda #$35
          sta $01
titlescreen         
          sei
          ldx #$48
          ldy #$ff
          lda #$81
          stx $fffe
          sty $ffff
          sta $dc0d
          sta $dd0d
          lda #$00 ;Switch screen off during drawing 
          sta $d011
          sta $d019
          sta $d01a
                   ;black screen
          lda #$00
          sta $d020
          sta $d021
          sta firebutton
          lda #$18
          sta $d016 
          lda #$1a
          sta $d018
          lda #$00
          sta $d015
          lda #$07
          sta $d022
          lda #$06
          sta $d023

          lda #0
          sta screendelay
          sta screendelay+1
          sta screenpage 
          
          jsr drawcredits
            
          lda #3
          sta lives
          ldx #$00
clearrow
          lda #$20
          sta $0400,x
          inx 
          cpx #40
          bne clearrow
          ;Initialise the scroll text
          lda #<scrolltext
          sta messread+1
          lda #>scrolltext
          sta messread+2
          
          ;Setup the IRQ raster interrupts
          
          ldx #<irq1
          ldy #>irq1
          lda #$7f
          stx $fffe
          sty $ffff
          ldx #<nmi 
          ldy #>nmi 
          stx $fffa
          sty $fffb
          sta $dc0d
          sta $dd0d
          lda #$32 ;Init top raster position
          sta $d012
          lda #$1b  ;Restore the screen again
          sta $d011
          lda #$01 ;Enable IRQ sync
          sta $d019
          sta $d01a
          lda #0
          jsr musicinit
          cli
        
          ;After the interrupts have been setup jump to "titleloop"
          jmp titleloop
          
          
          ;Create double IRQ interrupt for scrolling message 
          ;and playing music
          
irq1      sta tstacka1+1
          stx tstackx1+1
          sty tstacky1+1
          asl $d019    
          lda $dc0d
          sta $dd0d
          lda #$2e
          sta $d012
          
          lda xpos
          sta $d016 
          ldx #<irq2
          ldy #>irq2
          stx $fffe
          sty $ffff
tstacka1  lda #$00
tstackx1  ldx #$00
tstacky1  ldy #$00          
          rti
          
irq2      sta tstacka2+1
          stx tstackx2+1
          sty tstacky2+1
          inc $d019 
          lda #$f0
          sta $d012
          lda #$18
          sta $d016
          lda #$01
          sta rt
          jsr musicplayer
          ldx #<irq1
          ldy #>irq1
          stx $fffe
          sty $ffff
tstacka2  lda #$00
tstackx2  ldx #$00
tstacky2  ldy #$00          
          rti
          
musicplayer 
          lda system
          cmp #1
          beq pal
          inc ntsctimer
          lda ntsctimer
          cmp #6
          beq resetntsc
pal       jsr musicplay
          rts
resetntsc lda #0
          sta ntsctimer
          rts
          
          ;Body of title loop
titleloop 
         
          lda #0
          sta rt 
          cmp rt
          beq *-3
          jsr scroller
           jsr washroutine
          jsr animator
          jsr pageswapper
          jsr animchr
          lda $dc00 
          lsr
          lsr
          lsr
          lsr
          lsr 
          bit firebutton
          ror firebutton
          bmi titleloop
          bvc titleloop
          jmp gamestart

          ;Main code for scrolling text
scroller          
          lda xpos 
          sec 
          sbc #2
          and #7
          sta xpos
          bcs exitscr
          ldx #$00
scrshift  lda $07c1,x
          sta $07c0,x
          inx
          cpx #$27
          bne scrshift
messread  lda scrolltext  
          cmp #$00
          bne storechr
          lda #<scrolltext
          sta messread+1
          lda #>scrolltext
          sta messread+2
          jmp messread
storechr  sta $07e7
          inc messread+1
          bne exitscr
          inc messread+2
exitscr   rts 
          
washroutine
          jsr swapcolours
          lda cwdelay 
          cmp #3
          beq washnow
          inc cwdelay 
          rts 
washnow   lda #0
          sta cwdelay
          
          ldx cwpointer
          lda colourtable,x
          sta $dbe7 
          inx
          cpx #colourtableend-colourtable 
          beq resetflash
          inc cwpointer 
          rts
resetflash 
          ldx #0
          stx cwpointer
          rts
          
swapcolours 
          ldx #0
swaploop  lda $dbc1,x
          sta $dbc0,x
          inx
          cpx #$27
          bne swaploop
          rts
          
pageswapper
          
          inc screendelay
          lda screendelay
          cmp #$fa
          beq .waitalittlemore
          rts
.waitalittlemore          
          lda #0
          sta screendelay
          lda screendelay+1
          cmp #$02
          beq flip
          inc screendelay+1
          rts
flip      lda #0
          sta screendelay+1
          lda screenpage
          beq drawcredits
          jmp displayhiscore
          
drawcredits
              ;Draw the title screen 
          ldx #$00
.drawtitle
          lda titlescreendata+40,x
          sta $0400+40,x
          lda titlescreendata+$100,x
          sta $0500,x
          lda titlescreendata+$200,x
          sta $0600,x
          lda titlescreendata+$2e8-40,x
          sta $06e8-40,x 
          lda titlecolourdata,x
          sta $d800,x
          lda titlecolourdata+$100,x
          sta $d900,x
          lda titlecolourdata+$200,x
          sta $da00,x
          lda titlecolourdata+$2e8-40,x
          sta $dae8-40,x
          inx
          bne .drawtitle
          lda #1
          sta screenpage
          rts
          
            ;Draw the hall of fame
displayhiscore            
          ldx #$00
.drawhiscore 
          lda hiscreendata+40,x
          sta $0400+40,x
          lda hiscreendata+$100,x
          sta $0500,x
          lda hiscreendata+$200,x
          sta $0600,x
          lda hiscreendata-40+$2e8,x
          sta $06e8-40,x
          lda hicolourdata+40,x
          sta $d800+40,x
          lda hicolourdata+$100,x
          sta $d900,x
          lda hicolourdata+$200,x
          sta $da00,x
          lda hicolourdata+$2e8-40,x
          sta $dae8-40,x
          inx
          bne .drawhiscore
          
          ;Copy all hi score and names to the screen
          ldx #$00
.copynames lda name1,x
          sta namepos,x
          lda name2,x
          sta namepos+40,x
          lda name3,x
          sta namepos+80,x
          lda name4,x
          sta namepos+120,x
          lda name5,x
          sta namepos+160,x
          lda name6,x
          sta namepos+200,x
          lda name7,x
          sta namepos+240,x
          lda name8,x
          sta namepos+280,x
          lda name9,x
          sta namepos+320,x 
          lda name10,x
          sta namepos+360,x
          inx
          cpx #9
          bne .copynames
          ldx #$00
.copyscores          
          lda hiscore1,x
          sta scoreposhi,x
          lda hiscore2,x
          sta scoreposhi+40,x
          lda hiscore3,x
          sta scoreposhi+80,x
          lda hiscore4,x
          sta scoreposhi+120,x
          lda hiscore5,x 
          sta scoreposhi+160,x
          lda hiscore6,x
          sta scoreposhi+200,x
          lda hiscore7,x
          sta scoreposhi+240,x
          lda hiscore8,x
          sta scoreposhi+280,x
          lda hiscore9,x 
          sta scoreposhi+320,x
          lda hiscore10,x
          sta scoreposhi+360,x
          inx
          cpx #6
          bne .copyscores
          lda #0
          sta screenpage
          rts
          
          
;Pointers for the title code 
          
xpos      !byte 0          ;Smoothness position for the scrolling message
firebutton !byte 0          
cwdelay !byte 0
cwpointer !byte 0
screendelay !byte 0,0
screenpage !byte 0,0

colourtable !byte $06,$04,$03,$01,$03,$04
colourtableend !byte 0

!ct scr
welldonetext 
             !text "     well done you are in the top 10    "
             !text "        please enter your name          "
             !text "         for the hall of fame           "
             
hiscorestart             
hiscore1 !text "090000"
name1 !text "presented"             
hiscore2 !text "080000"
name2 !text "for you  "
hiscore3 !text "070000"
name3 !text "by       "
hiscore4 !text "060000"
name4 !text "tnd games"
hiscore5 !text "050000"
name5 !text "for      "
hiscore6 !text "040000"
name6 !text "the all  "
hiscore7 !text "030000"
name7 !text "new      "
hiscore8 !text "020000"
name8 !text "zzap     "
hiscore9 !text "010000"
name9 !text "sixty    "
hiscore10 !text "005000"
name10 !text "four     "
hiscoreend

hslo !byte <hiscore1,<hiscore2,<hiscore3,<hiscore4,<hiscore5,<hiscore6,<hiscore7,<hiscore8,<hiscore9,<hiscore10
hshi !byte >hiscore1,>hiscore2,>hiscore3,>hiscore4,>hiscore5,>hiscore6,>hiscore7,>hiscore8,>hiscore9,>hiscore10
nmlo !byte <name1,<name2,<name3,<name4,<name5,<name6,<name7,<name8,<name9,<name10
nmhi !byte >name1,>name2,>name3,>name4,>name5,>name6,>name7,>name8,>name9,>name10
