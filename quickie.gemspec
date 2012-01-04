# Copyright (c) 2011-12 Michael Dvorkin
#
# Quickie is freely distributable under the terms of MIT license.
# See LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
require "rake"
require File.dirname(__FILE__) + "/lib/quickie/version"

task :default => :test

task :test do
  exec "ruby test/quickie_test.rb"
end

Gem::Specification.new do |s|
  s.name        = "quickie"
  s.version     = Quickie.version
# s.platform    = Gem::Platform::RUBY
  s.authors     = "Michael Dvorkin"
  s.date        = Time.now.strftime("%Y-%m-%d")
  s.email       = "mike@dvorkin.net"
  s.homepage    = "http://github.com/michaeldv/quickie"
  s.summary     = "Micro framework for in-place testing of Ruby code"
  s.description = "Quickie adds Object#should and Object#should_not methods for quick testing of your Ruby code"

  s.rubyforge_project = "quickie"
  s.required_ruby_version = ">= 1.9.2"

  s.files         = Rake::FileList["[A-Z]*", "lib/**/*.rb", "test/*", ".gitignore"]
  s.test_files    = Rake::FileList["spec/*"]
  s.executables   = []
  s.require_paths = ["lib"]
end
