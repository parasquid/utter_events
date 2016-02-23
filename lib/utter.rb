require "utter/version"
require "observer"

module Utter
  class EventsTable
    extend Forwardable
    def_delegators :@backing_hash, :[], :fetch

    include Observable

    def initialize
      @backing_hash = Hash.new { |hash, key|
        hash[key] = Hash.new { |h, k|
          h[k] = []
        }
      }
    end

    def process_event(object_id, event, payload)
      @backing_hash.fetch(object_id)[event].each do |block|
        block.call(payload) if block
      end
    end
  end
  private_constant :EventsTable

  GLOBAL_EVENTS_TABLE = EventsTable.new

  def utter(event, payload=nil)
    events.process_event(self.object_id, event.to_sym, payload)
  end

  def on(event, &block)
    events[self.object_id][event.to_sym].push block
  end

  private

  def events
    GLOBAL_EVENTS_TABLE
  end


end
