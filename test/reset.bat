@echo off
setlocal enableDelayedExpansion
set NL=^


rem two empty line required
set program=require 'rb_visa'
set program=!program!!NL!require 'highline/system_extensions'
set program=!program!!NL!include HighLine::SystemExtensions
set program=!program!!NL!address = 'TCPIP0::133.243.104.179::inst0::INSTR'
set program=!program!!NL!puts '', 'default parameters for ' + address
set program=!program!!NL!tek = RbVisa::Session.new address
set program=!program!!NL!puts tek.id?
set program=!program!!NL!tek.write 'HORIZONTAL:FASTFRAME:STATE OFF'
set program=!program!!NL!tek.write 'SELECT:CH1 ON;CH2 OFF;CH3 OFF;CH4 OFF'
set program=!program!!NL!tek.write 'TRIGGER:A:TYPE EDGE;MODE NORMAL;LEVEL 1.0'
set program=!program!!NL!tek.write 'TRIGGER:A:MODE AUTO'
set program=!program!!NL!tek.write 'HORIZONTAL:MODE:SCALE 2E-3;SAMPLERATE 500E3'
set program=!program!!NL!tek.write 'HORIZONTAL:MAIN:POSITION 50'
set program=!program!!NL!tek.write 'DISPLAY:WAVEFORM ON'
set program=!program!!NL!tek.write 'ACQUIRE:STOPAFTER RUNSTOP'
set program=!program!!NL!tek.write 'ACQUIRE:STATE RUN'
set program=!program!!NL!puts 'press any key to close this window'
set program=!program!!NL!get_character.chr

ruby -e "!program!"