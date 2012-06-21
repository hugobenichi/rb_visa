module RbVisa

  module VISA
	  path='C:\Windows\System32\visa32.dll' # <TO_DO> read path from configuration file
	  extend FFI::Library
	  ffi_lib path
	
	  require 'rb_visa/visa/template'
	  Template.each{ |sig| attach_function *sig }
	 
	  VI_NULL   = 0
	  VI_FALSE  = 0
	  VI_TRUE   = 1
	 
	  # buffer settings
	  VI_READ_BUF             = 1
	  VI_WRITE_BUF            = 2
	  VI_READ_BUF_DISCARD     = 4
    VI_WRITE_BUF_DISCARD    = 8
	  VI_ASRL_IN_BUF 	        = 16    # VI_IO_IN_BUF
	  VI_ASRL_OUT_BUF         = 32    # VI_IO_out_BUF
    VI_ASRL_IN_BUF_DISCARD  = 64    # VI_IO_IN_BUF_DISCARD
	  VI_ASRL_OUT_BUF_DISCARD = 128   # VI_IO_OUT_BUF_DISCARD
	  	 
	  Buffer = {
	    read:     VI_READ_BUF,
	    write:    VI_WRITE_BUF,
	    asrl_in:  VI_ASRL_IN_BUF,
	    asrl_out: VI_ASRL_OUT_BUF,
	  }
    
    # other attributes
    VI_ATTR_TMO_VALUE       = "3fff001a".hex
    VI_TMO_INFINITE         = "FFFFFFFF".hex

	end
	
end
