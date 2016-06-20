# Ruby + Type = Rubype

[![Gem Version](https://badge.fury.io/rb/rubype.svg)](http://badge.fury.io/rb/rubype) [![Build Status](https://travis-ci.org/gogotanaka/Rubype.svg?branch=develop)](https://travis-ci.org/gogotanaka/Rubype) [![Dependency Status](https://gemnasium.com/gogotanaka/Rubype.svg)](https://gemnasium.com/gogotanaka/Rubype) [![Code Climate](https://codeclimate.com/github/gogotanaka/Rubype/badges/gpa.svg)](https://codeclimate.com/github/gogotanaka/Rubype)

![210414.png](https://qiita-image-store.s3.amazonaws.com/0/30440/0aafba03-1a4c-4676-5377-75f906aaeab9.png)
```rb
require 'rubype'
class MyClass
  # Assert first arg has method #to_i, second arg and return value are instance of Numeric.
  def sum(x, y)
    x.to_i + y
  end
  typesig :sum, [:to_i, Numeric] => Numeric
end

MyClass.new.sum(:has_no_to_i, 2)
#=> Rubype::ArgumentTypeError: for MyClass#sum's 1st argument
#   Expected: respond to :to_i,
#   Actual:   :has_no_to_i
#   ...(stack trace)
```


This gem brings you advantage of type without changing existing code's behavior.

## Good point:
* Meaningful error
* Executable documentation
* Don't need to check type of method's arguments and return.
* Type info itself is object, you can check it and even change it during run time.

## Bad point:
* Checking type run every time method call... it might be overhead, but it's not big deal.
* There is no static analysis.

# Feature
### Super clean!!!
I know it's terrible to run your important code with such a hacked gem.
But this contract is implemented by less than 80 lines source code!
(It is not too little, works well enough)
https://github.com/gogotanaka/Rubype/blob/develop/lib/rubype.rb#L2-L79

You can read this over easily and even you can implement by yourself !(Don't need to use this gem, just take idea)

### Advantage of type
* Meaningful error
* Executable documentation
* Don't need to check type of method's arguments and return .

```rb
require 'rubype'

# ex1: Assert class of args and return
class MyClass
  def sum(x, y)
    x + y
  end
  typesig :sum, [Numeric, Numeric] => Numeric

  def wrong_sum(x, y)
    'string'
  end
  typesig :wrong_sum, [Numeric, Numeric] => Numeric
end

MyClass.new.sum(1, 2)
#=> 3

MyClass.new.sum(1, 'string')
#=> Rubype::ArgumentTypeError: for MyClass#sum's 2nd argument
#   Expected: Numeric,
#   Actual:   "string"
#   ...(stack trace)

MyClass.new.wrong_sum(1, 2)
#=> Rubype::ReturnTypeError: for MyClass#wrong_sum's return
#   Expected: Numeric,
#   Actual:   "string"
#   ...(stack trace)


# ex2: Assert object has specified method
class MyClass
  def sum(x, y)
    x.to_i + y
  end
  typesig :sum, [:to_i, Numeric] => Numeric
end

MyClass.new.sum('1', 2)
#=> 3

MyClass.new.sum(:has_no_to_i, 2)
#=> Rubype::ArgumentTypeError: for MyClass#sum's 1st argument
#   Expected: respond to :to_i,
#   Actual:   :has_no_to_i
#   ...(stack trace)


# ex3: You can use Any class, if you want
class People
  def marry(people)
    # Your Ruby code as usual
  end
  typesig :marry, [People] => Any
end

People.new.marry(People.new)
#=> no error

People.new.marry('non people')
#=> Rubype::ArgumentTypeError: for People#marry's 1st argument
#   Expected: People,
#   Actual:   "non people"
#   ...(stack trace)

```

### Typed method can coexist with non-typed method

```ruby
# It's totally OK!!
class MyClass
  def method_with_type(x, y)
    x + y
  end
  typesig :method_with_type, [Numeric, Numeric] => Numeric

  def method_without_type(x, y)
    'string'
  end
end
```

### Duck typing
You can use `Any` class.
```ruby
class MyClass
  def foo(any_obj)
    1
  end
  typesig :foo, [Any] => Numeric

  def sum(x, y)
    x.to_i + y
  end
  typesig :sum, [:to_i, Numeric] => Numeric
end

# It's totally OK!!
MyClass.new.foo(1)
# It's totally OK!!
MyClass.new.foo(:sym)


# It's totally OK!!
MyClass.new.sum(1, 2)
# It's totally OK!!
MyClass.new.sum('1', 2)
```

### Check type info everywhere!
```ruby
class MyClass
  def sum(x, y)
    x.to_i + y
  end
  typesig :sum, [:to_i, Numeric] => Numeric
end

MyClass.new.method(:sum).type_info
# => [:to_i, Numeric] => Numeric

MyClass.new.method(:sum).arg_types
# => [:to_i, Numeric]

MyClass.new.method(:sum).return_type
# => Numeric
```

## Benchmarks

#### result of `bundle exec rake benchmark`

Ruby 2.2.1, Macbook Pro 2.7Ghz Intel Core i5, 8GB RAM

```
ruby version: 2.2.1
rubype version: 0.3.0
Calculating -------------------------------------
           Pure Ruby   101.070k i/100ms
              Rubype    63.973k i/100ms
-------------------------------------------------
           Pure Ruby      7.115M (± 6.1%) i/s -     35.476M
              Rubype      1.537M (± 2.5%) i/s -      7.677M

Comparison:
           Pure Ruby:  7114786.0 i/s
              Rubype:  1536611.5 i/s - 4.63x slower
```



## Installation

gem install rubype or add gem 'rubype' to your Gemfile.

And `require 'rubype'`, enjoy typed Ruby.

This gem requires Ruby 2.0.0+.

### Contributing

* I really wanna make Rubype elegant source code.

* Any feature or comments are welcome.

#### How to develop

Now Rubype is written with 100% Ruby.
In terms of performance, only core module(https://github.com/gogotanaka/Rubype/blob/develop/lib/rubype.rb#L4-L80) will be translate to C.

Only two API will be translate to C, it means you don't need to know what C dose!

1. Fork it ( https://github.com/gogotanaka/Rubype/fork )

2. Create your feature branch (`git checkout -b my-new-feature`)

    $ bundle install --path vendor/bundle

3. Commit your changes (`git commit -am 'Add some feature'`)

4. Run tests

    $ bundle exec rake test

    ......

5. Run benchmerk(optional)

    $ bundle exec rake bm

    ......

6. Push to the branch (`git push origin my-new-feature`)

7. Create a new Pull Request to `develop` branch

## Credits
[@chancancode](https://github.com/chancancode) and [This article](http://blog.codeclimate.com/blog/2014/05/06/gradual-type-checking-for-ruby/) first brought this to my attention. I've stolen some idea from them.

## License

MIT license (© 2015 Kazuki Tanaka)
