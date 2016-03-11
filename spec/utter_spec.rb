require "spec_helper"

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
      Given { instance.on(:event) }
      Then { "the utter method is mixed in" }
      And { expect { instance.test_utter }.to_not raise_error }
    end

    context "mixin with class" do
      class TestClass
        extend Utter
        def self.test_utter
          utter(:test)
        end
      end
      Given(:klass) { TestClass }
      Given { klass.on(:event) }
      Then { "the utter method is mixed in" }
      And { expect { klass.test_utter }.to_not raise_error }
    end

  end

  describe "mixed in with an instance" do
    Given(:instance) { Object.new.extend(Utter) }

    describe "#utter" do
      When { instance.on(:event) }
      Then { expect { instance.utter(:event) }.to_not raise_error }
      Then { expect { instance.utter(:event, payload: {}) }.to_not raise_error }
    end

    describe "#on" do
      Then { instance.respond_to?(:on) == true }

      context "event emitter DSL" do
        Then { expect {instance.on(:event) }.to_not raise_error }
      end

      Given(:payload) { {name: "parasquid", greeting: "hello"} }

      context "block runs when event is triggered" do
        Given(:verifier) { double("Verifier") }
        Given { expect(verifier).to receive(:call) }
        When { instance.on(:event) {|p| verifier.call(p)} }
        Then { expect {
            instance.utter(:event, payload: payload)
          }.to_not raise_error }
      end

      context "block does not run when the a different event is triggered" do
        Given(:wrong_verifier) { double("WrongVerifier") }
        Given { expect(wrong_verifier).not_to receive(:call) }
        When { instance.on(:wrong_event) {|p| wrong_verifier.call(p)} }
        Then { expect {
            instance.utter(:correct_event, payload: payload)
          }.to_not raise_error }
      end

      context "block is able to access the payload" do
        Given(:verifier) { double("Verifier") }
        Given { expect(verifier).to receive(:call).with(payload: payload) }
        When { instance.on(:event) {|p| verifier.call(p)} }
        Then { expect {
            instance.utter(:event, payload: payload)
          }.to_not raise_error }
      end

      context "two objects with the same event name are separately processed" do
        Given(:verifier) { double("Verifier") }
        Given { expect(verifier).to receive(:call).with(payload: payload) }
        Given(:instance2) { Object.new.extend(Utter) }
        Given(:payload2) { {name: "parasquid", greeting: "hi"} }
        Given(:verifier2) { double("Verifier2") }
        Given { expect(verifier2).to receive(:call).with(payload: payload2) }
        When { instance.on(:event) {|p| verifier.call(p)} }
        When { instance2.on(:event) {|p| verifier2.call(p)} }
        Then { expect {
            instance.utter(:event, payload: payload)
          }.to_not raise_error }
        And { expect {
            instance2.utter(:event, payload: payload2)
          }.to_not raise_error }
      end
    end
  end

  describe Utter::GLOBAL_EVENTS_TABLE do
    context "the global events table can be observed" do
      Given(:instance) { Object.new.extend(Utter) }
      Given(:watcher) { double("Watcher") }
      Given { expect(watcher).to receive(:update) }
      When { Utter::GLOBAL_EVENTS_TABLE.add_observer(watcher) }
      When { instance.on(:event) }
      Then { expect {
          instance.utter(:event)
        }.to_not raise_error }

    end
  end
end
