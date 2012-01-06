# Copyright (c) 2011-12 Michael Dvorkin
#
# Quickie is freely distributable under the terms of MIT license.
# See LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
require "stringio"
require File.expand_path(File.dirname(__FILE__) + "/../lib/quickie")

# Use Quickie to test itself. The methodology is as follows:
#
#   1. Write regular Quickie test.
#   2. Capture the output of the test.
#   3. Make sure captured output matches the expectation.
#
# In addition, we hack the Quickie trace/stats so that failed captured
# tests are not shown/counted in the actual results.
#--------------------------------------------------------------------------
def capture
  stats = Quickie::Runner.class_variable_get(:@@stats)
  trace = Quickie::Runner.class_variable_get(:@@trace)

  standard, $stdout = $stdout, StringIO.new
  yield
  $stdout.string
ensure
  if $stdout.string == '.'
    stats[:success] -= 1
  else
    stats[:failure] -= 1
    trace.pop
  end
  $stdout = standard
end

# Should - passing specs.
#--------------------------------------------------------------------------
capture { "abc".should == "abc" }.should == "."
capture { "abc".should != "xyz" }.should == "."
capture { "abc".should =~ /AB/i }.should == "."
capture { "abc".should !~ /XY/i }.should == "."
capture { 1234567.should_be > 0 }.should == "."

# Should Not - passing specs.
#--------------------------------------------------------------------------
capture { "abc".should_not != "abc" }.should == "."
capture { "abc".should_not == "xyz" }.should == "."
capture { "abc".should_not !~ /AB/i }.should == "."
capture { "abc".should_not =~ /XY/i }.should == "."
capture { 1234567.should_not_be < 0 }.should == "."

# Should - failing specs.
#--------------------------------------------------------------------------
capture { "abc".should != "abc" }.should == "F"
capture { "abc".should == "xyz" }.should == "F"
capture { "abc".should !~ /AB/i }.should == "F"
capture { "abc".should =~ /XY/i }.should == "F"
capture { 1234567.should_be < 0 }.should == "F"

# Should Not - failing specs.
#--------------------------------------------------------------------------
capture { "abc".should_not == "abc" }.should == "F"
capture { "abc".should_not != "xyz" }.should == "F"
capture { "abc".should_not =~ /AB/i }.should == "F"
capture { "abc".should_not !~ /XY/i }.should == "F"
capture { 1234567.should_not_be > 0 }.should == "F"
