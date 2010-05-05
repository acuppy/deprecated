class DeprecatedError < StandardError; end

module Deprecated
    VERSION = "3.0.0"

    def __deprecated_run_action__(sym)
        if self.class.instance_eval { @__deprecated_run_action__ }
            self.class.instance_eval { @__deprecated_run_action__ }.call(self.class, sym) 
        else
            Deprecated.run_action(self.class, sym)
        end
    end

    def self.set_action(type=nil, &block)
        @action = if block
                      block
                  else
                      case type
                      when :warn
                          proc { |klass, sym| warn "#{klass}##{sym} is deprecated." }
                      when :die
                          proc { |klass, sym| fail "#{klass}##{sym} is deprecated." }
                      when :raise
                          proc { |klass, sym| raise DeprecatedError, "#{klass}##{sym} is deprecated." }
                      else
                          raise ArgumentError, "you must provide a symbol or a block to set_action()."
                      end
                  end
    end

    def self.run_action(klass, sym)
        raise "no hook" unless @action
        @action.call(klass, sym)
    end

    def self.action
        @action
    end
end

module Deprecated
    module Module
        def deprecated(sym, scope=nil)

            raise ArgumentError, "deprecated() requires symbols for its arguments" unless sym.kind_of?(Symbol)

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
                __deprecated_run_action__(sym)
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
