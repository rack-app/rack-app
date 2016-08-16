require 'benchmark'

class TestSubject
  def test
    'OK'
  end
end

block = proc do
  test
end

TestSubject.__send__(:define_method, :defined_method,&block)

TEST_AMOUNT = 1_000_000

Benchmark.bm(15) do |x|

  x.report('method call') do
    TEST_AMOUNT.times do
      test_subject = TestSubject.new
      test_subject.__send__(:defined_method)
    end
  end

  x.report('instance_exec') do
    TEST_AMOUNT.times do
      test_subject = TestSubject.new
      test_subject.instance_exec(&block)
    end
  end

end
