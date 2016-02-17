require "utter/version"
require "observer"

module Utter
  include Observable

  def utter(event, payload=nil)
    events = utter_events[event.to_sym]
    events.each do |block|
      block.call
    end
  end

  def on(event, &block)
    utter_events[event.to_sym].push block
  end

  private

  def utter_events
    @utter_events ||= events_table
  end

  def events_table
    Hash.new { |hash, key| hash[key] = [] }
  end
end
