
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
    @client.put_record(
      delivery_stream_name: "checkout",
      record: {
        data: payload.to_s
      }
    )
  end
end

class UtterDynamoLogger
  def initialize
    credentials = Aws::SharedCredentials.new(profile_name: "dynamodb")
    @client = Aws::DynamoDB::Client.new(
      credentials: credentials,
      region: "us-east-1"
    )
  end

  def update(object_id, event, payload)
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

ApplicationController.class_eval do
  def self.inherited(klass)
    def klass.method_added(name)
      # prevent a SystemStackError
      return if @_not_new
      @_not_new = true

      # preserve the original method call
      original = "original #{name}"
      alias_method original, name

      # wrap the method call
      define_method(name) do |*args, &block|
        # before action
        # puts "==> called #{name} with args: #{args.inspect}"

        # call the original method
        result = send original, *args, &block

        # after action
        # puts "<== result is #{result}"

        payload = {
          "object_instance" => self.to_s,
          "result" => result.inspect,
          "action_dispatch.request.path_parameters" => env["action_dispatch.request.path_parameters"]
        }
        utter("#{self.class.to_s}##{name}", payload) if self.respond_to?(:utter)

        # return the original return value
        result
      end

      # reset the guard for the next method definition
      @_not_new = false
    end
  end
end

console_watcher = UtterConsoleLogger.new
dynamo_watcher = UtterDynamoLogger.new
kinesis_watcher = UtterKinesisLogger.new
Utter::GLOBAL_EVENTS_TABLE.add_observer(console_watcher)
Utter::GLOBAL_EVENTS_TABLE.add_observer(dynamo_watcher)
Utter::GLOBAL_EVENTS_TABLE.add_observer(kinesis_watcher)
