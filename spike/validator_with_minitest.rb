o = Object.new
ms = o.methods
require "minitest"

block = proc do |payload|
  assert_kind_of(Array, payload, 'Payload should be a collection')
  payload.each do |element|
    assert_kind_of(Hash, element, 'Payload collection elements should be hashtables')

    assert_includes(element.keys, 'hello')
  end
end

good_payload = [
  {"hello" => "world1"},
  {"hello" => "world2"}
]

bad1_payload = [
  {"nope" => "world1"},
  {"hello" => "world2"}
]

bad2_payload = {"hello" => "world2"}

class Validator

  include Minitest::Assertions

  attr_accessor :assertions
  def initialize(&block)
    @assertions = 0
    singleton = class << self
      self
    end
    singleton.__send__(:define_method, :tester, &block)
    singleton.__send__(:protected, :tester)
  end

  def test(payload)
    tester(payload)
  rescue Minitest::Assertion => ex
    puts ex.message
  end

end


puts Object.new.methods - ms # no output , no monkey patch than

v = Validator.new(&block)
v.test(good_payload)
v.test(bad1_payload)
v.test(bad2_payload)
