        
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
;---------------------------------------------
;Enemy to bullet collision - Macro :)
;--------------------------------------------

!macro enemy2bullet posx, posy, speedx {

  
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
             
              ;Reposition enemy offset as well
              ;as speed
              
              lda #0
              sta speedx
              sta posx 
              sta posy
              
          
.notshot      rts              
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
            jmp removeprocess
.notavailable
}
  

