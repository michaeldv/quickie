# Copyright (c) 2011-12 Michael Dvorkin
#
# Quickie is freely distributable under the terms of MIT license.
# See LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
require "stringio"
require File.expand_path(File.dirname(__FILE__) + "/../lib/quickie")

$stderr.reopen("/dev/null", "w") # Disable debug noise.

arr = [ 1, 2, 3 ]
arr.stub! :join, :return => "Hello, world"

arr.join.should == "Hello, world"
arr.join(",").should == "Hello, world"

arr.stub :join, :remove
arr.join.should == "123"
arr.join(",").should == "1,2,3"
