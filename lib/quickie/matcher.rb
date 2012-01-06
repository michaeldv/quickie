# Copyright (c) 2011-12 Michael Dvorkin
#
# Quickie is freely distributable under the terms of MIT license.
# See LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
module Quickie
  class Hell < RuntimeError
    def oops
      "#{message.chomp} in #{backtrace[2].sub(':', ', line ').sub(':', ' ')}"
    end
  end

  class Matcher
    def initialize(object, verb)
      @object = object
      @should = (verb == :should)
    end

    private

    # Override an operator to be able to tell whether it succeeded or not.
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

    # Note that we always evaluate positive operators, and then flip the actual
    # result based on should/should_not request.
    #--------------------------------------------------------------------------
    def evaluate(operator, negative_operator, expected)
      actual = !!@object.__send__(operator, expected)
      actual ^= 1 if (!@should && !negative_operator) || (@should && negative_operator)

      if actual
        report :success
      else
        raise Hell, lyrics(negative_operator || operator, expected)
      end

    rescue Hell => e
      report :failure, e.oops
    end

    # Format actual vs. expected message.
    #--------------------------------------------------------------------------
    def lyrics(operator, expected)
      format = "expected: %s %s\n  actual: %s %s"
      format.sub!(":", " not:").sub!("\n", "\n    ") unless @should
      format % [ operator, expected.inspect, ' ' * operator.size, @object.inspect ]
    end

    # Report test success and/or failure. When running within IRB or Pry the
    # message gets displayed immediately, otherwise all the messages are shown
    # by the Runner in at_exit block.
    #--------------------------------------------------------------------------
    def report(status, message = nil)
      print(status == :success ? '.' : 'F')
      if !defined?(::IRB) && !defined?(::Pry)
        Runner.update(status, message)
      else
        puts "\n\n#{message}"
      end
    end

    # The matcher magic starts here ;-)
    #--------------------------------------------------------------------------
    %w[ == === =~ > >= < <= => ].each do |operator|
      override operator
    end
  end
end
