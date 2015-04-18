require "bundler/gem_tasks"
require "rake/testtask"

Rake::TestTask.new(:test) do |t|
  t.libs << "test"
end
task default: :test

#  Benchmark
#-----------------------------------------------
desc "Compare with pure ruby"
task :benchmark do
  require "benchmark/ips"
  require "rubype"
  require "rubype/version"

  puts "ruby version: #{RUBY_VERSION}"
  class PureClass
    def sum(x, y)
      x + y
    end
  end
  pure_instance = PureClass.new

  puts "rubype version: #{Rubype::VERSION}"
  class RubypeClass
    def sum(x, y)
      x + y
    end
    typesig :sum, [Numeric, Numeric] => Numeric
  end
  rubype_instance = RubypeClass.new

  Benchmark.ips do |x|
    x.report('Pure Ruby') { pure_instance.sum(4, 2) }
    x.report('Rubype') { rubype_instance.sum(4, 2) }

    x.compare!
  end
end
task bm: :benchmark
