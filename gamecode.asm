;----------------------------------------
;Main game code
;----------------------------------------

gamestart
          ;Like with the front end switch 
          ;off all interrupts 
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
          stx $fffe
          sty $ffff
          ldx #<nmi 
          ldy #>nmi
          stx $fffa
          sty $fffb
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
girq1     pha
          txa
          pha
          tya
          pha
          asl $d019
          lda $dc0d
          sta $dd0d
          lda #$f8
          sta $d012
          lda #1
          sta rt
          jsr musicplay
          pla
          tay
          pla
          tax
          pla
nmi       rti          
          
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
          lda #0
          sta enemy1xspeed
          sta enemy2xspeed
          sta enemy3xspeed
          sta enemy4xspeed
          sta spawnstopenabled
          sta spawntime
         
         
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
          jsr spritetosprite
          jsr randomselector
          
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
           lda #1
           sta scoretype
           jmp killhawkleft
nothawk1a  cmp #hawktype1b 
           bne nothawk1b
           lda #1
           sta scoretype 
           jmp killhawkright 
nothawk1b  cmp #hawktype1c 
           bne nothawk1c 
           lda #1
           sta scoretype
           jmp killhawkleft 
nothawk1c  cmp #hawktype1d 
           bne nothawk1d
           lda #1
           sta scoretype
           jmp killhawkright
           
nothawk1d  cmp #hawktype2a
           bne nothawk2a
           lda #2
           sta scoretype 
           jmp killhawkleft 
nothawk2a  cmp #hawktype2b 
           bne nothawk2b
           lda #2
           sta scoretype 
           jmp killhawkright 
nothawk2b  cmp #hawktype2c 
           bne nothawk2c
           lda #2
           sta scoretype 
           jmp killhawkleft 
nothawk2c  cmp #hawktype2d 
           lda #2
           sta scoretype 
           bne nothawk2d 
           jmp killhawkright 
nothawk2d          
           cmp #hawktype3a 
           bne nothawk3a 
           lda #3
           sta scoretype
           jmp killhawkleft 
nothawk3a  cmp #hawktype3b 
           bne nothawk3b
           lda #3
           sta scoretype
           jmp killhawkright
nothawk3b  cmp #hawktype3c 
           bne nothawk3c
           lda #3
           sta scoretype 
           jmp killhawkleft 
nothawk3c  cmp #hawktype3d 
           bne nothawk3d
           lda #3
           sta scoretype 
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
           bne bgcloop01
           rts
bgcloop01  jmp bgcloop           
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
            jmp scorecheck
              
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
            jmp scorecheck
           
        
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
            jsr checklevelcomplete
            lda #$ff 
            sta $07ff ;Inivisible sprite spawner
            lda enemy1xspeed 
            sta $07e7-3
            lda enemy2xspeed
            sta $07e7-2
            lda enemy3xspeed
            sta $07e7-1
            lda enemy4xspeed
            sta $07e7
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
            cmp #$fa
            bcc notoffset
            lda #0
            sta objpos+$0d
notoffset            
            sta objpos+$0c
            
            rts
            
testegg     rts       
            lda bonusegg
            sta $07ff

           ; lda objpos+$0f 
          ;  clc
         ;   adc #4
           ; sta objpos+$0f 
            lda #$60
            sta objpos+$0e
            lda #$05
            sta $d02e
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
testswoop2  +configfall objpos+7, enemy2xspeed
            +confighawkswoop enemy2dir, objpos+6, enemy2xspeed
testswoop3  +configfall objpos+9, enemy3xspeed
            +confighawkswoop enemy3dir, objpos+8, enemy3xspeed
testswoop4  +configfall objpos+11, enemy4xspeed
            +confighawkswoop enemy4dir, objpos+10, enemy4xspeed
            
  
;----------------------------------------
;Sprite to sprite collision routines 
;two checks - enemies to play and 
;enemies to bullet.
;----------------------------------------

spritetosprite
              lda objpos 
              sec
              sbc #playercollisionleft
              sta collider
              clc
              adc #playercollisionright
              sta collider+1
              
              lda objpos+1
              sec
              sbc #playercollisionup 
              sta collider+2
              clc
              adc #playercollisiondown
              sta collider+3
              
              lda objpos+2
              sec
              sbc #bulletcollisionleft 
              sta collider+4
              clc
              adc #bulletcollisionright 
              sta collider+5
              
              lda objpos+3
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
              jsr enemy2bullet4
             ; jsr egg2bullet
              rts
              
              ;Player to enemy collision. This is 
              ;a very simple loop 
              
playertoenemy
              ldx #$00
p2echeckloop              
              lda objpos+4,x
              cmp collider
              bcc playernothit
              cmp collider+1
              bcs playernothit
              lda objpos+5,x
              cmp collider
              bcc playernothit
              cmp collider+1
              bcs playernothit
              
              ;Player is hit
              sta $07c0
              
              rts
playernothit  inx
              inx
              cpx #$0c
              bne p2echeckloop
              rts
              
enemy2bullet1  +enemy2bullet objpos+4, objpos+5, enemy1xspeed
enemy2bullet2  +enemy2bullet objpos+6, objpos+7, enemy2xspeed
enemy2bullet3  +enemy2bullet objpos+8, objpos+9, enemy3xspeed
enemy2bullet4  +enemy2bullet objpos+10, objpos+11, enemy4xspeed

;Special routine for egg 2 bullet since egg only 
;falls and uses no X-movement. 

egg2bullet      lda objpos+14
                beq .noeggshot
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
                lda #0
                sta objpos+14
                sta objpos+15
.noeggshot                
                rts
                
;-----------------------------------------------------------------
;Check level complete ...   A simple routine which will check
;to see whether or not all of the bird chars have been removed
;and also all bird sprites xspeed = 0
;-----------------------------------------------------------------

checklevelcomplete
               ldx #$00
checklevloop   lda $0450,x
               cmp #$20
               bne .hawkexists
               lda $0450+200,x
               cmp #$20
               bne .hawkexists 
               inx
               cpx #200
               bne checklevloop
               lda #1 ;Stop spawning new birds 
               sta spawnstopenabled
               ldx #$00
checkspeedloop lda enemy1xspeed,x
               bne .hawkexists
               inx
               cpx #4
               bne checkspeedloop
               inc $d020
               jmp *-3 ;Level completed
.hawkexists    rts               
               
;-------------------------------------
; Random launch of enemy bird sprites
;-------------------------------------


randomselector  jsr cycleselection1
                jsr cycleselection2
                jsr cycleselection3
                jsr cycleselection4
                jsr cyclespriteposition
                
                lda spawndelay
                cmp #1
                beq spawnnextifpossible
                inc spawndelay
                rts 
spawnnextifpossible                
                lda #0
                sta spawndelay
                jsr getrandom
                and #$07
                sta selectrandompointer
                lda selectrandompointer
                cmp #1
                bne .notselectfleet1
                jmp selectfleet1
.notselectfleet1
                cmp #2
                bne .notselectfleet2
                jmp selectfleet2 
.notselectfleet2
                cmp #3
                bne .notselectfleet3 
                jmp selectfleet3
.notselectfleet3
                cmp #4
                bne .noselection 
                jmp selectfleet4
.noselection    rts

;A fleet row has been selected to check for the bird type ...

selectfleet1    lda #1
                sta $d020
                lda #fleet1spriteypos
                sta enemyposy 
                lda fleet1store1lo 
                sta fleetcharsm+1
                lda fleet1store1hi
                sta fleetcharsm+2
                jmp spawnnewenemycheck
                
selectfleet2    lda #2
                sta $d020 
                lda #fleet2spriteypos
                sta enemyposy
                lda fleet2store1lo 
                sta fleetcharsm+1
                lda fleet2store1hi 
                sta fleetcharsm+2
                jmp spawnnewenemycheck
            
selectfleet3    lda #3
                sta $d020 
                lda #fleet3spriteypos
                sta enemyposy
                lda fleet3store1lo 
                sta fleetcharsm+1
                lda fleet3store1hi 
                sta fleetcharsm+2 
                jmp spawnnewenemycheck
             
selectfleet4    lda #4
                sta $d020
                lda #fleet4spriteypos
                sta enemyposy
                lda fleet4store1lo 
                sta fleetcharsm+1
                lda fleet4store1hi 
                sta fleetcharsm+2
                
spawnnewenemycheck 
                
fleetcharsm     lda $cccc ;<- selfmod 
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
                ;jsr deletefromleft
                jmp spawnhawk1left
.nothawk03d
                rts               
dospawnhawk1backwards 
                ;jsr deletefromright
                jmp spawnhawk1right
                
                
dospawnhawk2forwards 
                ;jsr deletefromleft 
                jmp spawnhawk2left
dospawnhawk2backwards 
                ;jsr deletefromright 
                jmp spawnhawk2right 

dospawnhawk3forwards 
                ;jsr deletefromleft 
                jmp spawnhawk3left
dospawnhawk3backwards 
                ;jsr deletefromright
                jmp spawnhawk3right
                
;Delete characters from top left 

deletefromleft  lda fleetcharsm+1
                sta delleftsm+1
                lda fleetcharsm+2
                sta delleftsm+2
                
                lda fleetcharsm+1
                clc
                adc #40
                sta delleftsm2+1
                lda fleetcharsm+2
                clc
                adc #$00
                sta delleftsm2+2 
                
                ldx #$00
leftrub         lda #$20                
delleftsm       sta $c000,x
delleftsm2      sta $c028,x              
                inx 
                cpx #2
                bne leftrub
               
                rts

deletefromright lda fleetcharsm+1
               
                sta delrightsm+1
                lda fleetcharsm+2
                sta delrightsm+1
                lda fleetcharsm+1
                clc
                adc #40
                sta delrightsm2+1 
                lda fleetcharsm+1
                clc 
                adc #$00
                sta delrightsm2+2
                ldx #$01
rightrub        lda #$20
delrightsm     sta $c000,x 
delrightsm2    sta $c028,x 
                dex 
                bpl rightrub
                 
                rts
             
;--------------------------------------------------                
;Cycle subroutines of the lo and hi byte table for 
;each of the enemy fleet objects
;--------------------------------------------------
cycleselection1 +selection selectpointer1, fleet1table1lo, fleet1store1lo, fleet1table1hi, fleet1store1hi
cycleselection2 +selection selectpointer2, fleet2table1lo, fleet2store1lo, fleet2table1hi, fleet2store1hi 
cycleselection3 +selection selectpointer3, fleet3table1lo, fleet3store1lo, fleet3table1hi, fleet3store1hi 
cycleselection4 +selection selectpointer4, fleet4table1lo, fleet4store1lo, fleet4table1hi, fleet4store1hi                
rts

cyclespriteposition ldx selectorx
                    lda spriteposxtable,x 
                    sta enemyposx
                    inx 
                    cpx #40
                    beq .resetspriteread
                    inc selectorx
                    rts
.resetspriteread    ldx #0
                    stx spriteposxtable
                    rts
;Spawn any of the hawk sprites where 
;available.
spawnhawk1left
            
            +spawnhawk enemy1xspeed, hawktype1spr, hawk1sm, objpos+4, objpos+5, deletefromleft
            +spawnhawk enemy2xspeed, hawktype1spr, hawk2sm, objpos+6, objpos+7, deletefromleft
            +spawnhawk enemy3xspeed, hawktype1spr, hawk3sm, objpos+8, objpos+9, deletefromleft
            +spawnhawk enemy4xspeed, hawktype1spr, hawk4sm, objpos+10, objpos+11, deletefromleft
            rts
spawnhawk1right

            +spawnhawk enemy1xspeed, hawktype1spr, hawk1sm, objpos+4, objpos+5, deletefromright
            +spawnhawk enemy2xspeed, hawktype1spr, hawk2sm, objpos+6, objpos+7, deletefromright
            +spawnhawk enemy3xspeed, hawktype1spr, hawk3sm, objpos+8, objpos+9, deletefromright
            +spawnhawk enemy4xspeed, hawktype1spr, hawk4sm, objpos+10, objpos+11, deletefromright
            rts            
spawnhawk2left
            
            +spawnhawk enemy1xspeed, hawktype2spr, hawk1sm, objpos+4, objpos+5, deletefromleft
            +spawnhawk enemy2xspeed, hawktype2spr, hawk2sm, objpos+6, objpos+7, deletefromleft
            +spawnhawk enemy3xspeed, hawktype2spr, hawk3sm, objpos+8, objpos+9, deletefromleft
            +spawnhawk enemy4xspeed, hawktype2spr, hawk4sm, objpos+10, objpos+11, deletefromleft
            rts
spawnhawk2right

            +spawnhawk enemy1xspeed, hawktype2spr, hawk1sm, objpos+4, objpos+5, deletefromright
            +spawnhawk enemy2xspeed, hawktype2spr, hawk2sm, objpos+6, objpos+7, deletefromright
            +spawnhawk enemy3xspeed, hawktype2spr, hawk3sm, objpos+8, objpos+9, deletefromright
            +spawnhawk enemy4xspeed, hawktype2spr, hawk4sm, objpos+10, objpos+11, deletefromright
            
spawnhawk3left
            
            +spawnhawk enemy1xspeed, hawktype3spr, hawk1sm, objpos+4, objpos+5, deletefromleft
            +spawnhawk enemy2xspeed, hawktype3spr, hawk2sm, objpos+6, objpos+7, deletefromleft
            +spawnhawk enemy3xspeed, hawktype3spr, hawk3sm, objpos+8, objpos+9, deletefromleft
            +spawnhawk enemy4xspeed, hawktype3spr, hawk4sm, objpos+10, objpos+11, deletefromleft
            
            rts
            
spawnhawk3right
            
            +spawnhawk enemy1xspeed, hawktype3spr, hawk1sm, objpos+4, objpos+5, deletefromright
            +spawnhawk enemy2xspeed, hawktype3spr, hawk2sm, objpos+6, objpos+7, deletefromright
            +spawnhawk enemy3xspeed, hawktype3spr, hawk3sm, objpos+8, objpos+9, deletefromright
            +spawnhawk enemy4xspeed, hawktype3spr, hawk4sm, objpos+10, objpos+11, deletefromright
            
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
;Game scoring routines 
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
                jmp updatepanel
            
;Update panel with score 
                
updatepanel     ldx #$00
copyscore       lda score,x
                sta scorepos,x
                inx 
                cpx #$06 
                bne copyscore
                rts
               
                
    ;-------------------------------------------------------------
              ;Import game pointers 
              
              !source "pointers.asm"
    ;-------------------------------------------------------------
              

