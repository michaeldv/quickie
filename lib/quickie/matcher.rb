# Copyright (c) 2011-12 Michael Dvorkin
#
# Quickie is freely distributable under the terms of MIT license.
# See LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
module Quickie
  class Hell < RuntimeError
    def oops
      puts "\n#{message.chomp} in #{backtrace[2].sub(':', ', line ').sub(':', ' ')}"
    end
  end

  class Matcher
    def initialize(object, verb)
      @object = object
      @should = (verb == :should)
      %w[ == === =~ > >= < <= => ].each do |operator|
        self.class.override operator
      end
    end

    private

    #--------------------------------------------------------------------------
    def self.override(operator)
      define_method(operator) do |expected|
        evaluate(operator, nil, expected)
      end

      negative_operator = case operator[0]
      when '<' then operator.sub('<',  '>')
      when '>' then operator.sub('>',  '<')
      else          operator.sub(/^=/, '!')
      end

      return unless @object.respond_to?(negative_operator)

      define_method(negative_operator) do |expected|
        evaluate(operator, negative_operator, expected)
      end
    end

    #--------------------------------------------------------------------------
    def evaluate(operator, negative_operator, expected)
      actual = !!@object.__send__(operator, expected)
      actual ^= 1 if (!@should && !negative_operator) || (@should && negative_operator)

      if actual
        report :success
      else
        report :failure
        raise Hell, lyrics(negative_operator || operator, expected)
      end

    rescue Hell => e
      e.oops
    end

    #--------------------------------------------------------------------------
    def lyrics(operator, expected)
      format = "expected: %s %s\n  actual: %s %s"
      format.sub!(":", " not:").sub!("\n", "\n    ") unless @should
      format % [ operator, expected.inspect, ' ' * operator.size, @object.inspect ]
    end

    #--------------------------------------------------------------------------
    def report(status)
      print '.' if status == :success
      Runner.update(status)
    end
  end
end
