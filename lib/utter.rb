require "utter/version"
require "observer"

module Utter
  class EventsTable
    extend Forwardable
    def_delegators :@backing_hash, :[]

    include Observable

    def initialize
      @backing_hash = Hash.new { |hash, key|
        hash[key] = Hash.new { |h, k|
          h[k] = []
        }
      }
    end

    def process_event(object_id, event, payload)
      return unless @backing_hash.has_key? object_id
      return unless @backing_hash[object_id].has_key? event

      # call registered event handlers
      @backing_hash[object_id][event].compact!
      @backing_hash[object_id][event].each do |block|
        block.call(payload)
      end

      # notify watchers
      changed
      notify_observers(object_id, event, payload)
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
