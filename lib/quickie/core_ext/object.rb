# Copyright (c) 2011-12 Michael Dvorkin
#
# Quickie is freely distributable under the terms of MIT license.
# See LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
class Object
  [ :should, :should_not ].each do |verb|
    define_method verb do
      Quickie::Matcher.new(self, verb)
    end
    alias_method :"#{verb}_be", verb
  end

  define_method :stub do |method, options = {}|
    Quickie::Stub.new(self, method, options)
  end
  alias_method :stub!, :stub
end
