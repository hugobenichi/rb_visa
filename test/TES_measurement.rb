puts  "-- TES voltage measurement script --","",
      "send complains to hugo.benichi@m4x.org",
      "loading modules..."

require 'rb_visa'
require 'fileutils'
require 'cbuffer'
require 'highline/system_extensions'

data_dir = ""
date = Time.new
base_dir = "%s/%i-%i-%i" % [data_dir, date.year, date.month, date.day]
FileUtils::mkdir_p base_dir
data_path = "%s/%ih%imin"  [base_dir, data.hour, data.min]
data_path += "_%s" % ARGV[0] if ARGV[0]


size      = 1000    # size of one frame
ff_count  = 5000    # ff frames chunk
frm_tot   = 100000  # total frames
chunk     = 100000  # bytes
repet     = 20      # number of curve? cycles
scale     = 1E-6 
sample    = 100E6
 
puts  "datapath: %s" % data_path,
      "samplerate:  %s MHz" % (sample / 100000),
      "scale/div:   %s ms" % (scale * 1000),
      "frame size:  %i bytes" % (sample*scale*10),
      "recording %i FastFrame chunks of %i frames each" % [repet, ff_count],
      "transferring %i bytes at a time (= %i frames)" % [chunk, chunk / (sample*scale*10)]
      

buffer = CBuffer.new( path: data_path, chunk: chunk, length: chunk*126 )


tek = RbVisa::Session.new 'TCPIP0::133.243.104.179::inst0::INSTR'
tek[:VI_ATTR_TMO_VALUE] = :VI_TMO_INFINITE
puts tek.id?
 
[
  "*CLS",
  "HEADER OFF",
  "DISPLAY:WAVEFORM:OFF",
  "SELECT:CH1 ON;CH2 OFF;CH3 OFF;CH4 ON",
  
  "TRIGGER:A:TYPE EDGE",
  "TRIGGER:MODE NORMAL",
  "TRIGGER:LEVEL 1.0",
  "TRIGGER:A:EDGE:SOURCE CH4",
  "TRIGGER:SLOPE RISE",
  
  "HORIZONTAL:FASTFRAME:STATE ON",         
  "HORIZONTAL:FASTFRAME:COUNT #{ff_count}",   
  "HORIZONTAL:FASTFRAME:SEQUENCE FIRST", 
  "HORIZONTAL:MODE:SCALE 1E-6",
  "HORIZONTAL:MODE:SAMPLERATE 100E6",
  "HORIZONTAL:MAIN:POSITION 50",
  
  "DATA:START 1;STOP 1000", 
  "DATA:FRAMESTART 1",
  "DATA:FRAMESTOP #{frm_tot}",
  "DATA:SOURCE CH1",
  "DATA:ENCDG FASTEST",
  "WFMOUTPRE:BYT_NR 1",
  
  "ACQUIRE:SAMPLINGMODE RT",
  "ACQUIRE:MODE SAMPLE",         
  "ACQUIRE:STOPAFTER RUNSTOP",
].each{ |c| tek.write c }


buffer = FFI::MemoryPointer.new :char, 1000000



puts "Tektronix oscillo ready for acquisition",
     "  press return to start"
$stdin.gets

buffer.write{ |count| puts "wrote #{count} chunks of data" }
tek.write "ACQUIRE:STATE RUN"

time_start = Time.new
repet.times do |i|
  puts "chunk number %i" % i
  tek.write "CURVE?"
  read = tek.mread_into(chunk) { buffer.next }
  puts "total read: %i" % read
end
puts "measurement time: %is" % (Time.new-time_start),

buffer.stop
puts "transfer time to HD: %is" % (Time.new-time_start),

tek.write "*CLS"

puts  "measurement script over", 
      "press any key to close this window"
          
HighLine::SystemExtensions::get_character.chr
