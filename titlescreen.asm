 rt = $0340
 
          ;Init necessary hardware. Disable 
          ;interrupts 
          lda #$35
          sta $01
          
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

          ;Draw the title screen 
          ldx #$00
.drawtitle
          lda titlescreendata,x
          sta $0400,x
          lda titlescreendata+$100,x
          sta $0500,x
          lda titlescreendata+$200,x
          sta $0600,x
          lda titlescreendata+$2e8,x
          sta $06e8,x 
          lda titlecolourdata,x
          sta $d800,x
          lda titlecolourdata+$100,x
          sta $d900,x
          lda titlecolourdata+$200,x
          sta $da00,x
          lda titlecolourdata+$2e8,x
          sta $dae8,x
          inx
          bne .drawtitle
          
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
          jsr musicplay
          ldx #<irq1
          ldy #>irq1
          stx $fffe
          sty $ffff
tstacka2  lda #$00
tstackx2  ldx #$00
tstacky2  ldy #$00          
          rti
          
          
          ;Body of title loop
titleloop 
         
          lda #0
          sta rt 
          cmp rt
          beq *-3
          jsr scroller
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
          sbc #1
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
          
;Pointers for the title code 
          
xpos      !byte 0          ;Smoothness position for the scrolling message
firebutton !byte 0          
!align $ff,0
          
          !ct scr

scrolltext !text "*** star hawx *** ...    code, graphics, sound effects and music by richard bayliss ...   (c)2021 the new dimension ... "
           !text "plug a joystick into port 2 ...   move your ship left/right and blast all of those evil star hawx into oblivion with your "
           !text "armed spaceship ...   scoring is based on the type of enemy you blast ...   if an enemy, their weapon or the bonus eggs collide into your ship, you will lose a life ...   you only have "
           !text "3 lives at your disposal ...   keep on blasting those star hawx and score as many points as you possibly can ...   good luck ...    press fire to play ...          "
           !byte 0
          
           !byte 0
