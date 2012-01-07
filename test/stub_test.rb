# Copyright (c) 2011-12 Michael Dvorkin
#
# Quickie is freely distributable under the terms of MIT license.
# See LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
require File.expand_path(File.dirname(__FILE__) + "/../lib/quickie")

numbers = [ 1, 2, 3 ]
letters = %w(a b c)

numbers.stub! :join, :return => 42              # Stub numbers#join to return arbitrary value.
numbers.join.should == 42                       # Test numbers.join().
numbers.join(",").should == 42                  # Test numbers.join(arg).
letters.join.should == "abc"                    # letters array is unaffected by numbers#join.

letters.stub! :join, :return => "Hello, world!" # Now stub letters#join.
letters.join.should == "Hello, world!"          # Test letters.join().
letters.join(",").should == "Hello, world!"     # Test letters.join(arg).
numbers.join.should == 42                       # numbers#join stub is unaffected by letters#join stub.
numbers.join(",").should == 42                  # Ditto.

numbers.stub :join, :remove                     # Remove numbers#join stub.
numbers.join.should == "123"                    # numbers.join() should work as expected.
numbers.join(",").should == "1,2,3"             # numbers.join(arg) should work as expected.
letters.join.should == "Hello, world!"          # letters#join remains stubbed.

letters.stub :join, :remove                     # Now remove letters#join stub.
letters.join.should == "abc"                    # letters.join() should work as expected.
letters.join(",").should == "a,b,c"             # letters.join(arg) should work as expected.
