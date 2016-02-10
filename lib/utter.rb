require "utter/version"
require "observer"

module Utter
  include Observable

  def utter(channel, payload=nil)

  end

  def on(event)
    yield if block_given?
  end
end
