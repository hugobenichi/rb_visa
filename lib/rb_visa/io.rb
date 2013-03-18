module RbVisa

    class Session

        # grows client buffer size if necessary
        def buffer_grow size
            if size > @string_buffer_len
                @string_buffer = FFI::MemoryPointer.new :char, size
                @string_buffer_len = size
            end
        end

        # makes sure client memory is ready for operation
        def memory_prep size
            buffer_grow size
            @read_count ||= FFI::MemoryPointer.new :uint32, 1
        end

        # writes client command to visa buffer and then to device
        def write command
            memory_prep command.length
            @string_buffer.write_string command
            check VISA::viWrite @session,
                                @string_buffer,
                                command.length,
                                @read_count
#puts "write count %i" % @read_count.read_uint32
            self
        end

        # reads bytes number of bytes from the input buffer
        def read bytes = @string_buffer_len
            memory_prep bytes
            check VISA::viRead @session,
                               @string_buffer,
                               bytes,
                               @read_count
#puts "read count %i" % @read_count.read_uint32
            @string_buffer.read_string(@read_count.read_uint32).chomp
        end

        # alias for write
        def << command
            self.write command
        end

        # helper method for simple queries
        def query command
            self.write(command).read
        end

        # queries the device identification string
        def id?
            query "*idn?"
        end

        # parse a data block received from "CURVE" like commands
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

#puts "data_size_tag size: %i" % data_size_tag_size

            #read the header tag and parse into an int
            check VISA::viRead  @session,
                                @string_buffer,
                                data_size_tag_size,
                                @read_count

            size_string = @string_buffer.read_array_of_char(data_size_tag_size)
            size_string.map{ |c| c - offset }.join.to_i
        end

        # multiple reads into a client provided buffer
        def mread_into chunk, &next_buffer
            total = 0
            (self.parse / chunk).times do
                VISA::viRead @session, next_buffer.call, chunk, @read_count
#puts "mread read count %i" % @read_count.read_uint32
                total += @read_count.read_uint32
            end
            total
        end

        # multiplde reads with data handling by a client provided block
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
