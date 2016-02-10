require 'spec_helper'

describe Utter do
  Given(:version) { Utter::VERSION }
  Then { version != nil }

  describe "usage" do
    context "mixin with instance" do
      class TestClass
        include Utter
        def test_utter
          utter(:test)
        end
      end
      Given(:instance) { TestClass.new }
      Then { expect { instance.test_utter }.to_not raise_error }
    end

    context "mixin with class" do
      class TestClass
        extend Utter
        def self.test_utter
          utter(:test)
        end
      end
      Given(:klass) { TestClass }
      Then { expect { klass.test_utter }.to_not raise_error }
    end
  end

  describe "mixed in with an instance" do
    Given(:instance) { Object.new.extend(Utter) }

    describe "#utter" do
      Then { expect { instance.utter(:event) }.to_not raise_error }
      Then { expect { instance.utter(:event, payload: {}) }.to_not raise_error }
    end

    describe "including utter makes the object an observable" do
      Then { instance.respond_to?(:notify_observers) == true }
    end

    describe "#on" do
      Then { instance.respond_to?(:on) == true }

      context "event emitter DSL" do
        Then { expect {instance.on(:event) }.to_not raise_error }
      end

      context "block runs when event is triggered" do
        Given(:payload) { {name: "parasquid", greeting: "hello"} }
        Given(:verifier) { double("Verifier") }
        Given { expect(verifier).to receive(:call) }
        Then { expect { instance.on(:event) {|p| verifier.call(p)} }.to_not raise_error }
      end
    end

  end
end
