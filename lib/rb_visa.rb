# Ruby wrapper around National Instrument visa library.
# Allows easy scripting for control of your favorite oscilloscopes
#
# author      hugo benichi
# email       hugo [dot] benichi [at] m4x [dot] org
# copyright   2012 hugo benichi
# homepage    http://github.com/hugobenichi/rb_visa
#
# RbVisa is the main module and namespace of the gem
module RbVisa

    require "ffi"               # import ffi library for dll access
    require "rb_visa/visa"      # creates binding to visa32.dll
    require "rb_visa/session"   # create Ruby wrapper object to visa sessions
    require "rb_visa/io"        # IO methods for large blocks of data

end
