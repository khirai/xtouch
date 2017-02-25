  ar        =  48000
  kr        =  4800
  ksmps     =  10
  nchnls    =  2
gkunits[][] init 18, 16  ;; unit info structure, [unit][param] 
massign 0,0   ;; cause no midi events to trigger score events
giunittab init 2  ;; the table number of the midinotenumber to unit lut

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
  gkunits[gkunit][kparm] = gkunits[gkunit][kparm]+kdelta
 printks   "dial:%d delta:%d value:%d\n",0,kparm ,kdelta, gkunits[gkunit][kparm]   
  endif


;if kstatus== 0xe0 then
;; modify values in the 

;endif

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

    instr 11
            printks   , "midi 11",0.5
    endin