!align $ff,0
system !byte 0
ntsctimer !byte 0
waitdelay !byte 0
animmode !byte 0

fleetdir !byte 0 ;Set direction to move the birds accordingly 0 = left, 1 = right
fleetpos !byte 0
fleetdelay !byte 0      
animdelay !byte 0
animpointer !byte 0
fleet1store1lo !byte 0
fleet1store1hi !byte 0

fleet2store1lo !byte 0
fleet2store1hi !byte 0
fleet3store1lo !byte 0
fleet3store1hi !byte 0
fleet4store1lo !byte 0
fleet4store1hi !byte 0

;Fleet selector to launch birds

selectorx !byte 0
spawnstopenabled !byte 0
spawntime !byte 0
spawndelay !byte 0
spawndelayspeed !byte 0

hawktoshoot !byte 0
hawktoshootdelay !byte 0

playerbulletdead !byte 0
splatdelay !byte 0

;Hawk counters
hawkcount !byte 0
maxhawksallowed !byte 1

;Randomizer 

soundloopdelay !byte 0

randtemp !byte $5a 
random !byte %10011101,%01011011

;Animated swooping hawk objects
hawktype1spr !byte $89 
hawktype2spr !byte $8b 
hawktype3spr !byte $8c 

;Animation sprites for the players 
playership !byte $80    
playerbullet !byte $81
playerdeath !byte $82
playershieldpointer !byte 0
shieldavailable !byte 0
shieldtime !byte 0
shieldpointer !byte 0
shieldenabled !byte 0

;Player death animation
playerdeathframe !byte $82,$83,$84,$85,$86,$87,$39,$39,$39,$39,$39,$39,$39,$39,$39,$39,$39,$39,$39,$39,$39,$39,$39,$39,$39,$39
playerdeathframeend !byte $39

playerdeathpointer !byte 0
playerdeathdelay !byte 0


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
eggreleased !byte 0
eggdir !byte 0
eggtimer !byte 0
eggtimerexpiry !byte 177
eggdelay !byte 0

levelpointer !byte 0
levelspeed !byte 0
levelbullspeed !byte 0

enemy1xspeed !byte 1
enemy2xspeed !byte 2
enemy3xspeed !byte 3
enemy4xspeed !byte 4

enemyposx !byte 0
enemyposy !byte 0


;Get READY sprite everytime a new level 
;or game starts, or the player lose a
;life. (2 sprites)
ready1 !byte $94
ready2 !byte $95

;Game over (3 sprites)
gameover1 !byte $96
gameover2 !byte $97
gameover3 !byte $98

;Wave clear (4 sprites)
waveclear1 !byte $99
waveclear2 !byte $9a
waveclear3 !byte $9b
waveclear4 !byte $9c

playertable !byte $80,$80,$80,$80
shieldtable !byte $9d,$9e,$9f,$80

objpos !fill 16,0
hawk1backup1 !fill 17,0
hawk1backup2 !fill 17,0
hawk1backup3 !fill 17,0
hawk1backup4 !fill 17,0
hawk2backup1 !fill 17,0
hawk2backup2 !fill 17,0
hawk2backup3 !fill 17,0
hawk2backup4 !fill 17,0
hawk3backup1 !fill 17,0
hawk3backup2 !fill 17,0
hawk3backup3 !fill 17,0
hawk3backup4 !fill 17,0

;Forcefield colour store pointers

colourpointer !byte 0
colourstore1 !byte 0
colourstore2 !byte 0


;Colour table for the forcefield 

colourtable1 !byte $06,$02,$04,$05,$03,$07,$01,$07,$03,$05,$04,$02
colourtable1end
colourtable2 !byte $01,$07,$03,$05,$04,$02,$06,$02,$04,$05,$03,$07

selectrandompointer !byte 0
selectpointer1 !byte 0
selectpointer2 !byte 0
selectpointer3 !byte 0
selectpointer4 !byte 0
eggscore !byte 0
scoretype !byte 0

;Sprite collision table
collider !byte 0,0,0,0,0,0,0,0

!align $ff,0

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
    
 !align $ff,0

 ;Low/hi byte tables of possible positions for each 
 ;row, top and bottom. Where the pointers will pick 
 ;where to spawn a new hawk. The hawk type checked 
 ;will only be the very first char of each one. 
 ;A selfmod routine will delete the hawk once 
 ;found. So there is no need to do a full table 
 ;for the second row of the same enemy.
 
fleet1table1lo !byte $50,$51,$52,$53,$54,$55,$56,$57
               !byte $58,$59,$5a,$5b,$5c,$5d,$5e,$5f
               !byte $60,$61,$62,$63,$64,$65,$66,$67
               !byte $68,$69,$6a,$6b,$6c,$6d,$6e,$6f 
               !byte $70,$71,$72,$73,$74,$75,$76,$77
              
fleet1table1hi !byte $04,$04,$04,$04,$04,$04,$04,$04
               !byte $04,$04,$04,$04,$04,$04,$04,$04
               !byte $04,$04,$04,$04,$04,$04,$04,$04
               !byte $04,$04,$04,$04,$04,$04,$04,$04 
               !byte $04,$04,$04,$04,$04,$04,$04,$04 
               
fleet2table1lo !byte $c8,$c9,$ca,$cb,$cc,$cd,$ce,$cf
               !byte $d0,$d1,$d2,$d3,$d4,$d5,$d6,$d7 
               !byte $d8,$d9,$da,$db,$dc,$dd,$de,$df
               !byte $e0,$e1,$e2,$e3,$e4,$e5,$e6,$e7 
               !byte $e8,$e9,$ea,$eb,$ec,$ed,$ee,$ef 
               
fleet2table1hi !byte $04,$04,$04,$04,$04,$04,$04,$04
               !byte $04,$04,$04,$04,$04,$04,$04,$04
               !byte $04,$04,$04,$04,$04,$04,$04,$04
               !byte $04,$04,$04,$04,$04,$04,$04,$04
               !byte $04,$04,$04,$04,$04,$04,$04,$04 
               
fleet3table1lo !byte $40,$41,$42,$43,$44,$45,$46,$47
               !byte $48,$49,$4a,$4b,$4c,$4d,$4e,$4f 
               !byte $50,$51,$52,$53,$54,$55,$56,$57
               !byte $58,$59,$5a,$5b,$5c,$5d,$5e,$5f 
               !byte $60,$61,$62,$63,$64,$65,$66,$67 
               
fleet3table1hi !byte $05,$05,$05,$05,$05,$05,$05,$05
               !byte $05,$05,$05,$05,$05,$05,$05,$05
               !byte $05,$05,$05,$05,$05,$05,$05,$05
               !byte $05,$05,$05,$05,$05,$05,$05,$05
               !byte $05,$05,$05,$05,$05,$05,$05,$05 
               
               
fleet4table1lo !byte $b8,$b9,$ba,$bb,$bc,$bd,$be,$bf
               !byte $c0,$c1,$c2,$c3,$c4,$c5,$c6,$c7 
               !byte $c8,$c9,$ca,$cb,$cc,$cd,$ce,$cf
               !byte $d0,$d1,$d2,$d3,$d4,$d5,$d6,$d7 
               !byte $d8,$d9,$da,$db,$dc,$dd,$de,$df
               
fleet4table1hi !byte $05,$05,$05,$05,$05,$05,$05,$05
               !byte $05,$05,$05,$05,$05,$05,$05,$05 
               !byte $05,$05,$05,$05,$05,$05,$05,$05
               !byte $05,$05,$05,$05,$05,$05,$05,$05
               !byte $05,$05,$05,$05,$05,$05,$05,$05
               
spriteposxtable !byte $0a,$0e,$12,$16,$1a,$1e,$22,$26
                !byte $2a,$2e,$32,$36,$3a,$3e,$42,$46
                !byte $4a,$4e,$52,$56,$5a,$5e,$62,$66
                !byte $6a,$6e,$72,$76,$7a,$7e,$82,$86
                !byte $8a,$8e,$92,$96,$9a,$9e,$a0,$a6

;Level settings ... There are 16 levels in total, they should be based on
;the number of enemies that can spawn, hawk speed, and bullet speed 

levelspawntable !byte $01,$02,$03,$04     
              !byte $01,$02,$03,$04
              !byte $01,$02,$03,$04
              !byte $01,$02,$03,$04,$04

levelspeedtable !byte $01,$01,$01,$01
              !byte $01,$01,$01,$01
              !byte $02,$02,$02,$02
              !byte $03,$03,$03,$03 
              
levelbulltable

              !byte $04,$04,$04,$04
              !byte $06,$06,$06,$06 
              !byte $08,$08,$08,$08
              !byte $0a,$0a,$0a,$0a
         
         
         
               
!align $ff,0
       
score           !byte $30,$30,$30,$30,$30,$30 
hiscore         !byte $30,$30,$30,$30,$30,$30
lives           !byte $03 
level           !byte $30,$31
 