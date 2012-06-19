require 'rake/clean'

name = 'rb_visa'

task :test_local do
  ruby "-I./lib test/test_rbvisa.rb"
end

task :test_global do
  ruby "test/test_rbvisa.rb"
end

task :gem_install => [:gem_build, :rdoc] do
  gemfile = Dir.new("./").entries.select{ |f| f =~ /rb_visa-[\d]+\.[\d]+\.[\d]+.gem/ }[0]
  sh "sudo gem install %s" % gemfile
end

task :gem_build => :compile do
  sh "gem build %s.gemspec" % name
end
  
task :rdoc do  
  sh 'rdoc lib' 
end
