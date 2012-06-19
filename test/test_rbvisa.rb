require 'rb_visa'

tek = RbVisa::Session.new("TCPIP0::133.243.104.179::inst0::INSTR")

puts tek.id?
