
animmode !byte 0

fleetdir !byte 0 ;Set direction to move the birds accordingly 0 = left, 1 = right
fleetpos !byte 0
fleetdelay !byte 0      
animdelay !byte 0
animpointer !byte 0

;Fleet selector to launch birds

selectorx !byte 0
selectory !byte 0

;Randomizer 

randtemp !byte $5a 
random !byte %10011101,%01011011



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