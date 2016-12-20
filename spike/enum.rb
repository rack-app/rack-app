fib = Enumerator.new do |y|
  a = b = 1
  10.times do
    y << a
    a, b = b, a + b
  end
end

fib.each do |e|
  p e
end
