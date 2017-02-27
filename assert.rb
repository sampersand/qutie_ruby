module Assertions
  AssertionError = Class.new(Exception)

  module_function
  
  def assert(statement=nil, msg: '', &block)
    if !statement.nil?
      fail AssertionError, msg.to_s unless statement
    elsif statement.nil?
      fail AssertionError, msg.to_s unless block.call()
    else
      fail "No statement or block given!"
    end
  end
  
  def assert_is_any(obj, *types, msg: '')
    assert types.any?(&obj.method(:is_a?)), msg: msg
  end
  
  def assert_respond_all(obj, *methods, msg: '')
    assert methods.all?(&obj.method(:respond_to?)), msg: msg
  end

  alias :assert_is_a :assert_is_any
  alias :assert_respond_to :assert_respond_all
  # def assert_each(obj, msg: '', &block)
  #   raise unless obj.respond_to?(:each) && block_given?
  #   assert(obj.all?{ |*a, **k, &b| block.(*a, **k, &b) })
  # end
end