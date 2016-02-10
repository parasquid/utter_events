require "utter/version"
require "observer"

module Utter
  include Observable

  def utter(event, payload=nil)
    utter_events.push(event)
  end

  def on(event)
    events = utter_events.select { |e| e == event }
    events.each do |e|
      if block_given?
        yield
      end
    end
  end

  private

  def utter_events
    @utter_events ||= []
  end
end
