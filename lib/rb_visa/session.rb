module RbVisa

    # main class that clients instantiate to create a connection to a device
    class Session

        attr_reader :session,   # C pointer to visa session handle
                      :rm,      # C pointer to visa ressource manager
                      :status,  # int code of most recent operation
                      :address  # string which id the device and tells interface

        # creates a Session instance which calls the necessary VISA functions
        # to start a connection to a device identified by the string address
        def initialize address, &block
            mem = FFI::MemoryPointer.new :uint32, 1
            check VISA::viOpenDefaultRM mem
            puts "ressource manager opened"
            @rm = mem.read_uint32
            @address = address
            check VISA::viOpen( @rm, @address, VISA::NULL, VISA::NULL, mem)
            puts "session opened"
            @session = mem.read_uint32

            @string_buffer_len = 65536
            @string_buffer = FFI::MemoryPointer.new :char, @string_buffer_len

            self.instance_eval &block if block
            self
        end

        # close the connection with the device
        def close
            check VISA::viClose @session
            check VISA::viClose @rm
            def close; end                # guards against double "free"
        end

        # finalizer for Session instances
        def self.release object
            object.close
        end

        # self-check which prints error msg if last operation was unsuccessful
        def check status
            puts self.status? if 0 > (@status = status)
            self
        end

        # queries error msg
        def status?
            puts "error code #{@status} for #{@session ||@rm}"
            @error_buffer ||= FFI::MemoryPointer.new :char, 256
            VISA::viStatusDesc @session||@rm, @status, @error_buffer
            @error_buffer.read_string
        end

        # resets connection state
        def clear
            check VISA::viClear @session
            self
        end

        # flushes the IO buffers
        def flush mask_val = VISA::VI_READ_BUF_DISCARD
            check VISA::viFlush @session, mask_val
            self
        end

        # sets buffers using a hash
        def buffer params = {}
            VISA::Buffer.each_pair.select{ |buf, mask|
                params[buf] && params[buf] > 0
            }.each{ |buf, mask|
                check VISA::viSetBuf( @session, mask, params[buf] )
            } if params.is_a? Hash
            self
        end

        # access VISA property
        # properties are accessed through their names (as symbol)
        # or through their their uint32 id value.
        # refer to your device manual or the VISA specifications to
        # obtain the name and id value of properties
        def [] name
            mem = FFI::MemoryPointer.new :uint32, 1
            name = VISA.const_get(name) if name.is_a? Symbol
            check VISA::viGetAttribute( @session, name, mem )
            return mem.read_uint32
        end

        # sets VISA property
        # properties  and properties values are accessed through their names
        # as symbols or through their their uint32 id value.
        # refer to your device manual or the VISA specifications to
        # obtain the name and id value of properties
        def []= name, value
            name  = VISA.const_get(name)  if name.is_a? Symbol
            value = VISA.const_get(value) if value.is_a? Symbol
            check VISA::viSetAttribute( @session, name, value )
        end

    end

end
