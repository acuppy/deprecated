#
# Please see the COPYING file in the source distribution for copyright information.
# 

begin
    require 'rubygems'
    gem 'test-unit'
rescue LoadError
end

$:.unshift 'lib'
require 'rake/testtask'
require 'rake/packagetask'
require 'rake/gempackagetask'
require 'rake/rdoctask'
require 'deprecated'

task :default => [ :dist ]

#
# Tests
#

Rake::TestTask.new do |t|
    t.libs << 'lib'
    t.test_files = FileList['test/test*.rb']
    t.verbose = true 
end

#
# Distribution
#

task :dist      => [:test, :repackage, :gem, :rdoc]
task :distclean => [:clobber_package, :clobber_rdoc]
task :clean     => [:distclean]

#
# Documentation
#

Rake::RDocTask.new do |rd|
    rd.rdoc_dir = "rdoc"
    rd.main = "Deprecated"
    rd.rdoc_files.include("./lib/**/*.rb")
    rd.options = %w(-ap)
end

#
# Packaging
# 


spec = Gem::Specification.new do |s|
    s.name = "deprecated"
    s.version = Deprecated::VERSION
    s.author = "Erik Hollensbe"
    s.email = "erik@hollensbe.org"
    s.summary = "An easy way to handle deprecating and conditionally running deprecated code"
    s.has_rdoc = true
    s.files = Dir['Rakefile'] + Dir['lib/deprecated.rb'] + Dir['test/test_deprecated.rb']
    s.test_file = "test/test_deprecated.rb"
    s.rubyforge_project = 'deprecated'
end

Rake::GemPackageTask.new(spec) do |s|
end

Rake::PackageTask.new(spec.name, spec.version) do |p|
    p.need_tar_gz = true
    p.need_zip = true
    p.package_files.include("./setup.rb")
    p.package_files.include("./Rakefile")
    p.package_files.include("./lib/**/*.rb")
    p.package_files.include("./test/**/*")
end
