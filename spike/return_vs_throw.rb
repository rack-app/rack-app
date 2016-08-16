require 'benchmark'

class TestSubject

  def tvalue
    catch :value do
      tget
    end
  end

  def rvalue
    catch :value do
      rget
    end
  end

  def tget
    throw :value, 'hello'
  end

  def rget
    return 'hello'
  end

end

TEST_AMOUNT = 1_000_000

Benchmark.bm(15) do |x|

  x.report('throw') do
    test_subject = TestSubject.new
    TEST_AMOUNT.times do
      test_subject.tvalue
    end
  end

  x.report('return') do
    test_subject = TestSubject.new
    TEST_AMOUNT.times do
      test_subject.rvalue 
    end
  end

end
