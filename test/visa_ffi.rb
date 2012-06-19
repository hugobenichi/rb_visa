VISA_DIR = File.expand_path(File.dirname(__FILE__)) unless defined? VISA_DIR
require "ffi"

module VISA

  class << self
    def prompt message
      puts "VISA >> #{message}"
    end
    def start dev, &block
      return Running[dev] if Running.has_key? dev
      Running[dev] = (new_dev = Session.new start_session VISA::Address[dev])
      new_dev.name = dev
      new_dev.extend Util[dev] if Util.has_key? dev
      new_dev.id_query
      new_dev.instance_eval &block if block
      new_dev
    end
    def close_all
      Running.each_value do |dev| stop_session dev; end
      prompt "all devices closed"
    end
  end  
  
  extend FFI::Library
  ffi_lib VISA_DIR+"/visa_api"
  
  [ 
    [:start_session,    [:string],                  :pointer],
    [:stop_session,     [:pointer],                 :void],
    [:open_tcp_session, [:pointer],                 :int],
    [:close_session,    [:pointer],                 :int],
    
    [:set_attr,         [:pointer,:uint,:int],      :void], 
    [:id_query,         [:pointer],                 :void],
    [:clear,            [:pointer],                 :void],

    [:alloc_buffer,     [:pointer,:int],            :void],
    [:clear_buffer,     [:pointer],                 :void],
    [:flush,            [:pointer],                 :void],
    [:set_visa_buf,     [:pointer,:int],            :void],
    [:set_io_buf,       [:pointer,:int],            :void],
    
    [:write,            [:pointer,:string],         :int],
    [:scan_next,        [:pointer],                 :int],
    [:read,             [:pointer,:pointer,:int],   :int],
    [:query,            [:pointer,:string],         :string],
    
    [:parse_header,     [:pointer],                 :string],
    [:read_n_do,        [:pointer,:int,],           :int],
    [:stream_read,      [:pointer,:int,:int],       :int],
    
    [:event_on,         [:pointer],                 :int],    
    [:event_off,        [:pointer],                 :int],  
    [:event_wait,       [:pointer],                 :int],

    [:tiny_buf_siz,     [],                         :int],

  ].each do |sig| attach_function sig[0], sig[1], sig[2]; end
  
  callback :frame_callback, [:pointer, :int], :int
  
  Running = {}
	Util = {}
	Address = {}
	Address[:self] = "TCPIP0::127.0.0.1::inst0::INSTR"
	['/visa_agl','/visa_tek'].each do |f| require VISA_DIR+f; end
	
	Basics = [
		"data:start 1;data:stop 2500\n",	
		"DATA:ENCDG RIBINARY;WIDTH 1\n",
		"CURVE?\n",
	]
	
	class Settings
  
		include Enumerable
		attr_reader :commands
		
		def initialize dev
			@dev = dev
			@commands = []
			self
		end			
		def each(&blk)
      @commands.each(&blk)
    end
		def <=>(other)
      @list <=> other
    end
		def to_a
      @commands
    end
		def method_missing meth, *args
			@commands = *@commands,*(Util[@dev].send meth, *args) #@name read at call time after init
			self
		end
		def conf &block
			self.instance_eval &block
		end
		def self.default
			Settings.new.trigger.channel(1).data.horz.acquire
		end
				
	end

  prompt "Settings module loaded"
	
  class Session < FFI::ManagedStruct
  
    attr_accessor :return, :name, :settings
    
    layout  :address,       :string,
            :rm,            :uint,
            :instr,         :uint,
            :status,        :int,
            :tiny_buf,      [:char,VISA::tiny_buf_siz],
            :buffer,        :pointer,
            :buf_siz,       :int,
            :frame_functer, :pointer #:frame_callback #ffi_callback must be Proc or Function 

    def self.release ptr
      VISA::stop_session ptr
    end
  
    def return_self arg
      @return = !arg
    end
    def method_missing(sym,*args)
      return VISA.send sym, self, *args if @return
      VISA.send sym, self, *args
      self
    end
    def flush!
      VISA::flush self.name
      self
    end		
    def settings &block
			@settings = Settings.new @name
			@settings.conf &block
			set
		end
		def set
			return if @settings == nil
			@settings.each do |command|
				write command
			end
		end
		def reset
			@settings = Util[@name]::DEFAULT
			set
		end
  end
  
  prompt "Session module loaded"
  
end

VISA::prompt "'visa_ffi' modules loaded"
