# Ruby with Type.

```rb

require 'haskell'

# Ruby 2.1.0+
class MyClass
    type Numeric >= Numeric >= Numeric, def sum(x, y)
    x + y
  end

  type Numeric >= Numeric >= Numeric, def wrong_sum(x, y)
  'string'
  end
end

MyClass.new.sum(1, 2)
#=> 3

MyClass.new.sum(1, 'string')
#=> ArgumentError: Wrong type of argument, type of "str" should be Numeric

MyClass.new.wrong_sum(1, 2)
#=> TypeError: Expected wrong_sum to return Numeric but got "str" instead

# Ruby 1.8.0+
class MyClass
  def sum(x, y)
    x + y
  end
  type Numeric >= Numeric >= Numeric, :sum
end
```

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'haskell'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install haskell

## More example
```ruby
class People
  type People >= Any, def marry(people)
    # Your Ruby code as usual
  end
end

People.new.marry(People.new)
#=> no error

People.new.marry('non people')
#=> ArgumentError: Wrong type of argument, type of "non people" should be People

```

## Contributing

1. Fork it ( https://github.com/[my-github-username]/haskell/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request


## Credits
[@chancancode](https://github.com/chancancode) first brought this to my attention.
