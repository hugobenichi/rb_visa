require 'rake/clean'

name = 'rb_visa'

task :test_local do                     # if run from gem root dir
  ruby "-I./lib test/test_rbvisa.rb"
end

task :test_global do                    # if run after gem installation
  ruby "test/test_rbvisa.rb"
end

task :gem_install => :gem_build do
  gemfile = Dir.new("./").entries.select{ |f|
    f =~ /rb_visa-[\d]+\.[\d]+\.[\d]+.gem/      # auto-get last version
  }.max
  sh "gem install %s" % gemfile
end

task :gem_build do
  sh "gem build %s.gemspec" % name
end
