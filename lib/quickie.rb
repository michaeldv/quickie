# Copyright (c) 2011-12 Michael Dvorkin
#
# Quickie is freely distributable under the terms of MIT license.
# See LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
#
# Check Ruby version in case someone is playng with cloned source repo. Note
# that quickie.gemspec explicitly sets required_ruby_version to ">= 1.9.2".
#
abort "Quickie requires Ruby 1.9.2 or later" if RUBY_VERSION < "1.9.2"

require File.dirname(__FILE__) + "/quickie/runner"
require File.dirname(__FILE__) + "/quickie/matcher"
require File.dirname(__FILE__) + "/quickie/stub"
require File.dirname(__FILE__) + "/quickie/version"
require File.dirname(__FILE__) + "/quickie/core_ext/object"
