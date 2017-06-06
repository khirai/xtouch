  ar        =  48000
  kr        =  4800
  ksmps     =  10
  nchnls    =  2

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


; lut structures
;            type flag beg end data...
; where type can be
;   linear wrap/lim/none  mult off 
;   lut    wrap/lim
;   

  gkunits   [][] init   18,16                     ;; unit info structure, [unit][param]
  gkunitlut [][] init   18,16                     ;; number of the table to index into
  gkunitlutlen [][] init   18,16                     ;; length of the table to index into
  gkunitval [][] init   18,16                     ;; ultimate value assigned from lut
 
massign 0,0   ;; cause no midi events to trigger score events
giunittab init 2  ;; the table number of the midinotenumber to unit lut

;;audio initialization
gitabl ftgen 0, 0, sr*8, 2, 0
gitabend tableng gitabl


    instr 1
;; read raw data from the xtouch device in mc mode
  kstatus, kchan, kdata1, kdata2  midiin
  gkunit    init      0 ;; the current active unit number    ;

  if kstatus == 0x90 then 
     ;; we received a button or a knob press
    if kdata1 >= 40 then
      ;; receieved a  button press, change the unit
      if kdata2 == 127 then
         ;; look up unit associated with note number
              gkunit    tab       kdata1-32, giunittab
              printks   "button:%d unit change:%d\n",0 , kdata1, gkunit
      endif
    else
      ;; its a knob press, stub
              printks   "knob:%d\n",0 ,kdata1-32
    endif
  elseif kstatus == 0xb0 then
    ;; received a knob turn,  change the unit data proportionately
    kparm = kdata1-16
    if kdata2 >40 then
      kdelta    =  64 - kdata2
    else
      kdelta    =  kdata2
    endif
    ;; stub, we need to index a table here unless the table number is zero
    gkunits   [gkunit   ][kparm] = gkunits[gkunit][kparm]+kdelta
 

    ;; call back for unit param
  kft       =  gkunitlut[gkunit][kparm]
  kftlen    =  gkunitlutlen[gkunit][kparm]
    if  kft  == 0 then   ;passsthough
      gkunitval[gkunit][kparm] = gkunits[gkunit][kparm]
    else     ;read from table
      if gkunits[gkunit][kparm] < 1 then
        gkunits   [gkunit   ][kparm] = 1
      endif
      gkunitval[gkunit][kparm]  tab kft, gkunits[gkunit][kparm]%kftlen 
    endif
  
            printks   "dial:%d delta:%d raw:%d val:%d\n",0,kparm ,kdelta, gkunits[gkunit][kparm],gkunitval[gkunit][karam]   

;if kstatus== 0xe0 then
;; modify values in the 

  endif

  ktime     times     
            printf    "w: stat:%x chan:%x dat1:%x dat2:%x unit:%d time:%f\n",kstatus,  kstatus, kchan, kdata1, kdata2, gkunit,  ktime
;           printf   "%x %x %x %x %f\n",kstatus,  kstatus, kchan, kdata1, kdata2, ktime


    endin

    instr 2
  kcnt      init      0
  kmod      init      49 
        
if kcnt % kmod == 0 then
            printks   , "i2 %d\n", 0.5, kcnt/kmod%12+1
            outkc 1,9,kcnt/kmod%12+1,0,127

;            midiout   176, 0, kcnt/kmod%8+9,kcnt/kmod%12+1
endif
  kcnt      =  kcnt +1

    endin

;; recording instr
    instr 10
  ainl, ainr   ins    
  arecpos   phasor    sr
            tabw      ainl, arecpos, gitabl
    endin

;;playback
    instr 11
  gkunitlut [p4][0] init p5

kunit=p4
kspeed=gunitval[0][0]
  aoutl     lposcil   4096, kspeed, 0, gitabend, gitabl
            outs      aoutl,aoutr
    endin


    instr 100
            printks   , "midi 11",0.5
    endin