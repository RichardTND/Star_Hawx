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

  !source "variables.asm"
  !source "macros.asm"

          ;Generate program

          !to "starhawx.prg",cbm
          
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
          
          
          !source "titlescreen.asm"
          
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
         ; *=$2fc0
         ; !fill $40,0
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
            !source "gamecode.asm"
;=========================================
          ;Sound effects 
          *=$7000
          !bin "bin\sfx.prg",,2
          
;=========================================          
