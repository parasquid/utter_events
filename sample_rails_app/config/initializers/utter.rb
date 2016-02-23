class UtterConsoleLogger
  def update(object_id, event, payload)
    puts "object_id: #{object_id}\nevent: #{event}\npayload: #{payload}"
  end
end

watcher = UtterConsoleLogger.new
Utter::GLOBAL_EVENTS_TABLE.add_observer(watcher)