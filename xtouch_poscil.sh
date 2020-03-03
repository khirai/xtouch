### alsa
#csound  -m 96 -realtime -+rtaudio=alsa -l -o dac:hw:${2},0  -Mhw:${1},0,0  xtouch_poscil.orc xtouch_poscil.sco

### jack
#csound -realtime -+rtmidi=alsa -M hw:${1},0,0 -+rtaudio=jack -+jack_client=xtouch -b 100 -o dac -i adc xtouch_poscil.orc xtouch_poscil.sco

### soundfile
 #csound  -d -realtime -+rtmidi=alsa -M hw:${1},0,0 -+rtaudio=jack  -b 1024   -i gochakabuchi.wav -o dac  xtouch_poscil.orc xtouch_poscil.sco 

 csound  -d -realtime -+rtmidi=alsa -M hw:${1},0,0   -b 1024   -i gochakabuchi.wav -o dac:hw:${2},0 --num-threads=4  xtouch_tape_layout.orc xtouch_poscil.sco 
