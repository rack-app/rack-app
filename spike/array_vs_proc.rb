require 'benchmark'

TEST_AMOUNT = 1_000_000
Benchmark.bm(15) do |x|

  x.report('empty_array') do
    empty_array = []
    TEST_AMOUNT.times do
      empty_array.each{|e|}
    end
  end

  x.report('proc call') do
    block = proc {}
    TEST_AMOUNT.times do
      block.call
    end
  end

end
