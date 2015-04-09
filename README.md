# Ruby + Type = Rubype

[![Gem Version](https://badge.fury.io/rb/rubype.svg)](http://badge.fury.io/rb/rubype) [![Build Status](https://travis-ci.org/gogotanaka/Rubype.svg?branch=develop)](https://travis-ci.org/gogotanaka/Rubype) [![Dependency Status](https://gemnasium.com/gogotanaka/Rubype.svg)](https://gemnasium.com/gogotanaka/Rubype) [![Code Climate](https://codeclimate.com/github/gogotanaka/Rubype/badges/gpa.svg)](https://codeclimate.com/github/gogotanaka/Rubype)

![210414.png](https://qiita-image-store.s3.amazonaws.com/0/30440/0aafba03-1a4c-4676-5377-75f906aaeab9.png)
```rb
# Assert class of both args is Numeric and class of return is String
def sum(x, y)
  (x + y).to_s
end
typesig :sum, [Numeric, Numeric] => String

# Assert first arg has method #to_i
def sum(x, y)
  x.to_i + y
end
typesig :sum, [:to_i, Numeric] => Numeric
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
#=> Rubype::ArgumentTypeError: Expected MyClass#sum's 2nd argument to be Numeric but got "string" instead

MyClass.new.wrong_sum(1, 2)
#=> Rubype::ReturnTypeError: Expected MyClass#wrong_sum to return Numeric but got "string" instead


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
#=> Rubype::ArgumentTypeError: Expected MyClass#sum's 1st argument to have method #to_i but got :has_no_to_i instead


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
#=> Rubype::ArgumentTypeError: Expected People#marry's 1st argument to be People but got "non people" instead

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

```ruby
require 'rubype'
require 'benchmark'

class RubypeCommonClass
  def sum(x, y)
    x + y
  end
  typesig :sum, [Numeric, Numeric] => Numeric
end

class CommonClass
  def sum(x, y)
    x + y
  end
end

class RubypeDucktypeClass
  def sum(x, y)
    x.to_i + y
  end
  typesig :sum, [:to_i, Numeric] => Numeric
end

class DucktypeClass
  def sum(x, y)
    x.to_i + y
  end
end

N = 100_000
Benchmark.bm("RubypeDucktypeClass".length + 3) do |x|
  x.report("RubypeCommonClass") { N.times { RubypeCommonClass.new.sum(1, 5) } }
  x.report("CommonClass")       { N.times { CommonClass.new.sum(1, 5) } }
end

Benchmark.bm("RubypeDucktypeClass".length + 3) do |x|
  x.report("RubypeDucktypeClass")  { N.times { RubypeDucktypeClass.new.sum(1, 5) } }
  x.report("DucktypeClass")        { N.times { DucktypeClass.new.sum(1, 5) } }
end
```

### Results
Ruby 2.2.0, Macbook Pro 2.9Ghz Intel Core i7, 8GB RAM

```
                             user     system      total        real
RubypeCommonClass        0.530000   0.010000   0.540000 (  0.566493)
CommonClass              0.030000   0.000000   0.030000 (  0.035718)
                             user     system      total        real
RubypeDucktypeClass      0.590000   0.010000   0.600000 (  0.682504)
DucktypeClass            0.030000   0.000000   0.030000 (  0.029856)
```



## Installation

gem install rubype or add gem 'rubype' to your Gemfile.

And `require 'rubype'`, enjoy typed Ruby.

This gem requires Ruby 2.0.0+.

### Contributing

Fork it ( https://github.com/[my-github-username]/rubype/fork )

Create your feature branch (`git checkout -b my-new-feature`)

    $ bundle install --path vendor/bundle

Commit your changes (`git commit -am 'Add some feature'`)

    $ bundle exec rake test

    ......

    Finished in 0.010961s, 547.3953 runs/s, 5017.7903 assertions/s.

    7 runs, 61 assertions, 0 failures, 0 errors, 0 skips

Push to the branch (`git push origin my-new-feature`)

Create a new Pull Request to `develop` branch

## Credits
[@chancancode](https://github.com/chancancode) and [This article](http://blog.codeclimate.com/blog/2014/05/06/gradual-type-checking-for-ruby/) first brought this to my attention. I've stolen some idea from them.
