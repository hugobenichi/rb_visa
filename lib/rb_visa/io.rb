module RbVisa

  class Session
  
    def buffer_grow size
      if size > @string_buffer_length
        @string_buffer = FFI::MemoryPointer.new :char, size
        @string_buffer_length = size
      end     
    end
    
    def write command
      buffer_grow command.length
      @string_buffer.write_string command
      @read_count ||= FFI::MemoryPointer.new :uint32, 1     
      check VISA::viWrite @session, @string_buffer, command.length, @read_count      
puts "write count %i" % @read_count.read_uint32
      self     
    end

    def read bytes = @string_buffer_length
      buffer_grow bytes
      @read_count ||= FFI::MemoryPointer.new :uint32, 1     
      check VISA::viRead @session, @string_buffer, bytes, @read_count
puts "read count %i" % @read_count.read_uint32
      @string_buffer.read_string
    end 
    
    #alias_method :puts, :write
    #alias_method :gets, :read
    
    def << command
      self.write command
    end 
    
    def query command
      self.write(command).read
    end
    
    def id?
      query "*idn?"   
    end
    
    def parse
      @read_count ||= FFI::MemoryPointer.new :uint32, 1     
      
      comp   = "#".bytes.first
      offset = '0'.bytes.first
       
      #find beginning of header      
      while true
         check VISA::viRead @session, @string_buffer, 1, @read_count
         break if comp == @string_buffer.read_char
      end
      
      #read the size of the header tag
      check VISA::viRead @session, @string_buffer, 1, @read_count
      data_size_tag_size = @string_buffer.read_char - offset

      #read the header tag and parse into an int
      check VISA::viRead @session, @string_buffer, data_size_tag_size, @read_count      
      @string_buffer.read_array_of_char(data_size_tag_size).map{ |c|
        c - offset
      }.join.to_i     
    end
    
    def mread_into chunk, &next_buffer   
      total = 0
      (self.parse / chunk).times do 
        VISA::viRead @session, next_buffer.call, chunk, @read_count   
        total += @read_count.read_uint32
      end
    end
    
    def mread_to chunk, &handle_data
      buffer_grow.chunk
      total = 0
      (self.parse / chunk).times do 
        VISA::viRead @session, @string_buffer, chunk, @read_count   
        handle_data.call @string_buffer.read_array_of_char chunk        
        total += @read_count.read_uint32
      end 
    end
  
  end
	
end
