require "utter/version"
require "observer"

module Utter
  module Sinks
    GLOBAL_EVENTS_TABLE = Hash.new { |hash, key|
      hash[key] = Hash.new { |h, k|
        h[k] = []
      }
    }
  end

  def utter(event, payload=nil)
    events[self][event.to_sym].each do |block|
      block.call(payload)
    end
  end

  def on(event, &block)
    events[self][event.to_sym].push block
  end

  def events
    Sinks::GLOBAL_EVENTS_TABLE
  end
end
