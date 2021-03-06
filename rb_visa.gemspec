Gem::Specification.new do |spec|

  spec.name        = 'rb_visa'
  spec.version     = '0.1.2'
  spec.date        = '2013-03-19'
  spec.summary     = "Ruby wrapper to NI-VISA API for measurement devices automation"
  spec.description = "A Ruby layer wrapping around the Ni-VISA calls. Based on the ffi gem"
  spec.authors     = ["Hugo Benichi"]
  spec.email       = 'hugo[dot]benichi[at]m4x[dot]org'
  spec.homepage    = "http://github.com/hugobenichi/rb_visa"

  spec.files       = Dir.glob( 'lib/**/*.{rb}')
  spec.files      += Dir.glob( 'ext/**/*.{c,h,def}')
  spec.files      += Dir.glob( 'test/**/*.{rb,bat}')
  spec.files      << 'rakefile.rb'
  spec.files      << 'README'

  spec.add_dependency 'ffi'

end
