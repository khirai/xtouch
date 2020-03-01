ar        =  44100
kr        =  4410
ksmps     =  10
nchnls    =  2
0dbfs     =  1
;; xouch initialization

#define LUT_ADDR_TYPE # 0 #
#define LUT_ADDR_FLAG # 1 #
#define LUT_ADDR_BEG # 2 #
#define LUT_ADDR_END # 3 #
#define LUT_ADDR_DATA # 4 #
#define LUT_ADDR_MULT # 4 #
#define LUT_ADDR_OFF  # 5 #

#define LUT_TYPE_RAW # 0 #
#define LUT_TYPE_LIN  # 1 #
#define LUT_TYPE_TAB  # 2 # 

#define LUT_FLAG_WRAP # 1 #
#define LUT_FLAG_LIM  # 2 #
#define NUM_PARAM " 2 "
#define NUM_UNIT " 8 "

; lut structures
;            type flag beg end data...
; where type can be
;   linear wrap/lim/none  mult off 
;   lut    wrap/lim
;   

gkunits   [][] init      NUM_PARAM,NUM_UNIT                  ;; unit info structure, [unit][param]
gkunitlut [][] init      NUM_PARAM,NUM_UNIT                  ;; number of the table to index into
gkunitlutlen [][] init   NUM_PARAM,NUM_UNIT                  ;; length of the table to index into
gkunitval [][] init      NUM_PARAM,NUM_UNIT                  ;; ultimate value assigned from lut
gSdisp [] init NUM_PARAM
massign   0,0                         ;; cause no midi events to trigger score events
giunittab init 2  ;; the table number of the midinotenumber to unit lut

gimaxunit init 2

;;audio initialization
gitabl ftgen 0, 0, sr*2, 2, 0
gitabend tableng gitabl


instr 1
;; read raw data from the xtouch device in mc mode
  kstatus, kchan, kdata1, kdata2  midiin
  gkparam    init      0 ;; the current active unit number    ;
  gkount    init      0
  gktrig    metro     4
  gkount    +=        gktrig


  if kstatus == 0x90 then 
     ;; we received a button or a knob press
    if kdata1 >= 40 then
      ;; receieved a  button press, trigger unit action
      if kdata2 == 127 then
         ;; look up unit associated with note number
            ;  gkunit    tab       kdata1-32, giunittab
              printks   "button:%d\n",0 , kdata1
      endif
    else
      ;; its a knob press, change parameter
           gkparam = (gkparam + 1) % NUM_PARAM 
           ;   printks   "knob:%d\n",0 ,kdata1-32
    endif
  elseif kstatus == 0xb0 then
     ;; received a knob turn,  change the unit data proportionately
    kunit = kdata1-16
    if kdata2 >40 then
      kdelta    =  64 - kdata2
    else
      kdelta    =  kdata2
    endif
    ;; stub, we need to index a table here unless the table number is zero
    gkunits   [gkparam ][kunit] = gkunits[gkparam][kunit]+kdelta
 

    ;; call back for unit param
  kft       =  gkunitlut[gkparam][kunit]
  kftlen    =  gkunitlutlen[gkparam][kunit]
    if  kft  == 0 then   ;passsthough
      gkunitval[gkparam][kunit] = gkunits[gkparam][kunit]
    else     ;check boundries , read from table 
      kunitlim limit gkunits[gkparam][kunit], 0 , kftlen
      gkunits   [gkparam][kunit] = kunitlim
      gkunitval [gkparam][kunit]  tablekt  kunitlim  , kft
    endif
  
;    printks   "unit: %d pram:%d delta:%d raw:%d lut:%d val:%f\n",0,gkunit, kparm ,kdelta, gkunits[gkunit][kparm],kft, gkunitval[gkunit][kparm]   

;if kstatus== 0xe0 then
;; modify values in the 
;; endif

  endif

;  ktime     times     
;            printf    "w: stat:%x chan:%x dat1:%x dat2:%x unit:%d time:%f\n",kstatus,  kstatus, kchan, kdata1, kdata2, gkunit,  ktime
;           printf   "%x %x %x %x %f\n",kstatus,  kstatus, kchan, kdata1, kdata2, ktime

;; initialize the pack on the virtical display strings
if gktrig ==1 then


    gSdisp    [k(0        )] = "1:"
    gSdisp    [k(1        )] = "2:"
    gSdisp    [k(2        )] = "3:"
    gSdisp    [k(3        )] = "4:"
    gSdisp    [k(4        )] = "5:"
    gSdisp    [k(5        )] = "6:"
    gSdisp    [k(6        )] = "7:"
    gSdisp    [k(7        )] = "8:"
endif


    endin

    instr 2  ;; supposed to do the light show, not sure which mode its got to be in
  kcnt      init      0
  kmod      init      49 
        
if kcnt % kmod == 0 then
           ; printks   , "i2 %d\n", 0.5, kcnt/kmod%12+1
            outkc 1,9,kcnt/kmod%12+1,0,127

;            midiout   176, 0, kcnt/kmod%8+9,kcnt/kmod%12+1
endif
  kcnt      =  kcnt +1

    endin

    instr 9  ;;; loop size control p4=unit 

;; manages loop start and loop end in 2 dividors of the
  gktabscend   init   gitabend
  Sdisp     [] init   16
  gkunitlut[0][p4] init p5
  gkunitlutlen [0][p4] init ftlen(p5)
  gkunitlut[1][p4] init p5
  gkunitlutlen [1][p4] init ftlen(p5)
  
  gktabscend    =  gkunitval[0][p4]*gkunitval[1][p4]*gitabend

  if gktrig ==1 then
    kitr=0
    while kitr<NUM_PARAM do
      Sdisp[kitr]   sprintfk "%s %8.3f",gSdisp[kitr],gkunitval[kitr][p4]
      gSdisp    [kitr     ] strcpyk Sdisp[kitr]
      kitr+=1
    od
  endif

    endin


;; recording instr
    instr 10
  Sdisp     [] init   16 
  gkunitlut[0][p4] init p5
  gkunitlutlen [0][p4] init ftlen(p5)
  kspeed    =  gkunitval[0][p4]
  if gktrig ==1 then
    kitr=0
    while kitr<NUM_PARAM do
      Sdisp     [kitr] sprintfk "%s %8.3f",gSdisp[kitr],gkunitval[kitr][p4]
      gSdisp    [kitr     ] strcpyk Sdisp[kitr]
      kitr+=1
    od
  endif
  ainl, ainr   ins    
 ktabscend limit gktabscend, kr, gitabend
  arecpos   phasor    sr/ktabscend * kspeed
            tabw      ainl, arecpos*ktabscend, gitabl


    endin

;;playback
    instr 11
  Sdisp     [] init   16
  gkunitlut [0][p4] init p5
  gkunitlutlen [0][p4    ] init ftlen(p5)
  kvol      =  gkunitval[1][p4]*gkunitval[1][p4] * 0.001
   kpan =  0.5 ;(gkunitval[2][p4]+50)/100
  kspeed    =  gkunitval[0][p4]
if gktrig == 1 then
    kitr=0
    while kitr<NUM_PARAM do
      Sdisp     [kitr] sprintfk "%s %8.3f",gSdisp[kitr],gkunitval[kitr][p4]
      gSdisp    [kitr     ] strcpyk Sdisp[kitr]
      kitr+=1
    od
 endif
  aout      lposcil3   1, kspeed, 0, gktabscend, gitabl
  aoutl, aoutr pan2   aout*kvol, kpan 
            outs      aoutl ,aoutr
    endin


    instr 100
  printf    "       %d        2        3        4        5        6        7        8\n",gktrig,1
 kitr=0
while kitr < NUM_PARAM do
  printf"%s\n", gktrig, gSdisp[kitr]
  kitr=kitr+1
od

;  printf"%s\n", gktrig, gSdisp[k(1)]
;  printf"%s\n", gktrig, gSdisp[k(2)]
;  printf"%s\n", gktrig, gSdisp[k(3)]
;  printf"%s\n", gktrig, gSdisp[k(4)]
;  printf"%s\n", gktrig, gSdisp[k(5)]
;  printf"%s\n", gktrig, gSdisp[k(6)]
;  printf"%s\n", gktrig, gSdisp[k(7)]

;;  printf    "%s%s%s%s%s%s%s%s%d:%d\n", gkount,gSunitdisp[1],gSunitdisp[2],gSunitdisp[3],gSunitdisp[4],gSunitdisp[5],gSunitdisp[6],gSunitdisp[7],gSunitdisp[8],gkount,gktrig

    endin
