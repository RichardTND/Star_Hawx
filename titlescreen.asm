
!ifdef justplaygame {          
          ;Title screen code
          jmp gamestart
}
          
          ;Init necessary hardware. Disable 
          ;interrupts 
          
          sei
          lda #$35
          sta $01
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
          stx $fffe
          sty $ffff
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
          
irq1      pha
          txa
          pha
          tya
          pha
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
          pla
          tay
          pla
          tax
          pla
          rti
          
irq2      pha
          txa
          pha
          tya
          pha
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
          pla 
          tay
          pla
          tax
          pla
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
          
;Pointers for the title code 
          
xpos      !byte 0          ;Smoothness position for the scrolling message
rt        !byte 0          ;Sync timer
firebutton !byte 0          
!align $ff,0
          
          !ct scr

scrolltext !text " ... greetings arcade fans, welcome to *** s t a r  h a w x *** ...   a fun quick little arcade creation "
           !text "...   programming, graphics, sound effects and music by richard bayliss (original music by roy fielding) ... (c) 2021 the new dimension "
           !text "...   this is a fun galaxians style shoot 'em up ...    a fleet of evil space hawx have entered the "
           !text "galaxy and has put all the neighbouring planets into turmoil ...   your mission is to move your ship at the "
           !text "bottom of the screen and fire lasers into their butts ...   one hit and they are gone ...   watch out ...   at times "
           !text "the space hawx will attempt to attack your ship ...   move it out the way if you can ...   once all of the space hawx "
           !text "have gone, a new fleet of the same group will appear, but the game will get harder ...   "
           !text "watch out for the green eggs ...   if you shoot those you will score a mystery bonus ...   "
           !text "avoid collision with the space hawx, eggs or their bullets ...   controls: joystick in port 2 ...   left/right moves "
           !text "ship, and fire button fires a laser bullet ...   press fire to play ...                                               "
           !byte 0
