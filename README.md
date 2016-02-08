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

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/parasquid/utter. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](https://github.com/parasquid/utter/blob/master/CODE_OF_CONDUCT.md) code of conduct.

