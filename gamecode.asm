;----------------------------------------
;Main game code
;----------------------------------------

gamestart
          ;Like with the front end switch 
          ;off all interrupts 
          lda #$35
          sta $01
          ldx #0
initproperties
          lda #0
          sta propsstart
          inx
          cpx #propsend-propsstart 
          bne initproperties
          
         
          sei
         ; ldx #$48
         ; ldy #$ff
         ; lda #$81
         ; stx $fffe
         ; sty $ffff
          sta $dc0d
          sta $dd0d
          lda #$00
          sta $d011
          sta $d01a
          sta $d019
          sta $d021
          sta $d020
          sta levelpointer
          lda #16
          sta spawndelayspeed
          
        
          lda #3
          sta lives
           ;Initialise the player's shield 
          lda #1
          sta shieldavailable
          lda #200
          sta shieldtime
          lda #0
          sta shieldenabled
          lda #7
          sta $d022
          lda #6
          sta $d023
          lda #$18
          sta $d016 
          lda #$1a
          sta $d018
          
          ;Init SID
          ldx #$00
clearsid  lda #$00
          sta $d3ff,x
          inx
          cpx #$1a
          bne clearsid
          sta firebutton
          
          ;Init score
          ldx #$00
scorezero lda #$30
          sta score,x
          inx
          cpx #6
          bne scorezero
          lda #$30
          sta level
          lda #$31
          sta level+1
          
          ldx #0
putpanel  lda gamescreendata,x
          sta $0400,x
          lda gamecolourdata,x
          sta $d800,x
          inx
          cpx #40
          bne putpanel
          ;cli
          ;Setup IRQ raster interrupts
          ;sei
          ldx #<girq1
          ldy #>girq1
          lda #$7f
          stx $fffe
          sty $ffff
          ldx #<nmi 
          ldy #>nmi
          stx $fffa
          sty $fffb
          sta $dc0d
          sta $dd0d
          lda #$2a
          sta $d012
          lda #$1b
          sta $d011
          lda #$01
          sta $d019
          sta $d01a
          lda #sfxgetready
          jsr sfxinit
          cli
          jmp gamerestart
          
          ;Main IRQ raster interrupt
girq1     sta stacka+1
          stx stackx+1
          sty stacky+1
          asl $d019
          lda $dc0d
          sta $dd0d
          lda #$f8
          sta $d012
          lda #1
          sta rt
          jsr sfxplayer
stacka    lda #$00
stackx    ldx #$00
stacky    ldy #$00          
nmi       rti          

sfxplayer
          lda system
          cmp #1
          beq pal2
          inc ntsctimer
          lda ntsctimer
          cmp #6
          beq resetntsc2
pal2      jsr sfxplay
          rts
resetntsc2 
          lda #0
          sta ntsctimer
          rts
          
gamerestart          
          lda #0
          sta soundloopdelay
          sta waitdelay
          sta firebutton
          sta hawktoshoot
          sta eggtimer
          sta eggdir 
          sta eggdelay
          ;sta objpos+14
          lda #$00
          sta objpos+15
          
          ldx #$00
drawgame  lda gamescreendata+40,x
          sta $0400+40,x
          lda gamescreendata+$100,x
          sta $0500,x
          lda gamescreendata+$200,x
          sta $0600,x
          lda gamescreendata+$2e8,x 
          sta $06e8,x 
          lda gamecolourdata+40,x 
          sta $d800+40,x
          lda gamecolourdata+$100,x
          sta $d900,x
          lda gamecolourdata+$200,x
          sta $da00,x
          lda gamecolourdata+$2e8,x
          sta $dae8,x
          inx
          bne drawgame
          
          jsr updatepanel
          lda #$1b
          sta $d011
lifelostloop          
          ;Zero position all of the game sprites
          ldx #$00
.blankout lda #$39 ;Custom blank sprite 
          sta $07f8,x
          inx
          cpx #$08
          bne .blankout
          
          ldx #$00
zerospritepos
          lda #$00
          sta objpos,x
          inx
          cpx #14
          bne zerospritepos
          jsr expandmsb
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
          
        
          
          ;Setup player frame as ship 
          lda playership
          sta $07f9 ;Sprite0 = player ship 
          
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
         
          lda #0 
          sta waitdelay
         
          lda #sfxgetready
          jsr sfxinit
          
         
          
          ;Place the READY sprite onto the screen 
          lda ready1
          sta $07f8 
          lda ready2
          sta $07f9 
          lda #$aa
          sta objpos+1
          sta objpos+3
          lda #$52
          sta objpos
          clc
          adc #$0c
          sta objpos+2
          jsr expandmsb
          ;After the player loses a life, the 
          ;sprites on screen are deducted
          ;If no chars or sprites visible, 
          ;level complete should be activated 
          
          jsr checklevelcomplete
        
         ldx levelpointer
         lda levelspawntable,x 
         sta maxhawksallowed
         lda levelspeedtable,x
         sta levelspeed
         lda levelbulltable,x
         sta levelbullspeed
         inx
         cpx #17
         beq gamecomplete
        
startmode 
          jsr synctimer
          jsr movehawx 
          
          lda waitdelay
          cmp #$a0
          beq stopwait
          inc waitdelay
          jmp startmode  
          
gamecomplete jmp gamecompleteroutine

stopwait  
          
          ;Setup player starting position 
          lda #0
          sta hawktoshootdelay
          sta hawktoshoot
          sta hawkcount
          lda #playerhomeposx
          sta objpos+2
          lda #playerhomeposy
          sta objpos+3
          
          lda #0
          sta objpos+1
          sta objpos
          
          ;Transform other sprite into player ship 
          ;Sprite 1 is being used instead of sprite 
          ;0 in order to prevent confusing the software 
          ;based sprite/sprite collision routine
        
          lda #0
          sta $d015 
          lda playership
          sta $07f9 
          lda #$ff
          sta $d015
         
          lda #0
          sta soundloopdelay
          sta waitdelay
          sta firebutton
          sta hawktoshoot
          sta eggtimer
          sta eggdir 
          sta eggdelay
          sta shieldenabled
          sta shieldtime
          sta spawndelay
          sta objpos+4
          sta objpos+6
          sta objpos+8
          sta objpos+10
          lda #0
          sta enemy1xspeed
          sta enemy2xspeed
          sta enemy3xspeed
          sta enemy4xspeed
          sta playerbulletdead
          jsr expandmsb
          
          
;-------------------------------------------          
;Main game loop control
;-------------------------------------------          
gameloop
          jsr synctimer
         
          ;Collision detection
          jsr bullettohawkchars
          jsr spritemode
          
          ;Shift hawk fleet
          jsr movehawx
          
          ;Player properties 
          jsr playercontrol
          
          ;Spawn test (if enemy kills player, zero Y position
          ;enemy that hit player)
          jsr testswoop
          
          ;Collision detection sprite/sprite
          jsr spritetosprite
          
          ;Randomiser - Hawk spawn
          jsr randomselector
          
          ;Hawk shooting properties
          jsr selecthawkshoot
          
          ;Bonus egg properties
          jsr eggproperties
          
          jmp gameloop
          
synctimer
          
          lda #$00
          sta rt
          cmp rt
          beq *-3 
          jsr expandmsb
          jsr animator
          jsr flashcolours
          
          rts 
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
          
;-------------------------------------------------
;Hawk SPACE INVADER type of animation while moving 
;across the screen inside the forcefield
;-------------------------------------------------

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
          
           jsr animationprocess
           jsr shieldstatus

           jsr playerbulletcontrol

          ;Check joystick port 2, left 
          lda #2
          bit $dc00 
          bne checkjoyleft 
          
          ;Down has been pressed, activate
          ;the player shield - only if the
          ;shield has NOT been enabled and 
          ;is available 
         
          lda shieldavailable
          beq checkjoyleft 
          lda shieldenabled
          cmp #1
          beq checkjoyleft 
          lda #255
          sta shieldtime
          ldx #0
          stx playershieldpointer
          lda #0
          sta shieldavailable
          lda #1
          sta shieldenabled
          lda #0
          jsr sfxinit
          
checkjoyleft          
          lda #4 
          bit $dc00 
          bne checkjoyright
          
          ;Move player until it has 
          ;reached the very left position
          
          lda objpos+2
          sec
          sbc #2
          cmp #leftboundary
          bcs leftupdate
          lda #leftboundary
leftupdate 
          sta objpos+2
          jmp checkjoyfire 
          
          ;Check joystick port 2, right
checkjoyright          
          lda #8
          bit $dc00 
          bne checkjoyfire 
          
          ;Move player until it has 
          ;reached the very right position
          
          lda objpos+2
          clc
          adc #2
          cmp #rightboundary
          bcc rightupdate
          lda #rightboundary 
rightupdate
          sta objpos+2
          
          ;Check fire on joystick port 2
          
checkjoyfire           
          lda $dc00
          lsr
          lsr
          lsr
          lsr
          lsr
          bit firebutton
          ror firebutton
          bmi nocontrol
          bvc nocontrol
          lda #0
          sta firebutton
          
          ;Check bullet position
          lda objpos
          beq spawnnewbullet;position 0 = offset 
          jmp nocontrol
spawnnewbullet
          lda playerbullet
          sta $07f8
          lda objpos+2
          sta objpos
          lda objpos+3
          sta objpos+1
          lda #sfxplayershoot
          jsr sfxinit
          
nocontrol
          rts          
          
shieldstatus
          jsr checkshieldactivation
          lda shieldavailable
          cmp #1
          beq indicate 
          lda #$20
          sta $0412
          sta $0413
          rts 
indicate  lda #38
          sta $0412
          lda #43
          sta $0413
          lda #4
          sta $d812
          sta $d813
          rts 
          
checkshieldactivation
          lda shieldenabled
          cmp #1
          beq docountdown 
          
          rts 
docountdown
          dec shieldtime
          lda shieldtime
          beq shieldout
          rts
shieldout lda #0
          sta shieldenabled
          rts
          
animationprocess
          lda shieldenabled
          cmp #1
          beq animateplayershield
          lda #$80   ;Default
          sta $07f9
          rts
animateplayershield 
          ldx playershieldpointer
          lda shieldtable,x
          sta $07f9
          inx
          cpx #4
          beq loopshield
          inc playershieldpointer
          rts
loopshield 
          ldx #0
          stx playershieldpointer
          rts
          
          
          
;----------------------------------------
;Player bullet control          
;----------------------------------------

playerbulletcontrol
          lda playerbulletdead 
          beq playerbulletactive
          jsr bulldeadanim
          rts
playerbulletactive  
          lda #$81
          sta $07f8
          lda objpos
          beq nocontrol
          lda objpos+1
          sec
          sbc #8
          cmp #bullettopboundary
          bcs storebullpos
          lda #$00
          sta objpos
storebullpos
          sta objpos+1
          rts
          
          ;Short delay to show splat exploder before 
          ;removing the bullet and making it active again
          
bulldeadanim          
splatsm
          lda #$90
          sta $07f8
          lda splatdelay
          cmp #$08
          beq restorebull
          inc splatdelay
          rts
restorebull
          lda #0
          sta objpos
          sta objpos+1
          lda #0
          sta playerbulletdead
          rts
          

          

;-----------------------------------------
;Collision detection - Player bullet to 
;hawk chars
;-----------------------------------------

           ;jsr spritetosprite 

bullettohawkchars
           lda playerbulletdead
           cmp #1
           bne _readcollider
           rts
_readcollider
           lda objpos
           bne checkcharz
           rts
checkcharz           
           lda $d000
           sec
           sbc #$10
           sta zp 
           lda $d010
           sbc #$00
           lsr
           lda zp
           ror
           lsr
           lsr
           sta zp+3
           lda $d001
           sec
           sbc #$2a 
           lsr
           lsr
           lsr
           sta zp+4 
           lda #$00
           sta zp+1
           lda #$04
           sta zp+2
           ldx zp+4
           beq checkchar 
colloop01  lda zp+1
           clc
           adc #40
           sta zp+1
           lda zp+2 
           adc #0
           sta zp+2 
           dex
           bne colloop01
checkchar  ldy zp+3           
           jsr checkifcharishawk1
           jsr checkifcharishawk2
           jsr checkifcharishawk3
           rts
           
            ;Check hawk objects 
            
checkifcharishawk1
            lda (zp+1),y 
            cmp #64 
            beq ishawk1left
            cmp #65
            beq ishawk1right
            cmp #66
            beq ishawk1left 
            cmp #67 
            beq ishawk1right
            rts
ishawk1left 
            jsr killhawkleft
            lda #1
            sta scoretype
            jsr scorecheck
            lda #sfxenemydeath1
            jsr sfxinit
            lda #$90
            sta splatsm+1
            rts 
ishawk1right
            jsr killhawkright
            lda #1
            sta scoretype
            
            jsr scorecheck
            lda #sfxenemydeath1
            jsr sfxinit
            lda #$90
            sta splatsm+1
            rts
            
checkifcharishawk2 
            lda (zp+1),y 
            cmp #68 
            beq ishawk2left
            cmp #69 
            beq ishawk2right
            cmp #70
            beq ishawk2left 
            cmp #71
            beq ishawk2right 
            rts
ishawk2left 
            jsr killhawkleft
            lda #2
            sta scoretype
            
            jsr scorecheck
            lda #sfxenemydeath2
            jsr sfxinit
            lda #$91
            sta splatsm+1
            
            rts 
ishawk2right
            
            jsr killhawkright
            lda #2
            sta scoretype
            
            jsr scorecheck
            lda #sfxenemydeath2
            jsr sfxinit
            lda #$91
            sta splatsm+1
            rts 
            
checkifcharishawk3 
            lda (zp+1),y 
            cmp #72 
            beq ishawk3left 
            cmp #73
            beq ishawk3right 
            cmp #74 
            beq ishawk3left 
            cmp #75
            beq ishawk3right
            rts 
ishawk3left 
            jsr killhawkleft
            
            lda #3
            sta scoretype
            
            jsr scorecheck
            lda #sfxenemydeath3
            jsr sfxinit
            lda #$92
            sta splatsm+1
            rts
ishawk3right
            jsr killhawkright
              lda #3
            sta scoretype
            jsr scorecheck
            lda #sfxenemydeath3
            jsr sfxinit
            lda #0
            sta spawndelay
            ;dec spawndelayspeed
            lda #$92
            sta splatsm+1
            rts
            
              

           ;Kill Star Hawk from left 
killhawkleft 
            lda #$20
            sta (zp+1),y 
            iny 
            sta (zp+1),y
            tya
            clc
            adc #40
            tay
            lda #$20 
            sta (zp+1),y 
            dey 
            sta (zp+1),y
            jmp dokillbullet
            ;rts
            ;Hill Star Hawk from right 
killhawkright
            lda #$20 
            sta (zp+1),y
            dey 
            sta (zp+1),y 
            tya
            clc
            adc #40
            tay
            lda #$20
            sta (zp+1),y 
            iny
            sta (zp+1),y
           
            ;sta spawndelay
            dec spawndelayspeed
            jmp dokillbullet
            rts
            
;Do kill bullet 
              
dokillbullet  
            lda #0
            sta splatdelay
            lda #1
            sta playerbulletdead
            rts
           
;----------------------------------------
;Animatior - for game sprites and also 
;characters
;----------------------------------------

animator    
            lda animdelay
            cmp #4
            beq animmain
            inc animdelay
            rts
animmain    lda #0
            sta animdelay
            jsr animforcefield ;Animate forcefield chars
            jsr animstars      ;Animate blinking stars 
          
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
animchr            
            ldx #$07
animchars2  lda $2800+(60*8),x
            asl
            rol $2800+(60*8),x
            lda $2800+(62*8),x
            lsr
            ror $2800+(62*8),x
            dex
            bpl animchars2
            
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
            
;-----------------------------------------------------------------
;On screen background animation (8 char frames) - link to 
;scrolling charsets
;-----------------------------------------------------------------               

animstars     ldx #$00
charanimloop1 lda $2c00,x
              sta $2c38,x 
              inx
              cpx #8
              bne charanimloop1
              ldx #$00
charanimloop2 lda $2c08,x 
              sta $2c00,x 
              inx
              cpx #$38
              bne charanimloop2
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
            adc levelbullspeed
            cmp #$f4
            bcc notoffset
            lda #0
            sta objpos+$0c
notoffset            
            sta objpos+$0d
            
            rts
;----------------------------------------
;Test swooping hawks            
;4 x jump subroutines for swoop test
;Called via macro routines in macros.asm
;----------------------------------------

testswoop 
            jsr testswoop1
            jsr testswoop2
            jsr testswoop3
            jsr testswoop4
            rts
            
;Swoop test to check availability of enemy, by 
;checking the x speed of the enemy. If enemy 
;is outside the game screen with speed X = 0
;then leave it, otherwise do the swooping X on 
;screen            
            
testswoop1  +configfall objpos+5, enemy1xspeed
            +confighawkswoop enemy1dir, objpos+4, enemy1xspeed
            rts
testswoop2  +configfall objpos+7, enemy2xspeed
            +confighawkswoop enemy2dir, objpos+6, enemy2xspeed
            rts
testswoop3  +configfall objpos+9, enemy3xspeed
            +confighawkswoop enemy3dir, objpos+8, enemy3xspeed
            rts
testswoop4  +configfall objpos+11, enemy4xspeed
            +confighawkswoop enemy4dir, objpos+10, enemy4xspeed
            rts
            
;----------------------------------------
;Sprite to sprite collision routines 
;two checks - enemies to play and 
;enemies to bullet.
;----------------------------------------

spritetosprite
              
              lda objpos+2 
              sec
              sbc #playercollisionleft
              sta collider
              clc
              adc #playercollisionright
              sta collider+1
              
              lda objpos+3
              sec
              sbc #playercollisionup 
              sta collider+2
              clc
              adc #playercollisiondown
              sta collider+3
              
              lda objpos
              sec
              sbc #bulletcollisionleft 
              sta collider+4
              clc
              adc #bulletcollisionright 
              sta collider+5
              
              lda objpos+1
              sec
              sbc #bulletcollisionup
              sta collider+6
              clc
              adc #bulletcollisiondown 
              sta collider+7
              
              jsr playertoenemy
              jsr enemy2bullet1
              jsr enemy2bullet2
              jsr enemy2bullet3
              jmp enemy2bullet4
              
              ;Player to enemy collision. This is 
              ;a very simple loop 
              
playertoenemy
              lda shieldenabled
              cmp #1
              beq skipcollision
              
              ldx #$00
p2echeckloop              
              lda objpos+4,x
              cmp collider
              bcc playernothit
              cmp collider+1
              bcs playernothit
              lda objpos+5,x
              cmp collider+2
              bcc playernothit
              cmp collider+3
              bcs playernothit
              lda #0
              sta objpos+5,x 
              ;Player is hit so move to another syncroutine to destroy the player.
              lda #sfxplayerdeath
              jsr sfxinit
              jmp destroyplayer
skipcollision              
              rts
playernothit  inx
              inx
              cpx #$0c
              bne p2echeckloop
              rts
              
enemy2bullet1  +enemy2bullet objpos+4, objpos+5, enemy1xspeed, $07fa
enemy2bullet2  +enemy2bullet objpos+6, objpos+7, enemy2xspeed, $07fb
enemy2bullet3  +enemy2bullet objpos+8, objpos+9, enemy3xspeed, $07fc
enemy2bullet4  +enemy2bullet objpos+10, objpos+11, enemy4xspeed, $07fd

;-------------------------------------
; Random launch of enemy bird sprites
;-------------------------------------


randomselector  
                jsr cycleselection1
                jsr cycleselection2
                jsr cycleselection3
                jsr cycleselection4
                jsr cyclespriteposition
                jsr checkspawn 
                rts 
checkspawn                
                
spawnnextifpossible                
                
                lda #0
                sta spawndelay        
                jsr getrandom
                and #$03
                sta selectrandompointer
                lda selectrandompointer
                cmp #0
                bne .notselectfleet1
                
                jmp selectfleet1
.notselectfleet1
                cmp #1
                bne .notselectfleet2
                jmp selectfleet2 
.notselectfleet2
                cmp #2
                bne .notselectfleet3 
                jmp selectfleet3
.notselectfleet3
                cmp #3
                bne .noselection 
                jmp selectfleet4
.noselection    rts            

;A fleet row has been selected to check for the bird type ...

selectfleet1    ;lda #1
                ;sta $d020
                lda #fleet1spriteypos
                sta enemyposy 
                lda fleet1store1lo 
                sta fleetcharsm+1
                lda fleet1store1hi
                sta fleetcharsm+2
                jsr spawnnewenemycheck
                rts
                
selectfleet2    ;lda #2
                ;sta $d020 
                lda #fleet2spriteypos
                sta enemyposy
                lda fleet2store1lo 
                sta fleetcharsm+1
                lda fleet2store1hi 
                sta fleetcharsm+2
                
                jsr spawnnewenemycheck
                rts
            
selectfleet3    ;lda #3
                ;sta $d020 
                lda #fleet3spriteypos
                sta enemyposy
                lda fleet3store1lo 
                sta fleetcharsm+1
                lda fleet3store1hi 
                sta fleetcharsm+2 
                jsr spawnnewenemycheck
                rts
             
selectfleet4    ;lda #4
                ;sta $d020
                lda #fleet4spriteypos
                sta enemyposy
                lda fleet4store1lo 
                sta fleetcharsm+1
                lda fleet4store1hi 
                sta fleetcharsm+2
                jsr spawnnewenemycheck
                
                rts
                
spawnnewenemycheck 
                
fleetcharsm     lda $ffff ;<- selfmod 
                cmp #hawktype1a 
                bne .nothawk01a
                jmp dospawnhawk1forwards
                
.nothawk01a     cmp #hawktype1b
                bne .nothawk01b
                jmp dospawnhawk1backwards
                
.nothawk01b     cmp #hawktype1c
                bne .nothawk01c 
                jmp dospawnhawk1forwards 
                
.nothawk01c     cmp #hawktype1d 
                bne .nothawk01d 
                jmp dospawnhawk1backwards
.nothawk01d                
                cmp #hawktype2a 
                bne .nothawk02a 
                jmp dospawnhawk2forwards 
                
.nothawk02a     cmp #hawktype2b
                bne .nothawk02b 
                jmp dospawnhawk2backwards 
                
.nothawk02b     cmp #hawktype2c 
                bne .nothawk02c 
                jmp dospawnhawk2forwards 
                
.nothawk02c     cmp #hawktype2d 
                bne .nothawk02d 
                jmp dospawnhawk2backwards
                
.nothawk02d     cmp #hawktype3a 
                bne .nothawk03a
                jmp dospawnhawk3forwards 

.nothawk03a     cmp #hawktype3b
                bne .nothawk03b
                jmp dospawnhawk3backwards
         
.nothawk03b     cmp #hawktype3c 
                bne .nothawk03c 
                jmp dospawnhawk3forwards 
                
.nothawk03c     cmp #hawktype3d 
                bne .nothawk03d 
                jmp dospawnhawk3backwards 
                
dospawnhawk1forwards
               
                jmp spawnhawk1left
.nothawk03d
                rts               
dospawnhawk1backwards 
               
                jmp spawnhawk1right
                
                
dospawnhawk2forwards 
                 
                jmp spawnhawk2left
dospawnhawk2backwards 
                
                jmp spawnhawk2right 

dospawnhawk3forwards 
                
                jmp spawnhawk3left
dospawnhawk3backwards 
              
                jmp spawnhawk3right
                
;Delete characters from top left 

deletefromleft  lda fleetcharsm+1
                sta delleftsm+1
                lda fleetcharsm+2
                sta delleftsm+2
                lda delleftsm+1
                clc
                adc #40 
                sta delleftsm2+1
                lda delleftsm+2
                adc #0
                sta delleftsm2+2
                ldx #$00
leftrub         lda #$20                
delleftsm       sta $ffff,x
delleftsm2      sta $ffff,x              
                inx 
                cpx #2
                bne leftrub
               
                rts

deletefromright  
                lda fleetcharsm+1
                sec 
                sbc #1
                sta delrightsm+1
                lda fleetcharsm+2 
                sta delrightsm+2
                lda delrightsm+1
                clc
                adc #40
                sta delrightsm2+1
                lda delrightsm+2
                adc #0
                sta delrightsm2+2
                
                ldx #$00
rightrub        lda #$20
delrightsm     sta $ffff,x 
delrightsm2    sta $ffff,x 
                inx
                cpx #$02
                bne rightrub
                 
                rts
             
;--------------------------------------------------                
;Cycle subroutines of the lo and hi byte table for 
;each of the enemy fleet objects
;--------------------------------------------------

cycleselection1 +selection selectpointer1, fleet1table1lo, fleet1store1lo, fleet1table1hi, fleet1store1hi
cycleselection2 +selection selectpointer2, fleet2table1lo, fleet2store1lo, fleet1table1hi, fleet2store1hi 
cycleselection3 +selection selectpointer3, fleet3table1lo, fleet3store1lo, fleet3table1hi, fleet3store1hi 
cycleselection4 +selection selectpointer4, fleet4table1lo, fleet4store1lo, fleet3table1hi, fleet4store1hi                


cyclespriteposition ldx selectorx
                    lda spriteposxtable,x 
                    sta enemyposx
                    inx 
                    cpx #39
                    beq .resetspriteread
                    inc selectorx
                    rts
.resetspriteread    ldx #0
                    stx selectorx
                    rts
                    
;Spawn any of the hawk sprites where 
;available.

spawnhawk1left
            
            +spawnhawk enemy1xspeed, hawktype1spr, hawk1sm, objpos+4, objpos+5, deletefromleft, enemy1dir
            +spawnhawk enemy2xspeed, hawktype1spr, hawk2sm, objpos+6, objpos+7, deletefromleft, enemy2dir
            +spawnhawk enemy3xspeed, hawktype1spr, hawk3sm, objpos+8, objpos+9, deletefromleft, enemy3dir
            +spawnhawk enemy4xspeed, hawktype1spr, hawk4sm, objpos+10, objpos+11, deletefromleft, enemy4dir
            rts
spawnhawk1right

            +spawnhawk enemy1xspeed, hawktype1spr, hawk1sm, objpos+4, objpos+5, deletefromright, enemy1dir
            +spawnhawk enemy2xspeed, hawktype1spr, hawk2sm, objpos+6, objpos+7, deletefromright, enemy2dir
            +spawnhawk enemy3xspeed, hawktype1spr, hawk3sm, objpos+8, objpos+9, deletefromright, enemy3dir
            +spawnhawk enemy4xspeed, hawktype1spr, hawk4sm, objpos+10, objpos+11, deletefromright, enemy4dir
            rts            
spawnhawk2left
            
            +spawnhawk enemy1xspeed, hawktype2spr, hawk1sm, objpos+4, objpos+5, deletefromleft, enemy1dir
            +spawnhawk enemy2xspeed, hawktype2spr, hawk2sm, objpos+6, objpos+7, deletefromleft, enemy2dir
            +spawnhawk enemy3xspeed, hawktype2spr, hawk3sm, objpos+8, objpos+9, deletefromleft, enemy3dir
            +spawnhawk enemy4xspeed, hawktype2spr, hawk4sm, objpos+10, objpos+11, deletefromleft,enemy4dir
            rts
spawnhawk2right

            +spawnhawk enemy1xspeed, hawktype2spr, hawk1sm, objpos+4, objpos+5, deletefromright, enemy1dir
            +spawnhawk enemy2xspeed, hawktype2spr, hawk2sm, objpos+6, objpos+7, deletefromright, enemy2dir
            +spawnhawk enemy3xspeed, hawktype2spr, hawk3sm, objpos+8, objpos+9, deletefromright, enemy3dir
            +spawnhawk enemy4xspeed, hawktype2spr, hawk4sm, objpos+10, objpos+11, deletefromright, enemy4dir
            rts
spawnhawk3left
            
            +spawnhawk enemy1xspeed, hawktype3spr, hawk1sm, objpos+4, objpos+5, deletefromleft, enemy1dir
            +spawnhawk enemy2xspeed, hawktype3spr, hawk2sm, objpos+6, objpos+7, deletefromleft, enemy2dir
            +spawnhawk enemy3xspeed, hawktype3spr, hawk3sm, objpos+8, objpos+9, deletefromleft, enemy3dir
            +spawnhawk enemy4xspeed, hawktype3spr, hawk4sm, objpos+10, objpos+11, deletefromleft, enemy4dir
            rts
            
spawnhawk3right
            
            +spawnhawk enemy1xspeed, hawktype3spr, hawk1sm, objpos+4, objpos+5, deletefromright, enemy1dir
            +spawnhawk enemy2xspeed, hawktype3spr, hawk2sm, objpos+6, objpos+7, deletefromright, enemy2dir
            +spawnhawk enemy3xspeed, hawktype3spr, hawk3sm, objpos+8, objpos+9, deletefromright, enemy3dir
            +spawnhawk enemy4xspeed, hawktype3spr, hawk4sm, objpos+10, objpos+11, deletefromright, enemy4dir
            
            rts
;General random routine                
             
getrandom       lda random+1
                sta randtemp
                lda random 
                asl
                rol randtemp
                asl
                rol randtemp
                clc
                adc random 
                pha
                lda randtemp
                adc random+1
                sta random+1
                pla
                adc #$11
                sta random
                lda random+1
                adc #$36
                sta random+1
                rts
                
;---------------------------------------------------------
;Game scoring routines. These are based on the type of
;hawk the player has shot down, and also the bonus egg
;that falls from the screen.
;---------------------------------------------------------                
   
scorecheck      
                lda scoretype
                cmp #1
                beq _100points
                cmp #2
                beq _200points
                cmp #3 
                beq _300points 
                cmp #4
                beq _500points 
                rts 
_500points      jsr doscore
                jsr doscore
_300points      jsr doscore                 
_200points      jsr doscore 
_100points      jsr doscore 
                rts 

;Main score routine 

doscore         inc score+3 
                ldx #$03
scoreloop       lda score,x
                cmp #$3a
                bne scoreok 
                lda #$30
                sta score,x
                inc score-1,x 
scoreok         dex 
                bne scoreloop 
                
                jsr updatepanel
                jsr checklevelcomplete
            
;Update panel with score, hiscore, lives 
                
updatepanel     lda shieldavailable
                cmp #1
                bne noshieldicon
                lda #38
                sta $0412
                lda #4
                sta $d812
                jmp .next_
noshieldicon    lda #$20
                sta $0412
.next_               
                ldx #$00
copyscore       lda score,x
                sta scorepos,x
                lda hiscore,x 
                sta hiscorepos,x
                inx 
                cpx #$06 
                bne copyscore
                lda level+1 
                sta levelpos+1
                lda level
                sta levelpos
                lda lives 
                beq nillives
                cmp #1
                beq onelife
                cmp #2
                beq twolives
                cmp #3
                beq threelives
                rts
threelives      lda #28 
                sta livespos
                sta livespos+1
                sta livespos+2
                rts
                
twolives        lda #$20                
                sta livespos 
                lda #28
                sta livespos+1
                sta livespos+2
                rts
                
onelife         lda #$20
                sta livespos 
                sta livespos+1
                lda #28
                sta livespos+2
                rts
                
nillives        lda #$20
                sta livespos
                sta livespos+1
                sta livespos+2
                rts
               
playdeathsfx1   lda #sfxenemydeath1
                jsr sfxinit
                
eggcontrol      rts

;-----------------------------------------------------------------
;Check level complete ...   A simple routine which will check
;to see whether or not all of the bird chars have been removed
;and also all bird sprites xspeed = 0
;-----------------------------------------------------------------

checklevelcomplete
               ldx #$00
checklevloop   lda $0450,x
               cmp #64
               beq .hawk1exists
               cmp #65
               beq .hawk1exists
               cmp #66
               beq .hawk1exists
               cmp #67 
               beq .hawk1exists
               jmp checkhawk2exists 
.hawk1exists   rts 
checkhawk2exists 
               cmp #68
               beq .hawk2exists 
               cmp #69 
               beq .hawk2exists 
               cmp #70 
               beq .hawk2exists 
               cmp #71 
               beq .hawk2exists 
               jmp checkhawk3exists 
.hawk2exists    rts 

checkhawk3exists 
               cmp #72
               beq .hawk3exists 
               cmp #73 
               beq .hawk3exists 
               cmp #74
               beq .hawk3exists 
               cmp #75 
               beq .hawk3exists 
               inx 
               cpx #200
               bne checklevloop
               jmp checksegment2
.hawk3exists   rts 
checksegment2
               ldx #$00
.finishcheckloop1               
               lda $0450+200,x
               cmp #64
               beq .hawk1exists2
               cmp #65
               beq .hawk1exists2
               cmp #66
               beq .hawk1exists2
               cmp #67
               beq .hawk1exists2
               jmp checkhawk2exists2
.hawk1exists2  rts 

checkhawk2exists2 
               cmp #68
               beq .hawk2exists2
               cmp #69 
               beq .hawk2exists2
               cmp #70
               beq .hawk2exists2
               cmp #71
               beq .hawk2exists2
               jmp checkhawk3exists2
.hawk2exists2               
               rts 
               
checkhawk3exists2
               cmp #72
               beq .hawk3exists2
               cmp #73
               beq .hawk3exists2
               cmp #74
               beq .hawk3exists2
               cmp #75
               beq .hawk3exists2
               jmp nohawkchars
.hawk3exists2               
               rts
               
nohawkchars               
               inx
               cpx #200
               bne .finishcheckloop1

;Check that there are no hawk sprites alive        
               
               lda #1 ;Stop spawning new birds 
               sta spawnstopenabled
               ldx #$00
checkspeedloop lda enemy1xspeed,x
               bne .hawkexists
               inx
               cpx #4
               bne checkspeedloop
               lda #sfxlevelcomplete
               jsr sfxinit
               jmp showlevelcomplete
.hawkexists    rts               
               
;---------------------------------------------
;Level complete sequence. Remove all the 
;other sprites, and then spawn the WELL
;DONE sprites onto the screen.
;---------------------------------------------

               ;Remove all of the sprites 
showlevelcomplete               
               ldx #$00
removespritesmain
               lda #$00
              
               sta objpos,x
                inx
                cpx #$10
                bne removespritesmain

                jsr expandmsb
                ldx #$00
.blankout2 lda #$39 ;Custom blank sprite 
          sta $07f8,x
          inx
          cpx #$08
          bne .blankout2
               ;Setup the LEVEL COMPLETE sprites 
               
               lda waveclear1
               sta $07f8 
               lda waveclear2
               sta $07f9 
               lda waveclear3
               sta $07fa 
               lda waveclear4
               sta $07fb 
               
               lda #$46
               sta objpos
               clc
               adc #$0c
               sta objpos+2
               adc #$0c 
               sta objpos+4
               adc #$0c
               sta objpos+6
               lda #$aa
               sta objpos+1
               sta objpos+3
               sta objpos+5
               sta objpos+7
               
               ;Setup 1000 points bonus 
         
                     
               inc score+2
               ldx #2
.bonuspoints   lda score,x
               cmp #$3a
               bne bonusok 
               lda #$30
               sta score,x
               inc score-1,x
bonusok        dex
               bne .bonuspoints
               
               jsr updatepanel
               
               lda #0
               sta waitdelay
levelcompleteloop               
               jsr synctimer
               lda waitdelay
               cmp #$a0
               beq startnextlevel
               inc waitdelay
               jmp levelcompleteloop
startnextlevel 
               inc level+1
               lda level+1
               cmp #$3a
               bne levelok
               lda #$30
               sta level+1
               inc level
levelok        lda spawndelayspeed
               sec
               sbc #1
               sta spawndelayspeed
               lda spawndelayspeed 
               cmp #1
               
               bne stordelay
               lda #32
               sta spawndelayspeed
               
stordelay               
               
               
               lda #0
               sta spawndelay
              
               jsr updatepanel
               inc levelpointer
               jmp gamerestart
               rts           
           
;------------------------------------------------
;Star Hawx shooting. Constantly increment the 
;hawk select pointer until it reaches >4 then 
;once the bullet is offset, check the hawk 
;boundary and then force it to fire bullet
;------------------------------------------------               
selecthawkshoot
               
               jsr bulletdrop
               lda hawktoshootdelay
               cmp #$10
               bne _noselect
               lda #0
               sta hawktoshootdelay
               jsr selecthawktoshoot
_noselect      
               inc hawktoshootdelay
               rts
selecthawktoshoot
               inc hawktoshoot
               lda hawktoshoot
               cmp #1
               beq checkhawk1fire
               cmp #2
               beq checkhawk2fire 
               cmp #3
               beq checkhawk3fire
               cmp #4
               beq checkhawk4fire
               lda #0
               sta hawktoshoot
               rts 

;Check hawks that should shoot during play 

checkhawk1fire jmp checkhawktoshoot1
checkhawk2fire jmp checkhawktoshoot2
checkhawk3fire jmp checkhawktoshoot3
checkhawk4fire jmp checkhawktoshoot4 

checkhawktoshoot1 +select_hawk_shoot objpos+4, objpos+5 
checkhawktoshoot2 +select_hawk_shoot objpos+6, objpos+7 
checkhawktoshoot3 +select_hawk_shoot objpos+8, objpos+9       
checkhawktoshoot4 +select_hawk_shoot objpos+10, objpos+11      

;-------------------------------------------------------------
;Bullet drop routine - this makes the bullet fall routine
;(No thrills here ;))
;--------------------------------------------------------------
bulletdrop    lda #$8f
              sta $07fe
            
              rts
              
              
;--------------------------------------------------------------
;Bonus egg properties - This controls the egg's behviour.
;When the egg is offset, the routine is timed for a short 
;period. Behind the scene, the egg will move left/right. As
;soon as timer expires, the egg will fall. The player will have
;to shoot the egg in order to get a bonus between 100 and 500
;points (The scoring option will operate in collision test mode)
;-------------------------------------------------------------- 

eggproperties 
              lda eggreleased
             
              cmp #1
              bne eggnotreleasedyet
              jmp dropegg
eggnotreleasedyet
              lda eggdelay 
              cmp #7
              beq eggdelayok
              inc eggdelay
              rts
eggdelayok    lda #0
              sta eggdelay
              lda eggtimer 
              cmp eggtimerexpiry
              beq releasetheegg
              lda #0
              sta objpos+15
              inc eggtimer
               lda #$88 ;Egg sprite 
              sta $07ff
              lda #5
              sta $d02e
              jmp testpositionegg
             

              
              ;Egg is released so activate it.
releasetheegg
              lda #0
              sta eggtimer
              sta eggdelay
              lda #1
              sta eggreleased
             
              rts 
              
dropegg       ;Drop the egg until it leaves the screen
              jsr egg2bullet
              lda objpos+15
              clc
              adc #2
              cmp #$fa
              bcc notoutborder
              lda #0
              sta eggreleased
              sta eggtimer
              rts
notoutborder  sta objpos+15
              rts
              
              ;Egg is not released so move it left/right in a fast pace behind the scene
testpositionegg              
          
              lda eggdir
              beq eggleft
              
              ;Egg secretly moves right 
              lda objpos+14
              clc
              adc #4
              cmp #rightboundary
              bcc storeeggright 
              lda #0
              sta eggdir
              rts
storeeggright sta objpos+14
              rts 
              
              ;Egg secretly moves left 
eggleft       lda objpos+14
              sec
              sbc #3
              cmp #leftboundary
              bcs storeeggleft
              lda #1
              sta eggdir
              rts
storeeggleft  sta objpos+14
              rts
              
;Special routine for egg 2 bullet since egg only 
;falls and uses no X-movement. 

egg2bullet      
                lda objpos+14
                beq .noeggshot
                jsr mysterybonus
                lda objpos+14
                cmp collider+4
                bcc .noeggshot
                cmp collider+5
                bcs .noeggshot
                lda objpos+15
                cmp collider+6
                bcc .noeggshot
                cmp collider+7
                bcs .noeggshot
                
                ;Shooting an egg gives the player a shield 
                
                lda #1
                sta shieldavailable
                jmp setsbonusscorezone
.noeggshot      rts             

                
mysterybonus    inc eggscore
                lda eggscore
                cmp #5
                beq switcheggscore
                rts 
switcheggscore  lda #0
                sta eggscore
                rts
                
setsbonusscorezone
                lda eggscore
                sta scoretype
                cmp #1
                beq splat100ptsbounus
                cmp #2
                beq splat200ptsbonus
                cmp #3
                beq splat300ptsbonus
                cmp #4
                beq splat500ptsbonus
                rts
splat100ptsbounus
                lda #$90
                sta splatsm+1
                lda #sfxeggshot
                jsr sfxinit
                jsr scorecheck
                
                lda #0
                sta objpos+15
                sta eggreleased
                jmp dokillbullet
splat200ptsbonus
                lda #$91
                sta splatsm+1
                
                lda #sfxeggshot
                jsr sfxinit
                jsr scorecheck
                
                lda #0
                sta objpos+15
                sta eggreleased
                jmp dokillbullet 
splat300ptsbonus
                lda #$92
                sta splatsm+1
                
                lda #sfxeggshot
                jsr sfxinit
                jsr scorecheck
                
                lda #0
                sta objpos+15
                sta eggreleased
                jmp dokillbullet 
splat500ptsbonus
                lda #$93 
                sta splatsm+1
                
                lda #sfxeggshot
                jsr sfxinit
                jsr scorecheck
                lda #0
                sta objpos+15
                sta eggreleased
                jmp dokillbullet
                
                
;----------------------------------
;The player has been hit by either 
;the enemies or the egg or bullet 
;either way, the player death 
;should take place
;---------------------------------

destroyplayer ;Remove the swoopers and eggs
          lda #0
          sta objpos+5
          sta objpos+7
          sta objpos+9
          sta objpos+11
          sta objpos+13
          sta objpos+15
          lda #0
                sta playerdeathdelay
                sta playerdeathpointer
                
                ;Main explosion loop
explodeloop     
          jsr synctimer
          
          ;Shift hawk fleet
          jsr movehawx
          
          lda #0
          sta objpos+15
          
          sta eggreleased 
          jsr exploder
          jmp explodeloop
          
exploder
          lda playerdeathdelay
          lda playerdeathdelay 
          cmp #3
          beq animdeathnow
          inc playerdeathdelay
          rts
animdeathnow
          lda #0
          sta playerdeathdelay
          sta objpos+0
          ldx playerdeathpointer
          lda playerdeathframe,x
          sta $07f9
          inx
          cpx #playerdeathframeend-playerdeathframe
          beq lifelost
          inc playerdeathpointer
          rts
lifelost  ldx #0
          stx playerdeathpointer
          dec lives
          jsr updatepanel
          lda lives
          beq gameover 
          
          ;Reset player X position - y is ok
          
          lda #$54
          sta objpos+4
          
          lda #$80 
          sta $07f8
          lda #0
          sta enemy1xspeed
          sta enemy2xspeed
          sta enemy3xspeed
          sta enemy4xspeed
          sta eggreleased
          sta objpos+12
          jmp lifelostloop
          
gameover  ldx #$00
.blankout3 lda #$39 ;Custom blank sprite 
          sta $07f8,x
          inx
          cpx #$08
          bne .blankout3
          
          lda #sfxgameover
          jsr sfxinit
        
          lda gameover1
          sta $07f8
          lda gameover2
          sta $07f9
          lda gameover3
          sta $07fa
          lda #$aa
          sta objpos+1
          sta objpos+3
          sta objpos+5
          lda #$4c
          sta objpos
          clc
          adc #$0c
          sta objpos+2
          adc #$0c
          sta objpos+4
          lda #0 
          sta waitdelay
          jsr hiscorereader
gameoverloop
          
          jsr synctimer
          
          ;Shift hawk fleet
          jsr movehawx
          lda waitdelay
          cmp #$e0
          beq stopwait2
          inc waitdelay
          jmp gameoverloop 
stopwait2
          jmp checkhiscore
hiscorereader              
          lda score
          sec 
          lda hiscore+5
          sbc score+5
          lda hiscore+4
          sbc score+4
          lda hiscore+3
          sbc score+3
          lda hiscore+2
          sbc score+2
          lda hiscore+1
          sbc score+1
          lda hiscore
          sbc score
          bpl nohiscore
          ldx #$00
makenewhiscore
          lda score,x
          sta hiscore,x
          inx
          cpx #$06
          bne makenewhiscore
nohiscore          
          jsr updatepanel
          rts

;------------------------------------------
;Game complete screen. Animated as like the
;title screen
;------------------------------------------         
gamecompleteroutine
          
         ;Setup the end screen
         
         sei
         lda #0
         sta $d019
         sta $d01a
         lda #$81
         sta $dc0d
         sta $dd0d
       ;  ldx #$48
       ;  ldy #$ff
       ;  stx $fffe
       ;  sty $ffff
         lda #0
         sta $d015
         lda #$36
         sta $0410
         
         lda #$0b
            sta $d011
         ldx #$00
copyendscreen
         lda endscreen+40,x
         sta $0400+40,x
         lda endscreen+$100,x
         sta $0500,x
         lda endscreen+$200,x
         sta $0600,x
         lda endscreen+$2e8,x
         sta $06e8,x
         lda endcolour+40,x
         sta $d800,x
         lda endcolour+$100,x
         sta $d900,x
         lda endcolour+$200,x
         sta $da00,x
         lda endcolour+$2e8,x
         sta $dae8,x 
         inx
         bne copyendscreen 
         ldx #$00
getgamecol 
         lda gamescreendata,x
         sta $0400,x
         lda gamecolourdata,x
         sta $d800,x
         inx
         cpx #40
         bne getgamecol
         jsr hiscorereader
         lda #0
         sta firebutton
         sta $d015
         ldx #<singleirq
         ldy #>singleirq
         lda #$7f
         sta $dc0d
         sta $dd0d
         lda #$1b
         sta $d011
         lda #$01
         sta $d01a
         cli
         lda #1
         jsr musicinit
waitloopend           
         lda #0
         sta rt
         cmp rt
         beq *-3
         jsr animator
         jsr musicplayer
       
         lda $dc00
         lsr
         lsr
         lsr
         lsr
         lsr
         bit firebutton
         ror firebutton
         bmi waitloopend
         bvc waitloopend
         lda #0
         sta firebutton
         jmp checkhiscore
         
         
         
              ;Import game pointers 
              
              !source "pointers.asm"
    ;-------------------------------------------------------------
              

