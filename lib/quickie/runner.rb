# Copyright (c) 2011-12 Michael Dvorkin
#
# Quickie is freely distributable under the terms of MIT license.
# See LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
module Quickie
  class Runner
    @@trace = []
    @@stats = Hash.new(0)

    def self.update(status, message = nil)
      at_exit {
        puts
        puts "\n" << @@trace.join("\n\n") unless @@trace.empty?
        puts "\nPassed: #{@@stats[:success]}, not quite: #{@@stats[:failure]}, total tests: #{@@stats.values.inject(:+)}."
      } if @@stats.empty?

      @@stats[status] += 1
      @@trace << message if message
    end
  end
end
