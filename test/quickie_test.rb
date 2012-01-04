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
# In addition, we hack the Quickie stats so that captured tests are not
# counted in the actual results.
#--------------------------------------------------------------------------
def capture
  stats = Quickie::Runner.class_variable_get('@@stats')
  captured = StringIO.new
  standard, $stdout = $stdout, captured
  yield
  captured.string
ensure
  $stdout = standard
  if captured.string == '.'
    stats[:success] -= 1
  else
    stats[:failure] -= 1
  end
  Quickie::Runner.class_variable_set('@@stats', stats)
end

#--------------------------------------------------------------------------
class String
  def fix(line)
    self.sub!(/^/, "\n")            # Insert newline.
    self.sub!("?", line.to_s)       # Insert actual line number.
    self.sub!(/\n+Passed.+$/, "")   # Ignore the stats.
    self
  end
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
capture { "abc".should != "abc" }.should == <<-EOS.fix(__LINE__)
expected: != "abc"
  actual:    "abc" in test/quickie_test.rb, line ? in `block in <main>'
EOS

capture { "abc".should == "xyz" }.should == <<-EOS.fix(__LINE__)
expected: == "xyz"
  actual:    "abc" in test/quickie_test.rb, line ? in `block in <main>'
EOS

capture { "abc".should !~ /AB/i }.should == <<-EOS.fix(__LINE__)
expected: !~ /AB/i
  actual:    "abc" in test/quickie_test.rb, line ? in `block in <main>'
EOS

capture { "abc".should =~ /XY/i }.should == <<-EOS.fix(__LINE__)
expected: =~ /XY/i
  actual:    "abc" in test/quickie_test.rb, line ? in `block in <main>'
EOS

capture { 1234567.should_be < 0 }.should == <<-EOS.fix(__LINE__)
expected: < 0
  actual:   1234567 in test/quickie_test.rb, line ? in `block in <main>'
EOS

# Should Not - failing specs.
#--------------------------------------------------------------------------
capture { "abc".should_not == "abc" }.should == <<-EOS.fix(__LINE__)
expected not: == "abc"
      actual:    "abc" in test/quickie_test.rb, line ? in `block in <main>'
EOS

capture { "abc".should_not != "xyz" }.should == <<-EOS.fix(__LINE__)
expected not: != "xyz"
      actual:    "abc" in test/quickie_test.rb, line ? in `block in <main>'
EOS

capture { "abc".should_not =~ /AB/i }.should == <<-EOS.fix(__LINE__)
expected not: =~ /AB/i
      actual:    "abc" in test/quickie_test.rb, line ? in `block in <main>'
EOS

capture { "abc".should_not !~ /XY/i }.should == <<-EOS.fix(__LINE__)
expected not: !~ /XY/i
      actual:    "abc" in test/quickie_test.rb, line ? in `block in <main>'
EOS

capture { 1234567.should_not_be > 0 }.should == <<-EOS.fix(__LINE__)
expected not: > 0
      actual:   1234567 in test/quickie_test.rb, line ? in `block in <main>'
EOS
