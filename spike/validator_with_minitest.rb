o = Object.new
ms = o.methods
require "minitest"

block = proc do |payload|
  assert_kind_of(Array, payload, 'Payload should be a collection')
  payload.each do |element|
    assert_kind_of(Hash, element, 'Payload collection elements should be hashtables')

    assert_includes(element.keys, 'hello', 'payload elements should has hello key')
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
    singleton.__send__(:define_method, :__tester__, &block)
    singleton.__send__(:protected, :__tester__)
  end

  def test(payload)
    __tester__(payload)
  rescue Minitest::Assertion => ex
    puts ex.message
  end

end

class Documentation

  def initialize(&block)
    @docs = []
    singleton = class << self
      self
    end
    singleton.__send__(:define_method, :__tester__, &block)
    singleton.__send__(:protected, :__tester__)
  end

  def to_doc
    o = Object.new
    def o.method_missing(*_)
      self
    end

    def o.each(&block)
      block.call(self)
    end

    def o.inspect
      'element'
    end
    __tester__(o)

    @docs.join("\n")
  end

  protected

  def method_missing(method_name,*args,&block)
    @docs << args.select{|arg| arg.is_a?(String) }.last
  end

end


puts Object.new.methods - ms # no output , no monkey patch than

v = Validator.new(&block)
v.test(good_payload)
v.test(bad1_payload)
v.test(bad2_payload)

d = Documentation.new(&block)
puts d.to_doc
