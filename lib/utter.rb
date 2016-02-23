require "utter/version"
require "observer"

module Utter
  module Sinks
    EVENTS_TABLE = Hash.new { |hash, key| hash[key] = [] }
  end

  def utter(event, payload=nil)
    events[event.to_sym].each do |block|
      block.call(payload)
    end
  end

  def on(event, &block)
    events[event.to_sym].push block
  end

  def events
    @events ||= local_events_table
  end

  private

  def local_events_table
    Hash.new { |hash, key| hash[key] = [] }
  end
end
