# Copyright (c) 2011-12 Michael Dvorkin
#
# Quickie is freely distributable under the terms of MIT license.
# See LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
module Quickie
  class Stub
    #
    # To set up a stub with optional return value:
    #   obj.stub(:method, :return => something)
    #
    # To remove existing stub and restore original method:
    #   obj.stub(:method, :remove)
    #
    #--------------------------------------------------------------------------
    def initialize(object, method, options = {})
      options = { options => true } if options.is_a?(Symbol)
      @object, @options = object, options
      @@stash ||= []
      #
      # Create a new stub by intercepting the method or remove existing stub
      # by restoring the original method.
      #
      unless @options[:remove]
        intercept(method)
      else
        restore(method)
      end
    end

    private

    # Same as class << @object; self; end -- comes with Ruby 1.9.
    #--------------------------------------------------------------------------
    def metaclass
      @object.singleton_class
    end

    # Unique name the original method gets stashed under when creating a stub.
    #--------------------------------------------------------------------------
    def moniker(method)
      :"__#{method}__#{@object.__id__}"
    end

    # Return method's visibility, nil if public.
    #--------------------------------------------------------------------------
    def visibility(method)
      if metaclass.private_method_defined?(method)
        :private
      elsif metaclass.protected_method_defined?(method)
        :protected
      end
    end

    # Set up a stub by stashing the original method under different name and
    # then rediefining the method to return the requested value.
    #--------------------------------------------------------------------------
    def intercept(method)
      new_name = moniker(method)
      unless @object.respond_to? new_name
        stash(method, new_name)
        redefine(method)
      end
    end

    # Preserve original method by creating its alias with the unique name.
    #--------------------------------------------------------------------------
    def stash(method, new_name)
      metaclass.class_eval do
        if method_defined?(method) || private_method_defined?(method)
          alias_method new_name, method
        end
      end
      @@stash << new_name
    end

    # Create a stub that returns requested value.
    #--------------------------------------------------------------------------
    def redefine(method)
      return_value = @options[:return]
      metaclass.class_eval do
        define_method method do |*args, &block|
          return_value
        end
      end
      #
      # Set visibility attribute if the origial method is not public.
      #
      private_or_protected = visibility(method)
      metaclass.class_eval("#{private_or_protected} :#{method}") if private_or_protected
    end

    # Remove the stub and restore the original method.
    #--------------------------------------------------------------------------
    def restore(method)
      stashed_name = moniker(method)
      if @@stash.include? stashed_name          # Was it ever stubbed?
        metaclass.instance_eval do
          if method_defined?(stashed_name) || private_method_defined?(stashed_name)
            remove_method method                # Remove the stub.
            alias_method method, stashed_name   # Restore the original method from stash.
            remove_method stashed_name          # Remove stashed copy.
          end
        end
        @@stash.delete stashed_name
      end
    end
  end
end
