require "spec_helper"
require "utter/utils/wrapper"

describe Utter::Utils::Wrapper do
  describe "wrapping a parent class" do
    Given(:klass) {
      class Klass
      end
      Klass
    }
    Given(:child_class) {
      class ChildKlass < Klass
        # we make a random method name so we can't know it in advance
        define_method "method_#{srand}" do; end;
      end
      ChildKlass
    }
    Given(:random_method) { (child_class.new.methods - Object.methods).first }

    context "executes the after action after a method is called" do
      Given(:after_action) { double("after_action", call: nil) }
      Given { Utter::Utils::Wrapper.new.wrap(klass, after: after_action) }

      When { child_class.new.send(random_method) }

      Then { expect(after_action).to have_received(:call) }
    end

    context "executes the before action after a method is called" do
      Given(:before_action) { double("before_action", call: nil) }
      Given { Utter::Utils::Wrapper.new.wrap(klass, before: before_action) }

      When { child_class.new.send(random_method) }

      Then { expect(before_action).to have_received(:call) }
    end

    context "makes the original calling context available" do
      Given(:before_action) { Proc.new { |context| expect(context.class).to eq(child_class) } }
      Given(:after_action) { Proc.new { |context| expect(context.class).to eq(child_class) } }
      Given { Utter::Utils::Wrapper.new.wrap(klass, before: before_action, after: after_action) }

      When { child_class.new.send(random_method) }

      Then { "context is the same as original calling object"; true }
    end
  end
end
