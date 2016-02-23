require "utter/version"
require "observer"

module Utter
  class EventsTable
    extend Forwardable
    def_delegators :@backing_hash,
      :push,
      :each,
      :[]

    def initialize
      @backing_hash = Hash.new { |hash, key|
        hash[key] = Hash.new { |h, k|
          h[k] = []
        }
      }
    end
  end
  private_constant :EventsTable

  GLOBAL_EVENTS_TABLE = EventsTable.new

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
    GLOBAL_EVENTS_TABLE
  end


end
