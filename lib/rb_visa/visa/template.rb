module RbVisa

  module VISA
  
    Template = [   
        [ :viOpenDefaultRM,
          [ :pointer],        # :uint32* which stores the ressource manager handle
          :int32],
        
        [ :viOpen, 
          [ :uint32,          # ressource manager handle
            :pointer,         # device address
            :uint32,          # access mode
            :uint32,          # timeout
            :pointer],        # :uint32* which stores the session handle  
          :int32],     

        [ :viClose, 
          [:uint32]           # session/ressource manager handle
          :int32],    
        
        [ :viClear, 
          [:uint32]           # session/ressource manager handle
          :int32],  
          
        [ :viStatusDesc,
          [ :uint32,          # session handle
            :int32,           # status code
            :pointer],        # char* output description of the status code
          :int32],  
                            
        [ :viSetAttribute,
          [ :uint32,          # session handle
            :uint32,          # attribute name
            :uint32],         # attribute state (can be 64bits, need to check !)
          :int32], 

        [ :viGetAttribute,
          [ :uint32,          # session handle
            :uint32,          # attribute name
            :pointer],        # uint32* attribute state outpout (can be 64bits, need to check !)
          :int32], 
                    
        [ :viSetBuf,
          [ :uint32,          # session handle
            :uint16,          # mask
            :uint32],         # size
          :int32],
          
        [ :viWrite,
          [ :uint32,          # session handle
            :pointer,         # uint8*  buffer for input data
            :uint32,          # buffer size
            :pointer],        # uint32* which stores the number of bytes written to the device
          :int32],
       
        [ :viRead,
          [ :uint32,          # session handle
            :pointer,         # char* pointer to output buffer
            :uint32,          # number of bytes to read
            :pointer],        # uint32* which stores the number of bytes written to the buffer   
          :int32],         

        [ :viBufRead,
          [ :uint32,          # session handle
            :pointer,         # char* pointer to output buffer
            :uint32,          # number of bytes to read
            :pointer],        # uint32* which stores the number of bytes written to the buffer   
          :int32],   
                  
        [ :viFlush,
          [ :uint32,          # session handle
            :uint16],         # mask
          :int32],
      ]
    
  end
  
end
