require 'benchmark'

VALUE = 'OK'
class A
  attr_accessor :value
end

class B
  def value=(new_value)
    @value = new_value
  end
  def value
    @value
  end
end

class C
  attr_reader :value
  def value=(new_value)
    @value = new_value
  end
end

a = A.new
a.value= VALUE

b = B.new
b.value= VALUE

c = C.new
c.value= VALUE

o = Object.new
o.define_singleton_method(:value){ VALUE }

h = {:value => VALUE}

TEST_AMOUNT = 10_000_000

Benchmark.bm(30) do |x|

  x.report('attr_accessor') do
    TEST_AMOUNT.times do
      a.value
    end
  end

  x.report('defined + instance var') do
    TEST_AMOUNT.times do
      b.value
    end
  end

  x.report('defined setter + attr_reader') do
    TEST_AMOUNT.times do
      c.value
    end
  end

  x.report('attr_reader + __send__') do
    TEST_AMOUNT.times do
      c.__send__(:value)
    end
  end

  x.report('anonimus method call') do
    TEST_AMOUNT.times do
      o.value
    end
  end

  x.report('hash getter') do
    TEST_AMOUNT.times do
      h[:value]
    end
  end

end
