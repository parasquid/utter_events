require "utter/version"
require "observer"

module Utter
  include Observable
  def utter(channel, payload=nil)
  end
end
