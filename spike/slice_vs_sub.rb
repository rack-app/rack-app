require 'benchmark'

TEST_AMOUNT = 2_000_000
Benchmark.bm(15) do |x|

  rgx = /\0\z/
  x.report('sub! + rgx') do
    TEST_AMOUNT.times do
      str = "hello\0"
      str.sub!(rgx, '')
    end
  end

  x.report('slice! + rgx') do
    TEST_AMOUNT.times do
      str = "hello\0"
      str.slice!(rgx)
    end
  end

  end_char = ?\0

  x.report('slice! + int + if') do
    TEST_AMOUNT.times do
      str = "hello\0"
      str.slice!(-1) if str[-1] == end_char
    end
  end

end
