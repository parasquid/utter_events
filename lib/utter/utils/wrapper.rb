module Utter
  module Utils
    class Wrapper
      def wrap(wrapped_class, before: nil, after: nil)
        wrapped_class.class_eval do
          self.define_singleton_method :utter_before_action do
            before || Proc.new {}
          end

          self.define_singleton_method :utter_after_action do
            after || Proc.new {}
          end

          def self.inherited(klass)
            def klass.method_added(name)
              # prevent a SystemStackError
              return if @_not_new
              @_not_new = true

              # preserve the original method call
              original = "original #{name}"
              alias_method original, name

              # wrap the method call
              define_method(name) do |*args, &block|
                self.class.superclass.utter_before_action.call(self)

                # call the original method
                result = send original, *args, &block

                self.class.superclass.utter_after_action.call(self)

                # return the original return value
                result
              end

              # reset the guard for the next method definition
              @_not_new = false
            end
          end
        end
      end
    end
  end
end