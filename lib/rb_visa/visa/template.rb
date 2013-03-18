module RbVisa

    module VISA

        # table of symbols which tells how to bind functions from visa32.dll
        Template = [

            [ # creates a visa resource manager
              :viOpenDefaultRM,
              [ :pointer],        # :uint32*, stores ressource manager handle
              :int32
            ],

            [ # creates a new connection to a visa device
              :viOpen,
              [ :uint32,          # ressource manager handle
                :pointer,         # device address
                :uint32,          # access mode
                :uint32,          # timeout
                :pointer],        # :uint32* which stores the session handle
              :int32
            ],

            [ # closes a connection to a visa device
              :viClose,
              [:uint32],          # session/ressource manager handle
              :int32
            ],

            [ # resets internal state of visa device connection (buffers, ...)
              :viClear,
              [:uint32],          # session/ressource manager handle
              :int32
            ],

            [ # gets human readable error message
              :viStatusDesc,
              [ :uint32,          # session handle
                :int32,           # status code
                :pointer],        # char* output description of status code
              :int32
            ],

            [ # sets connection attribute
              :viSetAttribute,
              [ :uint32,          # session handle
                :uint32,          # attribute name
                :uint32],         # attribute state
              :int32
            ],

            [ # gets connection atribute value
              :viGetAttribute,
              [ :uint32,          # session handle
                :uint32,          # attribute name
                :pointer],        # uint32* attribute state outpout
              :int32
            ],

            [ # sets connection buffer size
              :viSetBuf,
              [ :uint32,          # session handle
                :uint16,          # mask
                :uint32],         # size
              :int32
            ],

            [ # sends message to device
              :viWrite,
              [ :uint32,          # session handle
                :pointer,         # uint8*  buffer for input data
                :uint32,          # buffer size
                :pointer],        # uint32*, stores bytes num written to device
              :int32
            ],

            [ # reads message sent by device
              :viRead,
              [ :uint32,          # session handle
                :pointer,         # char* pointer to output buffer
                :uint32,          # number of bytes to read
                :pointer],        # uint32*, stores bytes num written to buffer
              :int32
            ],

            [ # reads message sent by device from (visa provided) buffer
              :viBufRead,
              [ :uint32,          # session handle
                :pointer,         # char* pointer to output buffer
                :uint32,          # number of bytes to read
                :pointer],        # uint32*, stores bytes num written to buffer
              :int32
            ],

            [ # flushes buffer content to/from device
              :viFlush,
              [ :uint32,          # session handle
                :uint16],         # mask
              :int32
            ]

        ]

    end

end
