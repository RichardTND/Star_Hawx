!align $100,0
!ct scr
name !text"         "
nameend
finalscore !byte 0,0,0,0,0,0
checkhiscore
           lda #$35
           sta $01
           ldx #$48
           ldy #$ff
           stx $fffe
           sty $ffff
           lda #$00
           sta $d01a
           sta $d019
           sta $d020
           sta $d021
           sta $d015
           
           ldx #$00
.copyfinalscore
           lda score,x
           sta finalscore,x
           inx
           cpx #6
           bne .copyfinalscore
           
           lda #$1a
           sta $d018
           ldx #$00
clrsid2    lda #$00
           sta $d400,x
           inx
           cpx #$18
           bne clrsid2
           
           lda #0
           sta $d020
           lda #$08
           sta $d016
           lda #0
           sta namefinished
           sta joydelay 
           
           ;Check if the player's score has reached a
           ;position in the high score table.
           
           ldx #$00
nextone    lda hslo,x
           sta $c1
           lda hshi,x
           sta $c2 
           
           ;The hi score table position read is grabbed 
           ;so check the player rank is higher than the
           ;previous hiscores until reached the end
           
           ldy #$00
scoreget   lda finalscore,y
           cmp ($c1),y
           bcc posdown
           beq nextdigit 
           bcs posfound
nextdigit  iny
           cpy #scorelen
           bne scoreget
           beq posfound
posdown    inx
           cpx #listlen
           bne nextone
           beq nohiscor
posfound   stx storbyt
           cpx #listlen-1
           beq lastscor
           
           ;Move all hi scores and name ranks down
           
           ldx #listlen-1
copynext   lda hslo,x
           sta $c1
           lda hshi,x
           sta $c2
           lda nmlo,x
           sta $d1
           lda nmhi,x
           sta $d2 
           dex
           lda hslo,x
           sta $c3
           lda hshi,x
           sta $c4
           lda nmlo,x
           sta $d3
           lda nmhi,x
           sta $d4
           
           ldy #scorelen-1
copyscor   lda ($c3),y
           sta ($c1),y 
           dey
           bpl copyscor
           
           ldy #namelen+1
copyname   lda ($d3),y
           sta ($d1),y
           dey
           bpl copyname
           cpx storbyt 
           bne copynext 
           
lastscor   ldx storbyt
           lda hslo,x
           sta $c1
           lda hshi,x
           sta $c2
           lda nmlo,x
           sta $d1
           lda nmhi,x
           sta $d2
           
           ;Call routine to allow player to sign name
           
           jmp nameentry 
           
           ;Place name to the new hi score
           
placenewscore
            ldy #scorelen-1
putscore    lda finalscore,y
            sta ($c1),y
            dey
            bpl putscore
            ldy #namelen-1
putname     lda name,y
            sta ($d1),y
            dey
            bpl putname
            jsr SaveHiScore
nohiscor            
            jmp titlescreen
            
;=====================================================
;The player has achieved a position in the high score
;table. Do name entry routine (operated by joystick)
;=====================================================

nameentry   ldx #$00
.drawhinamedata
            lda nameentryscreen,x
            sta $0400,x
            lda nameentryscreen+$100,x
            sta $0500,x
            lda nameentryscreen+$200,x
            sta $0600,x
            lda nameentryscreen+$2e8,x
            sta $06e8,x
            lda nameentrycolour,x
            sta $d800,x
            lda nameentrycolour+$100,x
            sta $d900,x
            lda nameentrycolour+$200,x
            sta $da00,x
            lda nameentrycolour+$2e8,x
            sta $dae8,x
            inx
            bne .drawhinamedata
            
            ldx #$00
.clearname
            lda #$20
            sta name,x
            inx
            cpx #9
            bne .clearname
            
            ;Set A char as default char
            
            lda #1
            sta $04
            lda $04
            sta hichar
            
            lda #0
            sta joydelay
            
            ;Init character position 
            
            lda #<name
            sta namesm+1
            lda #>name
            sta namesm+2
            
            lda #$1b
            sta $d011
            
            lda #0
            jsr musicinit 
nameentryloop            
            lda #$f9
            cmp $d012
            bne *-3
            jsr animator
            jsr musicplayer
            ldx #$00
showname    lda name,x
            sta $06e0,x
            lda #3
            sta $dae0,x
            inx
            cpx #9
            bne showname
            
            ;Check that the name entry routine is finished 
            
            lda namefinished
            bne stopnameentry
            jsr joycheck
            jmp nameentryloop
            
stopnameentry
            jmp placenewscore
            
            ;Joystick check routine
            
joycheck    lda hichar
namesm      sta name 
            lda joydelay
            cmp #4
            beq joyhiok
            inc joydelay 
            rts
            
joyhiok     lda #0
            sta joydelay
            
            ;Check joystick up
            
hiup        lda #1
            bit $dc00
            bne hidown
            inc hichar
            lda hichar
            cmp #27
            beq deletechar
            cmp #38
            beq achar
            rts 
            
hidown      lda #2
            bit $dc00
            bne hifire 
            dec hichar
            lda hichar
            beq spacechar
            cmp #34
            beq zchar
            rts 
            
            ;Make char delete
            
deletechar  lda #35
            sta hichar
            rts 
            
            ;Make char spacebar 
spacechar   lda #37
            sta hichar 
            rts
            
            ;Make A char
achar       lda #1
            sta hichar
            rts
            
            ;Make Z char 
zchar       lda #26 
            sta hichar
            rts
            
            ;Keep record if fire has been pressed 
            ;on joystick 
            
hifire      lda $dc00
            lsr
            lsr
            lsr
            lsr
            lsr
            bit firebutton
            ror firebutton
            bmi hinofire
            bvc hinofire
            lda #0
            sta firebutton
            
            ;Check delete pressed
            
            lda hichar
            cmp #35
            bne checkendchar
            
            ;Delete detected 
            lda namesm+1
            cmp #<name
            beq donotgoback
            dec namesm+1
            jsr cleanupname
donotgoback rts

             ;Check for END char
             
checkendchar cmp #36 
             bne charisok
             
             ;Make space char 
             lda #37
             sta hichar
             jmp finishednow
             
             ;Move to next character
             
charisok      inc namesm+1
              lda namesm+1 
              cmp #<name+9 
              beq finishednow
              
hinofire      rts

              ;trigger name entry finished 
              
finishednow   jsr cleanupname
              lda #1
              sta namefinished
              rts 
              
              ;Clear name from rub and end chars
              
cleanupname   ldx #$00
clearchars    lda name,x
              cmp #35
              beq cleanup
              cmp #36
              beq cleanup
              cmp #37
              beq cleanup
              jmp skipcleanup
cleanup       lda #$20
              sta name,x
skipcleanup   inx
              cpx #namelen 
              bne clearchars
              rts
              
joydelay !byte 0
namefinished !byte 0
hichar !byte 0              
              
            
            
            
            
            
            
            
          
           
           
