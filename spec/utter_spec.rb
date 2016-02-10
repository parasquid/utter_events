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

  describe "#utter" do
    Given(:instance) { Object.new.extend(Utter) }
    Then { expect { instance.utter(:event, payload: {}) }.to_not raise_error }
  end
end
