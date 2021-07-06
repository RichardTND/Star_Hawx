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

;Zero page pointers

screenlostore = $02
screenhistore = $03

;Sprite/char collision size

collisionwidth = 8
collisionheight = 32

;Value for each top hawk character (CHAR ID)

hawktype1a = 64
hawktype1b = 65
hawktype1c = 66 
hawktype1d = 67 

hawktype2a = 68 
hawktype2b = 69
hawktype2c = 70
hawktype2d = 71

hawktype3a = 72
hawktype3b = 73
hawktype3c = 74
hawktype3d = 75

hawktype4a = 76
hawktype4b = 77
hawktype4c = 78 
hawktype4d = 79

forcefieldleft = $2800 + (78*8)
forcefieldright = $2800 + (79*8)

;Title and game screen data
titlescreendata = $3000 
titlecolourdata = $33e8 
gamescreendata = $3800
gamecolourdata = $3be8

;Music pointers
musicinit = $1000
musicplay = $1003 

;Screen memory for each row of spacehawx

fleet1row1 = $0450
fleet1row2 = $0450+40
fleet2row1 = $04c8
fleet2row2 = $04c8+40
fleet3row1 = $0540
fleet3row2 = $0540+40
fleet4row1 = $05b8
fleet4row2 = $05b8+40

;Sprite X position boundary for both player 
;eggs, and swooping birds 

leftboundary = $0c
rightboundary = $9c

;Home X and Y position for player respawn 
playerhomeposx = $56
playerhomeposy = $e2

bullettopboundary = $1a

justplaygame = 1 ;Just launch game

          ;Generate program

          !to "starhawx.prg",cbm
          
          ;Generate BASIC SYS address (2064, Front end) 
          *=$0801
          !basic (2064)
;=========================================
          *=$0810
          
          ;Onetime anim backup grab 
          ldx #$00
backupchars
          lda $2800+(64*8),x
          sta hawk1backup1,x 
          lda $2800+(66*8),x
          sta hawk1backup2,x
          lda $2800+(68*8),x
          sta hawk2backup1,x
          lda $2800+(70*8),x
          sta hawk2backup2,x
          lda $2800+(72*8),x
          sta hawk3backup1,x
          lda $2800+(74*8),x
          sta hawk3backup2,x
          ;bottom layers
          lda $2800+(80*8),x
          sta hawk1backup3,x 
          lda $2800+(82*8),x
          sta hawk1backup4,x
          lda $2800+(84*8),x
          sta hawk2backup3,x
          lda $2800+(86*8),x
          sta hawk2backup4,x
          lda $2800+(88*8),x
          sta hawk3backup3,x
          lda $2800+(90*8),x
          sta hawk3backup4,x
          inx
          cpx #$10
          bne backupchars
          
          
          
!ifdef justplaygame {          
          ;Title screen code
          jmp gamestart
}
          
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

;=========================================          
          *=$1000
          ;Insert music
          !bin "bin\music.prg",,2
;=========================================          
          *=$2000
          ;Insert sprites
          !bin "bin\gamesprites.spr"
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
          sta $d021
          sta $d020
          
          lda #7
          sta $d022
          lda #6
          sta $d023
          lda #$18
          sta $d016 
          lda #$1a
          sta $d018
          
          ldx #$00
clearsid  lda #$00
          sta $d3ff,x
          inx
          cpx #$19
          bne clearsid
          sta firebutton
          ;Draw game screen 
          
          ;Setup IRQ raster interrupts
          ldx #$fb
          txs
          ldx #<girq1
          ldy #>girq1
          lda #$7f
          stx $0314
          sty $0315
          sta $dc0d
          sta $dd0d
          lda #$36
          sta $d012
          lda #$1b
          sta $d011
          lda #$01
          sta $d019
          sta $d01a
          lda #0
          jsr musicinit
          cli
          jmp gamerestart
          
          ;Main IRQ raster interrupt
girq1     inc $d019
          lda $dc0d
          sta $dd0d
          lda #$f8
          sta $d012
          lda #1
          sta rt
          jsr musicplay
          jmp $ea7e
          
gamerestart          
          
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
          
          ;Zero position all of the game sprites
          
          ldx #$00
zerospritepos
          lda #$00
          sta objpos,x
          inx
          cpx #16
          bne zerospritepos
          
          ;Force all sprites to be yellow, blue and red 
          ldx #$00
yelblured lda #$02
          sta $d027,x
          inx
          cpx #8 ;8 sprites in total will be used for game 
          bne yelblured
          
          ;Now setup sprite multi colour to match screen multicolour
          lda $d022
          sta $d025
          lda $d023
          sta $d026
          
          ;Setup player starting position 
          
          lda #playerhomeposx
          sta objpos
          lda #playerhomeposy
          sta objpos+1
          
          ;Setup player frame as ship 
          lda playership
          sta $07f8 ;Sprite0 = player ship 
          
          ;Now enable all of the sprites on screen
          ;including multicolour. But NO sprites 
          ;should be behind characters. Or expanded
          
          lda #$ff
          sta $d015
          sta $d01c
          lda #$00
          sta $d017
          sta $d01b
          sta $d01d
          
          lda #$56
          sta objpos+4
          lda #$40
          sta objpos+5
         
;-------------------------------------------          
;Main game loop control
;-------------------------------------------          
gameloop  lda #0
          sta rt
          cmp rt
          beq *-3
         
          jsr expandmsb
          jsr animator
          jsr spritemode
          jsr movehawx
          jsr playercontrol
          jsr playerbulletcontrol
          jsr bullettohawkchars
          jsr testswoop
          jmp gameloop
;--------------------------------------------
;Expand the game sprite position so that all
;sprites can move the whole screen

expandmsb 
          ldx #$00
eloop     lda objpos+1,x
          sta $d001,x
          lda objpos,x
          asl 
          ror $d010
          sta $d000,x 
          inx
          inx
          cpx #16 ;8x, * 8y, = 16 
          bne eloop
          rts
;--------------------------------------------          
          
;--------------------------------------------          
;Move those wretched space hawx
;--------------------------------------------
movehawx  ;jsr testswoopers
          lda fleetdelay
          cmp #2
          beq fleetdelayok
          inc fleetdelay
          rts
fleetdelayok
          lda #0
          sta fleetdelay
         
          lda fleetdir
          beq movefleetleft
          
          jmp movefleetright

          ;Move the entire hawk 
          ;fleet to the left of the screen
noshift1  rts
movefleetleft          
          lda fleetpos 
          sec
          sbc #1
          and #7
          sta fleetpos
          bcs noshift1
          jsr animfleet
          jmp shiftfleetback
noshift2  rts
          
          ;fleet to the right of the screen
movefleetright
          lda fleetpos
          sec
          sbc #1
          and #7
          sta fleetpos
          bcs noshift2
          jsr animfleet
          jmp shiftfleetforward
          rts
          
          ;Shift the entire fleet of space hawx 
          ;back each column

shiftfleetback ;Check for spacebar 
          
          lda fleet1row1+1
          jsr checkspacebarleft
          lda fleet1row2+1
          jsr checkspacebarleft
          lda fleet2row1+1
          jsr checkspacebarleft
          lda fleet2row2+1
          jsr checkspacebarleft
          lda fleet3row1+1
          jsr checkspacebarleft
          lda fleet3row2+1 
          jsr checkspacebarleft
          lda fleet4row1+1 
          jsr checkspacebarleft
          lda fleet4row2+1 
          jsr checkspacebarleft
          
          ldx #$00
pullbackhawx1char
          lda fleet1row1+1,x
          sta fleet1row1,x
          lda fleet1row2+1,x
          sta fleet1row2,x
          lda fleet2row1+1,x
          sta fleet2row1,x
          lda fleet2row2+1,x
          sta fleet2row2,x
          lda fleet3row1+1,x
          sta fleet3row1,x
          lda fleet3row2+1,x
          sta fleet3row2,x
          lda fleet4row1+1,x
          sta fleet4row1,x
          lda fleet4row2+1,x
          sta fleet4row2,x
          inx
          cpx #40
          bne pullbackhawx1char
          
          ;To avoid mess on the very first column, 
          ;replace the last character used with the 
          ;spacebar character. 
          
          lda #$20
          sta fleet1row1+39
          sta fleet1row2+39
          sta fleet2row1+39
          sta fleet2row2+39
          sta fleet3row1+39
          sta fleet3row2+39
          sta fleet4row1+39
          sta fleet4row2+39
         
          rts 
          
          ;Check if very first character for each fleet row is
          ;a space bar. If it is, then reverse the direction
          ;of the entire fleet.
        
checkspacebarleft
          cmp #$20
          beq skipdirswaptoright
          lda #1
          sta fleetdir
skipdirswaptoright          
          rts
          
shiftfleetforward
          lda fleet1row1+38
          jsr checkspacebarright 
          lda fleet1row2+38
          jsr checkspacebarright
          lda fleet2row1+38 
          jsr checkspacebarright
          lda fleet2row2+38
          jsr checkspacebarright
          lda fleet3row1+38
          jsr checkspacebarright
          lda fleet3row2+38
          jsr checkspacebarright 
          lda fleet4row1+38
          jsr checkspacebarright
          lda fleet4row2+38
          jsr checkspacebarright
          
          ;Shift the entire fleet of spacehawx 
          ;forward each column 
          ldx #39
pushforwardhawx1char
          lda fleet1row1-1,x 
          sta fleet1row1,x
          lda fleet1row2-1,x
          sta fleet1row2,x
          lda fleet2row1-1,x 
          sta fleet2row1,x
          lda fleet2row2-1,x
          sta fleet2row2,x
          lda fleet3row1-1,x
          sta fleet3row1,x
          lda fleet3row2-1,x
          sta fleet3row2,x
          lda fleet4row1-1,x
          sta fleet4row1,x
          lda fleet4row2-1,x 
          sta fleet4row2,x
          dex
          bpl pushforwardhawx1char
         
          ;Yet again.
          ;To avoid mess on the very first column, 
          ;replace the last character used with the 
          ;spacebar character. 
          
          
          lda #$20
          sta fleet1row1
          sta fleet1row2
          sta fleet2row1
          sta fleet2row2
          sta fleet3row1
          sta fleet3row2
          sta fleet4row1
          sta fleet4row2 
         
          rts

          ;Once again check for spacebar character 
          
checkspacebarright 

          cmp #$20
          beq skipdirswaptoleft
          lda #0
          sta fleetdir
skipdirswaptoleft          
          rts 

;Switch fleet animation - basically we swap enemy type objects 
;with other object types.

animfleet   lda animmode 
            beq switchfleetanim1
            jmp switchfleetanim2
            
switchfleetanim1
            ldx #$00
switchcharanim1
            lda hawk1backup2,x
            sta $2800+(64*8),x
            lda hawk1backup1,x
            sta $2800+(66*8),x
            lda hawk2backup2,x
            sta $2800+(68*8),x
            lda hawk2backup1,x
            sta $2800+(70*8),x
            lda hawk3backup2,x
            sta $2800+(72*8),x
            lda hawk3backup1,x
            sta $2800+(74*8),x
            lda hawk1backup4,x
            sta $2800+(80*8),x
            lda hawk1backup3,x
            sta $2800+(82*8),x
            lda hawk2backup4,x
            sta $2800+(84*8),x
            lda hawk2backup3,x
            sta $2800+(86*8),x
            lda hawk3backup4,x
            sta $2800+(88*8),x
            lda hawk3backup3,x
            sta $2800+(90*8),x
            inx
            cpx #16
            bne switchcharanim1
            lda #1
            sta animmode
            rts
            
checkchartype            
                        
            rts
            

switchfleetanim2
            ldx #$00
switchcharanim2
            lda hawk1backup1,x
            sta $2800+(64*8),x
            lda hawk1backup2,x
            sta $2800+(66*8),x
            lda hawk2backup1,x
            sta $2800+(68*8),x
            lda hawk2backup2,x
            sta $2800+(70*8),x
            lda hawk3backup1,x
            sta $2800+(72*8),x
            lda hawk3backup2,x
            sta $2800+(74*8),x
            lda hawk1backup3,x
            sta $2800+(80*8),x
            lda hawk1backup4,x
            sta $2800+(82*8),x
            lda hawk2backup3,x
            sta $2800+(84*8),x
            lda hawk2backup4,x
            sta $2800+(86*8),x
            lda hawk3backup3,x
            sta $2800+(88*8),x
            lda hawk3backup4,x
            sta $2800+(90*8),x
            inx
            cpx #16
            bne switchcharanim2
            lda #0
            sta animmode
            rts
                        
            
;----------------------------------------
;Player control 
;----------------------------------------
playercontrol

          ;Check joystick port 2, left 
checkjoyleft          
          lda #4 
          bit $dc00 
          bne checkjoyright
          
          ;Move player until it has 
          ;reached the very left position
          
          lda objpos
          sec
          sbc #2
          cmp #leftboundary
          bcs leftupdate
          lda #leftboundary
leftupdate 
          sta objpos
          jmp checkjoyfire 
          
          ;Check joystick port 2, right
checkjoyright          
          lda #8
          bit $dc00 
          bne checkjoyfire 
          
          ;Move player until it has 
          ;reached the very right position
          
          lda objpos
          clc
          adc #2
          cmp #rightboundary
          bcc rightupdate
          lda #rightboundary 
rightupdate
          sta objpos
          
          ;Check fire on joystick port 2
          
checkjoyfire           
          lda $dc00
          lsr
          lsr
          lsr
          lsr
          lsr
          bcs nocontrol
          
          ;Check bullet position
          lda objpos+2
          beq spawnnewbullet;position 0 = offset 
          jmp nocontrol
spawnnewbullet
          lda playerbullet
          sta $07f9
          lda objpos
          sta objpos+2
          lda objpos+1
          sta objpos+3
          
nocontrol
          rts          
;----------------------------------------
;Player bullet control          
;----------------------------------------

playerbulletcontrol

          lda objpos+2
          beq nocontrol
          lda objpos+3
          sec
          sbc #6
          cmp #bullettopboundary
          bcs storebullpos
          lda #$00
          sta objpos+2
storebullpos
          sta objpos+3
          rts
          

;-----------------------------------------
;Collision detection - Player bullet to 
;hawk chars
;-----------------------------------------

           jsr spritetosprite 
           
bullettohawkchars
           lda objpos+3
           sec
           sbc #collisionheight
           lsr
           lsr
           lsr
           tay
           lda screenlo,y 
           sta screenlostore
           lda screenhi,y
           sta screenhistore 
           
           lda objpos+2
           sec
           sbc #collisionwidth
           lsr
           lsr
           tay
           
           ldx #$03
           sty selfmodi+1
bgcloop    lda (screenlostore),y 
           cmp #hawktype1a
           bne nothawk1a 
           jmp killhawkleft
nothawk1a  cmp #hawktype1b 
           bne nothawk1b 
           jmp killhawkright 
nothawk1b  cmp #hawktype1c 
           bne nothawk1c 
           jmp killhawkleft 
nothawk1c  cmp #hawktype1d 
           bne nothawk1d
           jmp killhawkright
           
nothawk1d  cmp #hawktype2a
           bne nothawk2a 
           jmp killhawkleft 
nothawk2a  cmp #hawktype2b 
           bne nothawk2b 
           jmp killhawkright 
nothawk2b  cmp #hawktype2c 
           bne nothawk2c 
           jmp killhawkleft 
nothawk2c  cmp #hawktype2d 
           bne nothawk2d 
           jmp killhawkright 
nothawk2d           
           cmp #hawktype3a 
           bne nothawk3a 
           jmp killhawkleft 
nothawk3a  cmp #hawktype3b 
           bne nothawk3b
           jmp killhawkright
nothawk3b  cmp #hawktype3c 
           bne nothawk3c 
           jmp killhawkleft 
nothawk3c  cmp #hawktype3d 
           bne nothawk3d 
           jmp killhawkright 
nothawk3d
           
selfmodi   ldy #$00
           lda screenlostore
           clc
           adc #40
           sta screenlostore
           bcc skipmod 
           inc screenhistore
skipmod    dex 
           bne bgcloop
           rts
           
           ;Kill Star Hawk from left 
killhawkleft 
            lda #$20
            sta (screenlostore),y 
            iny 
            sta (screenlostore),y
            tya
            clc
            adc #40
            tay
            lda #$20 
            sta (screenlostore),y 
            dey 
            sta (screenlostore),y
            lda #0
            sta objpos+2
            rts 
              
            ;Hill Star Hawk from right 
killhawkright
            lda #$20 
            sta (screenlostore),y
            dey 
            sta (screenlostore),y 
            tya
            clc
            adc #40
            tay
            lda #$20
            sta (screenlostore),y 
            iny
            sta (screenlostore),y
            lda #0
            sta objpos+2
            rts
           
            ;Enemy sprite to sprite 
            ;collision 
            
spritetosprite 
            rts
;----------------------------------------
;Animatior - for game sprites and also 
;characters
;----------------------------------------

animator    jsr flashcolours
            lda animdelay
            cmp #4
            beq animmain
            inc animdelay
            rts
animmain    lda #0
            sta animdelay
            jsr animforcefield ;Animate forcefield chars
            ldx animpointer
            lda hawkanim1,x
            sta hawktype1spr
            lda hawkanim2,x
            sta hawktype2spr
            lda hawkanim3,x
            sta hawktype3spr
            inx
            cpx #2
            beq resethawkanim
            inc animpointer
            rts
resethawkanim
            ldx #0
            stx animpointer
            rts
            
            ;Animate the forcefield characters
            
animforcefield            
            ldx #$07
animfield   lda forcefieldleft,x
            asl
            rol forcefieldleft,x
            asl
            rol forcefieldleft,x
            lda forcefieldright,x
            lsr
            ror forcefieldright,x 
            lsr
            ror forcefieldright,x
            dex
            bpl animfield
            rts
            
            ;Flash the colour of the forcefield 
            
flashcolours 
            jsr paintforcefield
            ldx colourpointer
            lda colourtable1,x
            sta colourstore1
            lda colourtable2,x
            sta colourstore2
            inx
            cpx #colourtable1end-colourtable1 
            beq resetcolourflash
            inc colourpointer
            rts
resetcolourflash 
            ldx #0
            stx colourpointer
            rts
paintforcefield
            ldx #$00
paintloop   lda colourstore1
            sta $d800+40,x 
            lda colourstore2
            sta $d800+520,x
            inx
            cpx #$28
            bne paintloop
            rts

;----------------------------------
;Self-modifying sprite pointers 
;for space hawx.
;----------------------------------
            
spritemode
            jsr testhawk1
            jsr testhawk2
            jsr testhawk3
            jsr testhawk4
            jsr testbull
            jsr testegg
          
            rts
            
testhawk1
hawk1sm     lda hawktype1spr
            sta $07fa
            rts
testhawk2            
hawk2sm     lda hawktype2spr
            sta $07fb 
            rts
testhawk3            
hawk3sm     lda hawktype3spr
            sta $07fc
            rts
testhawk4            
hawk4sm     lda hawktype1spr
            sta $07fd 
            rts
testbull            
            lda hawkbullet
            sta $07fe 
            lda objpos+$0d
            clc
            adc #3
            sta objpos+$0d
            lda #$30
            sta objpos+$0c
            
            rts
testegg            
            lda bonusegg
            sta $07ff

            lda objpos+$0f 
            clc
            adc #4
            sta objpos+$0f 
            lda #$60
            sta objpos+$0e
            lda #$05
            sta $d02e
            rts
            
            
            
            
;----------------------------------------
;Test swooping hawks            
;----------------------------------------

testswoop 
            jsr testswoop1
            jsr testswoop2
            jsr testswoop3
            jsr testswoop4
            rts
            
;Macro code to make enemies fall

!macro configfall yposition {
          lda yposition
          clc
          adc #1
          sta yposition
          
}
  
            
;Macro code to test enemy direction and speed 

!macro confighawkswoop xdirection, positionx, speedx {
          
           lda xdirection
           cmp #1
           beq .shifthawkright 
           lda positionx
           sec
           sbc speedx
           cmp #leftboundary 
           bcs .leftok
           lda #1
           sta xdirection
           lda #leftboundary
.leftok    sta positionx
           rts 

.shifthawkright 
          lda positionx 
          clc
          adc speedx
          cmp #rightboundary 
          bcc .rightok 
          lda #0
          sta xdirection
          lda #rightboundary
.rightok  sta positionx          
          rts
           
}            
testswoop1  +configfall objpos+5
            +confighawkswoop enemy1dir, objpos+4, enemy1xspeed
testswoop2  +configfall objpos+7
            +confighawkswoop enemy2dir, objpos+6, enemy2xspeed
testswoop3  +configfall objpos+9
            +confighawkswoop enemy3dir, objpos+8, enemy3xspeed
testswoop4  +configfall objpos+11
            +confighawkswoop enemy4dir, objpos+10, enemy4xspeed
            
  


;Hawk SPACE INVADER type of animation while moving 
;across the screen inside the forcefield

animmode !byte 0

fleetdir !byte 0 ;Set direction to move the birds accordingly 0 = left, 1 = right
fleetpos !byte 0
fleetdelay !byte 0      
animdelay !byte 0
animpointer !byte 0
bonusegg !byte $88

;Animated swooping hawk objects
hawktype1spr !byte $89 
hawktype2spr !byte $8b 
hawktype3spr !byte $8c 

;Animation sprites for the players 
playership !byte $80    
playerbullet !byte $81
playerdeath !byte $82

;Player death animation
playerdeathframe !byte $82,$83,$84,$85,$86,$87
playerdeathframeend !byte $ab

;Enemy bullets that are dropped from 
;the swooping aliens 

hawkbullet !byte $8f 

;Animation for swooping aliens

hawkanim1   !byte $89,$8a 
hawkanim2   !byte $8b,$8c 
hawkanim3   !byte $8d,$8e 

;Hawk movement direction

enemy1dir !byte 0
enemy2dir !byte 1
enemy3dir !byte 0
enemy4dir !byte 1


enemy1xspeed !byte 1
enemy2xspeed !byte 2
enemy3xspeed !byte 3
enemy4xspeed !byte 4

;Score sprites 
points100 !byte $8f
points200 !byte $90
points300 !byte $a0
points500 !byte $a1

;Get READY sprite everytime a new level 
;or game starts, or the player lose a
;life. (2 sprites)
ready1 !byte $a2
ready2 !byte $a3

;Game over (3 sprites)
gameover1 !byte $a4
gameover2 !byte $a5
gameover3 !byte $a6

;Wave clear (4 sprites)
waveclear1 !byte $a7
waveclear2 !byte $a8
waveclear3 !byte $a9
waveclear4 !byte $aa

objpos !fill 16,0
hawk1backup1 !fill 16,0
hawk1backup2 !fill 16,0
hawk1backup3 !fill 16,0
hawk1backup4 !fill 16,0
hawk2backup1 !fill 16,0
hawk2backup2 !fill 16,0
hawk2backup3 !fill 16,0
hawk2backup4 !fill 16,0
hawk3backup1 !fill 16,0
hawk3backup2 !fill 16,0
hawk3backup3 !fill 16,0
hawk3backup4 !fill 16,0
;Forcefield colour store pointers

colourpointer !byte 0
colourstore1 !byte 0
colourstore2 !byte 0

;Colour table for the forcefield 

colourtable1 !byte $06,$02,$04,$05,$03,$07,$01,$07,$03,$05,$04,$02
colourtable1end
colourtable2 !byte $01,$07,$03,$05,$04,$02,$06,$02,$04,$05,$03,$07


;Sprite collision table
collider !fill 8,0

!fill $ff,0



;Charset collision row table

screenhi  !byte $04,$04,$04,$04,$04
    !byte $04,$04,$05,$05,$05
    !byte $05,$05,$05,$06,$06
    !byte $06,$06,$06,$06,$06
    !byte $07,$07,$07,$07,$07;,$07
    
screenlo  !byte $00,$28,$50,$78,$a0
    !byte $c8,$f0,$18,$40,$68
    !byte $90,$b8,$e0,$08,$30
    !byte $58,$80,$a8,$d0,$f8 
    !byte $20,$48,$70,$98,$c0;,$e0