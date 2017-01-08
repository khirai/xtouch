csound  -m 96 -realtime -+rtaudio=alsa -o dac:hw:${2},3  -Mhw:${1},0,0  xtouch.orc xtouch.sco
