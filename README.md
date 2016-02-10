# Utter

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'utter'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install utter

## Usage

### Sending Events

```ruby
require "utter"

# mixin instance methods
class UserRegistration
  include Utter
  def register_user(user)
    # code goes here
    # ...

    utter(:user_registered, payload: {
      username: user.name,
      registration_date: user.created_at
    })
  end
end

# mixin class methods
class Configuration
  extend Utter

  def self.user_account_endpoint(subdomain)
    # code goes here
    #...

    utter(:user_account_endpoint_called, payload: {
      subdomain: subdomain
    })
  end
end
```

If you'd like to have access to both instance methods and class methods, you can both `include` and `extend` `Utter` like this:

```ruby
class IncludeAndExtend
  include Utter
  extend Utter

  # now you can use `#utter` in both instance methods and class methods
end
```

Take note however that doing both an `include` and an `extend` may be a sign that your class is doing too much, and may benefit from a refactoring and separation of concerns.

### Consuming Events

`Utter` has a default FIFO queue where it stores events emitted by the calling objects. This FIFO queue also mixes in the `Observable` module from the Ruby Standard Library so you can do something like:

```ruby
FIFO_QUEUE = Utter::Sinks::FifoQueue.new # create a custom fifo queue object
Utter.configuration.sinks = [FIFO_QUEUE] # use this custom object instead of the default one

class Watcher
  def update(event, payload)
    # the FIFO queue will call `#update` whenever there's an event that is emitted
    # ...
  end
end

FIFO_QUEUE.add_observer(Watcher.new)
```

If you don't want to observe the FIFO queue, there's also an experimental syntax that's inspired by https://github.com/shokai/event_emitter and NodeJS. You don't need to further configure `Utter` to include the FIFO queue because it already implements it by default.

```ruby
user_registration = UserRegistration.new # see above for the class definition

# ... call the method that emits an event
user_registration.register_user(user)

# ... somewhere else
user.on :user_registered do |payload|
  puts "#{data[:username]} was registered on #{data[:registration_date]}"
end
```

Note that this doesn't work on events that are called from class methods; you will need to configure and observe your own custom FIFO queue object in those cases.

### Configuration

Utter can also use different sinks other than the default FIFO queue:

```ruby
# in an initializer

require "utter"
require "utter-sinks-kinesis"

FIFO_QUEUE = Utter::Sinks::FifoQueue.new
KINESIS = Utter::Sinks::Kinesis.new

Utter.configure do |c|
  c.sinks = [FIFO_QUEUE, KINESIS]
end

# or

Utter.configuration.sinks = [FIFO_QUEUE, KINESIS]
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/parasquid/utter. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](https://github.com/parasquid/utter/blob/master/CODE_OF_CONDUCT.md) code of conduct.

