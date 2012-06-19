module VISA
  
  module Tek
    {
	    clear!:  "*CLS",
      wait!:   "*WAI",
      next?:   "CURVENEXT?",
      stream?: "CURVESTREAM?",
      go!:     "ACQUIRE:STATE ON",
      run!:    "ACQUIRE:STATE RUN",
      off!:    "ACQUIRE:STATE OFF",
      stop!:   "ACQUIRE:STATE STOP",
    }.each do |name,msg| define_method(name){write msg;self} end  
    def header on_off
      write "HEADER #{on_off == false ? "OFF" : "ON"}"
    end
    def display(state = :on)
      write "DISPLAY:WAVEFORM #{state}".upcase
	  end
    def busy?
      t = query("BUSY?")[0] == '1' 
    end
    def wait_me
      while busy?; 
        print '.'    
        sleep 0.5    
      end
      puts "#{@name} is ready"
    end
    def source chan
      write "DATA:SOURCE CH#{chan}"
    end 
    def curve?(chan=1) 
      source chan
      write "CURVE?" 
      self 
    end 
    def srq_on
      VISA::event_on self
      alias old_go go!
      def go!
        #write "*CLS"
        old_go
        write "*OPC"
      end
      write "DESE 1;*ESE 1;*SRE 32"#;*CLS"
    end
    def srq_off
      VISA::event_off self
      alias go! old_go
    end
    def srq_wait
      VISA::send :event_wait, self 
    end
    
    FRAMES_DEF = '20000'
    TRIGGER_LEVEL = '3.00'
    SCAN_SCALE = '100E-9'
    SCAN_SAMPLE_RATE = '2.50E9'
    SCAN_POSITION = '20'  
    FFT_SCALE = '20E-6'
    FFT_SAMPLE_RATE = '1.00E9'
    FFT_POSITION = '10' #pourquoi pas 50?
    DATA_MAX_PT = '2147400000'
    DATA_MAX_FRM = '2500000'
    
    def self.fft; return {scale:FFT_SCALE, rate:FFT_SAMPLE_RATE, position:FFT_POSITION}; end
    def self.scan; return {scale:SCAN_SCALE, rate:SCAN_SAMPLE_RATE, position:SCAN_POSITION}; end

    DEFAULT = [
      'HORIZONTAL:FASTFRAME:STATE OFF',
      'TRIGGER:A:MODE AUTO',
      'DISPLAY:WAVEFORM ON',
      'ACQUIRE:STOPAFTER RUNSTOP',
      'ACQUIRE:STATE RUN',
    ]
    
    
    class << self #fct for tek settings
      def trigger *args
        ["TRIGGER:A:TYPE EDGE;MODE NORMAL;LEVEL #{TRIGGER_LEVEL}",
        "TRIGGER:A:EDGE:SOURCE AUXILIARY;SLOPE RISE"]
      end           
      def channel(args = [1])
        args = [1] unless args.is_a? Array
        comm = "SELECT:CH1 OFF;CH2 OFF;CH3 OFF;CH4 OFF"
        args.each do |k|
          comm.sub!("#{k} OFF","#{k} ON") if k.is_a? Fixnum and k.between? 1,4
        end
        comm
      end
      def source(chan=1)
        chan = 1 unless chan.is_a? Fixnum and chan.between? 1,4
        "DATA:SOURCE CH#{chan}"
      end    
      def data(width = 1, encode = :fastest)#MSB or LSB for normally read data ? I guess it is MSB
        wdt = (width.is_a? Fixnum and width.between? 1,2)? width: 1
        encd = (encode == :fastest ? :fastest : :ribinary).to_s.upcase!
        ["DATA:START 1;STOP #{DATA_MAX_PT};FRAMESTART 1;FRAMESTOP #{DATA_MAX_FRM}",  
        "DATA:ENCDG #{encd}", 
        "WFMOUTPRE:BYT_NR #{wdt}"]
      end
      def time(args = Tek.scan)
        scale  =   args[:scale]  ||Tek.scan[:scale] 
        rate  =  args[:rate]    ||Tek.scan[:rate] 
        poz    =  args[:pos]    ||Tek.scan[:position]
        ["HORIZONTAL:MODE:SCALE #{'%e' %scale};SAMPLERATE #{'%e' %rate}",
        "HORIZONTAL:MAIN:POSITION #{poz}"]
      end
      def fastframe(args = {frame: FRAMES_DEF,seq: :first, state: :on})
        frame  =  args[:frame]  || FRAMES_DEF 
        seq    =  args[:seq]    || :first
        state  =  args[:state]  || :on
        #frm = (frames.is_a? Fixnum and frames.between? 1,30000)? frames: FRAMES_DEF
        #ste = (state == :off ? :off : :on).to_s.upcase!
        #sqc = (seq == :last ? :last : :first).to_s.upcase!
        "HORIZONTAL:FASTFRAME:STATE #{state};COUNT #{frame};SEQUENCE #{seq}"
      end     
      def acq(run_mod = :seq, acq_mod = :sample)
        mode   = (acq_mod == :hires ? :hires : :sample).to_s.upcase!
        stp   = (run_mod == :run ? :runstop : :sequence).to_s.upcase!
        "ACQUIRE:SAMPLINGMODE RT;MODE #{mode};STOPAFTER #{stp}"
      end
    end
    
  end
  
  Util[:tektron] = Tek
  Address[:tektron] = "TCPIP0::192.168.0.85::inst0::INSTR"
  prompt "Tektronix module loaded"
        
end
