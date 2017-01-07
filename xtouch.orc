  ar        =  48000
  kr        =  4800
  ksmps     =  10
  nchnls    =  2

massign 0,0
giunittab init 2

    instr 1
  kstatus, kchan, kdata1, kdata2  midiin
  gkunit    init      0                           ;

if kstatus == 0x90 then
;; page to unit
  if kdata1 >= 40 then
    if kdata2 == 127 then
      gkunit    tab       kdata1-32, 2
            printks   "button:%d unit change:%d\n",0 , kdata1, gkunit
    endif
  else
            printks   "knob:%d\n",0 ,kdata1-32
  endif
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