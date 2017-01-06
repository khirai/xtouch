  ar        =  48000
  kr        =  4800
  ksmps     =  10
  nchnls    =  2

massign 0,0

    instr 1
  kstatus, kchan, kdata1, kdata2                  midiin              
            printks   ,"w: stat:%d chan:%d dat1:%d dat2:%d\n", 0.1, kstatus, kchan, kdata1, kdata2


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