module RbVisa

  class Session
  
    attr_reader :session, :rm, :status, :address
 
    def initialize address, &block
      mem = FFI::MemoryPointer.new :uint32, 1
      check VISA::viOpenDefaultRM mem
      @rm = mem.read_uint32
      @address = address
      check VISA::viOpen( @rm, @address, VISA::VI_NULL, VISA::VI_NULL, mem)
      @session = mem.read_uint32
      
      @string_buffer_length = 126
      @string_buffer = FFI::MemoryPointer.new :char, @string_buffer_length
      
      self.instance_eval &block if block
      self
    end
    
    def close
      check VISA::viClose @session
      check VISA::viClose @rm
    end
        
    def self.release object
      object.close
    end
    
    def check status
      puts self.status? if 0 != (@status = status)
      self
    end
    
    def status?
      @error_buffer ||= FFI::MemoryPointer.new :char, 256
      VISA::viStatusDesc @session, @status, @error_buffer
      @error_buffer.read_string
    end
    
    def clear
      check VISA::viClear @session
      self
    end
    
    def flush mask_val = VISA::VI_READ_BUF_DISCARD
      check VISA::viFlush @session, mask_val
      self
    end
    
    def buffer params = {}      
      VISA::Buffer.each_pair{ |buf,mask|
        check VISA::viSetBuf( @session, mask, params[buf] ) if params[buf] && params[buf] > 0
      } if params.is_a? Hash
      self
    end
    
    def attribute= params = {}
      params.each_pair{ |attrib, value|
        check VISA::viSetAttribute( @session, attrib, value )
      } if params.is_a? Hash
      self
    end
    
    def attribute params = []
      mem = FFI::MemoryPointer.new :uint32, 1   
      Hash.new.tap{ |values|       
        params.each{ |attrib|
          check VISA::viGetAttribute( @session, attrib, mem )
          values[attrib] = mem.read_uint32
        }       
      } if params.is_a? Hash
    end
    
    require 'rb_visa/io'
  
  end
	
end
