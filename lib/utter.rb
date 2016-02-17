require "utter/version"
require "observer"

module Utter
  include Observable

  def utter(event, payload=nil)
    events[event.to_sym].each do |block|
      block.call
    end
  end

  def on(event, &block)
    events[event.to_sym].push block
  end

  def events
    @events ||= events_table
  end

  private

  def events_table
    Hash.new { |hash, key| hash[key] = [] }
  end
end
