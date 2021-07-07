
;Variables and pointers

;Zero page pointers

screenlostore = $02
screenhistore = $03
screenlostore2 = $04
screenhistore2 = $05

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

;Collision co-ordinates 

playercollisionleft = $06
playercollisionright = $0c
playercollisionup = $0c
playercollisiondown = $18

bulletcollisionleft = $06
bulletcollisionright = $0c
bulletcollisionup = $0c 
bulletcollisiondown = $18


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