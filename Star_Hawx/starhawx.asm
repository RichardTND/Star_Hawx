;========================================
;
;               STAR HAWX
;
;         A fun arcade variant by 
;
;            Richard Bayliss
;
;       (c) 2021 The New Dimension
;
;=========================================
;Variables and pointers

titlescreendata = $3000 
titlecolourdata = $33e8 
gamescreendata = $3800
gamecolourdata = $3be8

;Music pointers
musicinit = $1000
musicplay = $1003 

          ;Generate program

          !to "spacehawx.prg",cbm
          
          ;Generate BASIC SYS address (2064, Front end) 
          *=$0801
          !basic (2064)
;=========================================
          *=$0810
          ;Title screen code
          
          ;Init necessary hardware. Disable 
          ;interrupts 
          
          sei
          ldx #$31
          ldy #$ea
          lda #$81
          stx $0314
          sty $0315
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
          stx $0314
          sty $0315
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
          
irq1      inc $d019    
          lda $dc0d
          sta $dd0d
          lda #$2e
          sta $d012
          lda xpos
          sta $d016 
          ldx #<irq2
          ldy #>irq2
          stx $0314
          sty $0315
          jmp $ea7e
          
irq2      inc $d019 
          lda #$f0
          sta $d012
          lda #$18
          sta $d016
          lda #$01
          sta rt
          jsr musicplay
          ldx #<irq1
          ldy #>irq1
          stx $0314
          sty $0315
          jmp $ea7e
          
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

scrolltext !text " *** s t a r   h a w x *** ...   yet another fun early 1980s style arcade game ...    code, graphics and "
           !text "sound effects by richard bayliss ...   (c) 2021 the new dimension ...   "
           !text "use joystick in port 2 ...   save the galaxy by blasting away space hawx one wave after "
           !text "another ...   at first the space hawx will hover above their forcefield, but after a while "
           !text "there is a good chance that the aliens will attempt to escape and try to attack your ship ...   "
           !text "shoot down the spacehawx with your lasers ...   also shoot green eggs for bonus points ...   "
           !text "for every wave cleared, the game will get a bit more harder ...   "
           !text "left/right = control space ship ...   fire = shoot laser ...   press - fire to start - ...   "
        
           !byte 0

;=========================================          
          *=$1000
          ;Insert music
          !bin "bin\music.prg",,2
;=========================================          
          *=$2000
          ;Insert sprites
;=========================================
          *=$2800
          ;Import charset data 
          !bin "bin\charset.chr"
;=========================================
          ;Import title screen data
          *=$3000
          !bin "bin\titlescreen.bin"
          ;Import game screen data
          *=$3800
          !bin "bin\gamescreen.bin"
;=========================================          
          ;Game code
          *=$4000
gamestart
          ;Like with the front end switch 
          ;off all interrupts 
          sei
          ldx #$31
          ldy #$ea
          lda #$81
          stx $0314
          sty $0315
          sta $dc0d
          sta $dd0d
          lda #$00
          sta $d011
          sta $d01a
          sta $d019 
          ldx #$00
clearsid  lda #$00
          sta $d3ff,x
          inx
          cpx #$19
          bne clearsid
          sta firebutton
          ;Draw game screen 
          
          ldx #$00
drawgame  lda gamescreendata,x
          sta $0400,x
          lda gamescreendata+$100,x
          sta $0500,x
          lda gamescreendata+$200,x
          sta $0600,x
          lda gamescreendata+$2e8,x 
          sta $06e8,x 
          lda gamecolourdata,x 
          sta $d800,x
          lda gamecolourdata+$100,x
          sta $d900,x
          lda gamecolourdata+$200,x
          sta $da00,x
          lda gamecolourdata+$2e8,x
          sta $dae8,x
          inx
          bne drawgame
          
          lda #$1b
          sta $d011
          jmp *
          
!ct scr
getreadytext !text "  get ready  "
gameovertext !text "  game over  "
wavecleartext!text " wave clear! "
completetext !text "   you win   "
