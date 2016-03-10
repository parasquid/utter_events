require "spec_helper"
require "utter/utils/wrapper"

describe Utter::Utils::Wrapper do
  describe "wrapping a parent class" do
    context "executes the after action after a method is called" do
      Given(:klass) {
        class Klass
        end
        Klass
      }
      Given(:after_action) { double("after_action", call: nil) }
      Given { Utter::Utils::Wrapper.new.wrap(klass, after: after_action) }

      Given(:child_class) {
        class ChildKlass < Klass
          # we make a random method name so we can't know it in advance
          define_method "method_#{srand}" do; end;
        end
        ChildKlass
      }
      Given(:random_method) { (child_class.new.methods - Object.methods).first }

      When { child_class.new.send(random_method) }

      Then { expect(after_action).to have_received(:call) }
    end
  end
end
