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

`Utter` has a default Global Events Table where it stores events emitted by the calling objects. This events table also mixes in the `Observable` module from the Ruby Standard Library so you can do something like:

```ruby
class Watcher
  def update(object_id, event, payload)
    # the events table will call `#update` whenever there's an event that is emitted
    # ...
    send_to_amazon_kinesis(event, payload.merge(meta: {object_id: object_id, sent_at: Time.now}))
  end
end

Utter::GLOBAL_EVENTS_TABLE.add_observer(watcher)
```

If you don't want to observe the events table, there's also an experimental syntax that's inspired by https://github.com/shokai/event_emitter and NodeJS.

```ruby
user_registration = UserRegistration.new # see above for the class definition

# ... call the method that emits an event
user_registration.register_user(user)

# ... somewhere else
user.on :user_registered do |payload|
  puts "#{data[:username]} was registered on #{data[:registration_date]}"
end
```

Note that this doesn't work on events that are called from class methods; you will need to observe the Global Events Table object in those cases.

## Examples

There is an example [Rails App](https://github.com/parasquid/utter/tree/master/sample_rails_app) that uses `Utter`

    $ # after checking out this repository
    $ cd sample_rails_app
    $ bundle install
    $ rails s

Then go to localhost:3000/articles and take a look at the console. You should see something like this:

```ruby
object_id: 70100155242700
event: index_viewed
payload: {:params=>{"controller"=>"articles", "action"=>"index"}}
```
You will need to [setup your AWS credentials](https://blogs.aws.amazon.com/security/post/Tx3D6U6WSFGOK2H/A-New-and-Standardized-Way-to-Manage-Credentials-in-the-AWS-SDKs) if you wish to be able to use the AWS related examples.

The `UtterDynamoLogger` watcher utilizes [Celluloid](https://github.com/celluloid/celluloid/wiki/Basic-usage) in order to not block the original method call.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/parasquid/utter. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](https://github.com/parasquid/utter/blob/master/CODE_OF_CONDUCT.md) code of conduct.

