class DeprecatedError < StandardError; end

module Deprecated
    VERSION = "3.0.0"

    def __deprecated_run_action__(sym, replacement)
        if self.class.instance_eval { @__deprecated_run_action__ }
            self.class.instance_eval { @__deprecated_run_action__ }.call(self.class, sym, replacement) 
        else
            Deprecated.run_action(self.class, sym, replacement)
        end
    end

    def self.build_message(klass, sym, replacement)
        message = "#{klass}##{sym} is deprecated."

        if replacement
            message += " Please use #{replacement}."
        end

        return message
    end

    def self.set_action(type=nil, &block)
        @action = if block
                      block
                  else
                      case type
                      when :warn
                          proc { |*args| warn build_message(*args) }
                      when :fail
                          proc { |*args| fail build_message(*args) }
                      when :raise
                          proc { |*args| raise DeprecatedError, build_message(*args) }
                      else
                          raise ArgumentError, "you must provide a symbol or a block to set_action()."
                      end
                  end
    end

    def self.run_action(klass, sym, replacement)
        raise "run_action has no associated hook" unless @action
        @action.call(klass, sym, replacement)
    end

    def self.action
        @action
    end
end

module Deprecated
    module Module
        def deprecated(sym, replacement=nil, scope=nil)
            unless sym.kind_of?(Symbol)
                raise ArgumentError, "deprecated() requires symbols for its first argument." 
            end

            meth = instance_method(sym)
            unless scope
                pub = public_instance_methods
                pro = protected_instance_methods
                pri = private_instance_methods
                if pub.include?(sym) or pub.include?(sym.to_s)
                    scope = :public
                elsif pro.include?(sym) or pro.include?(sym.to_s)
                    scope = :protected
                elsif pri.include?(sym) or pri.include?(sym.to_s)
                    scope = :private
                end
            end

            define_method(sym) do |*args|
                dep_meth = method(sym).unbind
                __deprecated_run_action__(sym, replacement)
                retval = meth.bind(self).call(*args) 
                dep_meth.bind(self)
                return retval
            end

            method(scope).call(sym) if scope
            return scope
        end

        def deprecated_set_action(&block)
            raise "You must provide a block" unless block
            @__deprecated_run_action__ = block
        end
    end
    
    def self.included(base)
        base.extend(Module)
    end
end

Deprecated.set_action(:warn)
