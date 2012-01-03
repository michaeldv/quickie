# Copyright (c) 2011-12 Michael Dvorkin
#
# Tiny Spec is freely distributable under the terms of MIT license.
# See LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
module Quickie
  class Runner
    @@stats = Hash.new(0)

    def self.update(status)
      at_exit {
        puts "\n\nPassed: #{@@stats[:success]}, not quite: #{@@stats[:failure]}, total tests: #{@@stats.values.inject(:+)}."
      } if @@stats.empty?

      @@stats[status] += 1
    end
  end
end
