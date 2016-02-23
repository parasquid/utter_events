require "utter/version"
require "observer"

class EventsTable
  extend Forwardable

  def initialize
    @backing_hash = Hash.new { |hash, key|
      hash[key] = Hash.new { |h, k|
        h[k] = []
      }
    }
  end

  def push(*args)
    @backing_hash.push(args)
  end

  def each(&block)
    @backing_hash.each.call(block)
  end

  def [](*args)
    @backing_hash[args]
  end
end

module Utter
  module Sinks
    GLOBAL_EVENTS_TABLE = EventsTable.new
  end

  def utter(event, payload=nil)
    events[self][event.to_sym].each do |block|
      block.call(payload)
    end
  end

  def on(event, &block)
    events[self][event.to_sym].push block
  end

  private

  def events
    Sinks::GLOBAL_EVENTS_TABLE
  end
end
