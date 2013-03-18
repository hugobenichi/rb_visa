module RbVisa

    # module which binds visa dll functions to Ruby
    # and provides a entry point from Ruby
    module VISA

       # loads visa dll
        extend FFI::Library
        ffi_lib 'C:\Windows\System32\visa32.dll' # TODO: set path from conf file

        # imports template file with binding information and binds dll functions
        require 'rb_visa/visa/template'
        Template.each{ |sig| attach_function *sig }

        # defines VISA constants
        VI_NULL   = 0
        VI_FALSE  = 0
        VI_TRUE   = 1
        NULL   = 0

        # VISA constants for buffer settings
        VI_READ_BUF             = 1
        VI_WRITE_BUF            = 2
        VI_READ_BUF_DISCARD     = 4
        VI_WRITE_BUF_DISCARD    = 8
        VI_ASRL_IN_BUF          = 16    # VI_IO_IN_BUF
        VI_ASRL_OUT_BUF         = 32    # VI_IO_out_BUF
        VI_ASRL_IN_BUF_DISCARD  = 64    # VI_IO_IN_BUF_DISCARD
        VI_ASRL_OUT_BUF_DISCARD = 128   # VI_IO_OUT_BUF_DISCARD

        # human readable names
        Buffer = {
            read:     VI_READ_BUF,
            write:    VI_WRITE_BUF,
            asrl_in:  VI_ASRL_IN_BUF,
            asrl_out: VI_ASRL_OUT_BUF,
        }

        # other VISA attributes
        VI_ATTR_TMO_VALUE       = 0x3fff001a
        VI_TMO_INFINITE         = 0xFFFFFFFF

    end

end
