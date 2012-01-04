# Copyright (c) 2011 Michael Dvorkin
#
# Quickie is freely distributable under the terms of MIT license.
# See LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
module Quickie
  class Stub
    def initialize(object, method, options = {})
      # Turn obj.stub(:method, :remove) into obj.stub(:method, :remove => true)
      options = { options => true } if options.is_a?(Symbol)
      @@stash ||= []
      @object, @return = object, options[:return]

      # To set up a stub with optional return value:
      #   obj.stub(:method, :return => something)
      #
      # To remove existing stub and restore original method:
      #   obj.stub(:method, :remove)
      #
      options[:remove] ? restore(method) : intercept(method)
        
      # $stderr.reopen("/dev/null", "w") to disable debug noise.
      $stderr.puts "obj: #{@object}, msg: #{@method}, opt: #{options.inspect}"
    end

    private

    #--------------------------------------------------------------------------
    def metaclass
      class << @object; self; end
    end

    #--------------------------------------------------------------------------
    def moniker(method)
      :"__original__#{method}"
    end

    #--------------------------------------------------------------------------
    def visibility(method)
      if metaclass.private_method_defined?(method)
        'private'
      elsif metaclass.protected_method_defined?(method)
        'protected'
      else
        'public'
      end
    end

    #--------------------------------------------------------------------------
    def intercept(method)
      new_name = moniker(method)
      unless @object.respond_to? new_name
        stash(method, new_name)
        redefine(method)
      end
    end

    #--------------------------------------------------------------------------
    def stash(method, new_name)
      metaclass.class_eval do
        if method_defined?(method) || private_method_defined?(method)
          $stderr.puts "aliasing #{new_name} as #{method}"
          alias_method new_name, method
        end
      end
      @@stash << new_name
    end

    #--------------------------------------------------------------------------
    def redefine(method)
      $stderr.puts "redefine: #{method}, return #{@return}"
      return_value = @return
      metaclass.class_eval do
        define_method method do |*args, &block|
          return_value
        end
      end

      visibility_attribute = visibility(method)
      metaclass.class_eval(<<-EOF, __FILE__, __LINE__)
        #{visibility_attribute} :#{method}
      EOF
    end

    #--------------------------------------------------------------------------
    def restore(method)
      $stderr.puts "restoring: #{method}"
      stashed_name = moniker(method)
      if @@stash.include? stashed_name
        metaclass.instance_eval do
          if method_defined?(stashed_name) || private_method_defined?(stashed_name)
            $stderr.puts "removing #{method}"
            remove_method method
            $stderr.puts "aliasing #{method} as #{stashed_name}"
            alias_method method, stashed_name
            $stderr.puts "removing stashed #{stashed_name}"
            remove_method stashed_name
          end
        end
      end
      @@stash.delete stashed_name
    end
  end
end
