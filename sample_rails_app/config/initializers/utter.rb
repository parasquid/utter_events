
require "pp"

class UtterConsoleLogger
  def update(object_id, event, payload)
    puts "object_id: #{object_id}\nevent: #{event}\npayload: #{payload}"
  end
end

class UtterKinesisLogger
  def initialize
    credentials = Aws::SharedCredentials.new(profile_name: "kinesis")
    @client = Aws::Firehose::Client.new(credentials: credentials, region: "us-east-1")
  end

  def update(object_id, event, payload)
    self.async._update(object_id, event, payload)
  end

  def _update(object_id, event, payload)
    @client.put_record(
      delivery_stream_name: "checkout",
      record: {
        data: payload.to_s
      }
    )
  end
end

class UtterDynamoLogger
  include Celluloid

  def initialize
    credentials = Aws::SharedCredentials.new(profile_name: "dynamodb")
    @client = Aws::DynamoDB::Client.new(
      credentials: credentials,
      region: "us-east-1"
    )
  end

  def update(object_id, event, payload)
    self.async._update(object_id, event, payload)
  end

  def _update(object_id, event, payload)
    @client.put_item({
      table_name: "mv_utter_events",
      item: {
        event_id: SecureRandom.uuid,
        object_id: object_id,
        event: event,
        payload: payload
      }
    })
  end
end

require "utter/utils/wrapper"

[ApplicationController].each do |klass|
  after_action = Proc.new do |context, args, name|
    payload = {
      "object_instance" => context.to_s,
      "action_dispatch.request.path_parameters" => context.env["action_dispatch.request.path_parameters"]
    }
    context.utter("#{context.class.to_s}##{name}", payload) if context.respond_to?(:utter)
  end
  Utter::Utils::Wrapper.new.wrap(klass, after: after_action )
end




console_watcher = UtterConsoleLogger.new
dynamo_watcher = UtterDynamoLogger.new
# kinesis_watcher = UtterKinesisLogger.new
Utter::GLOBAL_EVENTS_TABLE.add_observer(console_watcher)
Utter::GLOBAL_EVENTS_TABLE.add_observer(dynamo_watcher)
# Utter::GLOBAL_EVENTS_TABLE.add_observer(kinesis_watcher)
