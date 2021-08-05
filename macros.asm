        
;---------------------------------------------------        
;Macro code to make enemies fall. Basically we let 
;all of the enemy hawks fall constantly, even when
;not at screen
;---------------------------------------------------

!macro configfall yposition, xspeed {
          
          lda xspeed
          beq .nofall
          lda yposition
          clc
          adc #1
          sta yposition
.nofall          
}
  
;-----------------------------------------------------            
;Macro code to test enemy direction and speed. 
;When the hawks are on set, they can move left/right 
;constantly during play
;-----------------------------------------------------

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
          ; lda #sfxenemydeath3
          ; jsr sfxinit
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
         ; lda #sfxenemydeath3
         ; jsr sfxinit
          lda #rightboundary
.rightok  sta positionx          
          rts
           
}            
;---------------------------------------------
;Enemy to bullet collision - Macro :)
;--------------------------------------------

!macro enemy2bullet posx, posy, speedx, hwspriteframe {

              lda playerbulletdead
              cmp #1
              bne .processcollider
.notshot              
              rts
.processcollider              
              lda posx      ;Zero position - prevent collision
              beq .notshot
              lda speedx    ;Zero x-speed - prevent collision
              beq .notshot
              lda posx
              cmp collider+4
              bcc .notshot
              cmp collider+5
              bcs .notshot
              lda posy
              cmp collider+6
              bcc .notshot
              cmp collider+7
              bcs .notshot 
             
              ;The enemy is shot. We now need to check that 
              ;the enemy shot is a hawk  
              
              lda hwspriteframe
              cmp #$89 
              beq .score100
              cmp #$8a
              beq .score100
              cmp #$8b
              beq .score200
              cmp #$8c
              beq .score200 
              cmp #$8d 
              beq .score300
              cmp #$8e 
              beq .score300
              rts
              
.score100     lda #1
              sta scoretype 
              lda #$90
              sta splatsm+1
              lda #sfxenemydeath1
              jsr sfxinit
              jmp .dorest
              
.score200     lda #2
              sta scoretype 
              lda #$91
              sta splatsm+1
              lda #sfxenemydeath2
              jsr sfxinit
              jmp .dorest 
.score300
              lda #3
              sta scoretype
              lda #$92
              sta splatsm+1
              lda #sfxenemydeath3
              jsr sfxinit
              
              
              ;Reposition enemy offset as well
              ;as speed
.dorest       
              lda #0
              sta splatdelay
              sta speedx
              sta posx 
              sta posy
             
              sta spawndelay 
              dec spawndelayspeed
              lda #0
              sta splatdelay
              lda #1
              sta playerbulletdead
             
              jsr scorecheck
              
              rts              

              
}
;---------------------------------------------------------------
;Constant looping of the enemy char position select counter 
;routine. This will cycle through all of the lo and hi byte
;tables which the select cycle picks out at random after 
;spawntime has run out.
;---------------------------------------------------------------

!macro selection mpointer, source1, target1, source2, target2 {
 
                ldx mpointer 
                lda source1,x
                sta target1
                lda source2,x
                sta target2 
                inx
                cpx #40
                beq .recount 
                inc mpointer
                rts
.recount        ldx #0
                stx mpointer 
                rts
}
              
;-------------------------------------------------------------------------                              
;Pick out any enemy sprite available (enemy 1- enemy 4 as the last 2
;sprites have been reserved for enemy bullet and bonus egg). If no 
;sprites are available, the spawn process is ignored. Otherwise 
;position new enemy sprite and delete the characters that form the 
;same hawk roughly at the same position the new sprite has been spawned to
;-------------------------------------------------------------------------  

!macro spawnhawk xspeed, animationsprite, animsm, posx, posy, removeprocess {

            lda xspeed
            cmp #$00
            bne .notavailable
                      
            lda #<animationsprite
            sta animsm+1
            lda #>animationsprite
            sta animsm+2
           
            lda enemyposx
            sta posx
            lda enemyposy
            sta posy
            lda #1
            sta xspeed 
            jsr removeprocess
            lda #sfxswoop
            jsr sfxinit 
            rts
.notavailable
}

;-------------------------------------------------------
;Macro code for testing which hawk can fire or not. Also 
;check whether the hawk has reached $a0 or lower before
;it can attack and fire laser.
;-------------------------------------------------------

!macro select_hawk_shoot posx, posy {
               lda posy 
               cmp #$42
               bcc .hawkbullnotshoot 
               lda objpos+14
               beq .activate
.hawkbullnotshoot
               rts
.activate      lda posx 
               sta objpos+14
               lda posy 
               sta objpos+15
               lda #sfxplayershoot
               jsr sfxinit
               rts
}               
