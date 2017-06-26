### alsa
#csound  -m 96 -realtime -+rtaudio=alsa -l -o dac:hw:${2},0  -Mhw:${1},0,0  xtouch_poscil.orc xtouch_poscil.sco

### jack 
# csound -realtime -+rtmidi=alsa -M hw:${1},0,0 -+rtaudio=jack -+jack_client=xtouch -b 1000 -o dac -i adc xtouch_poscil.orc xtouch_poscil.sco

### soundfile
 csound -realtime -+rtmidi=alsa -M hw:${1},0,0 -+rtaudio=alsa  -b 1024 -o dac:hw:${2},0  -i test.wav  xtouch_poscil.orc xtouch_poscil.sco
