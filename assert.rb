module Assertions
  AssertionError = Class.new(Exception)

  module_function
  
  def assert(statement, msg)
    fail AssertionError, msg unless statement
  end
  
  def assert_is_any(obj, *types, objname)
    assert types.any?(&obj.method(:is_a?)), "Unexpected type for #{objname}: #{obj.class} (expected one of #{types})"
  end
  
  def assert_respond_all(obj, *methods, objname) #TODO: THIS
    assert methods.all?(&obj.method(:respond_to?)), "Expected response for #{objname}.#{methods}"
  end

  def assert_is_a(obj, type, objname)
    assert obj.is_a?(type), "Unexpected type for #{objname}: #{obj.class} (expected #{type})"
  end
  alias :assert_respond_to :assert_respond_all
  # def assert_each(obj, msg: '', &block)
  #   raise unless obj.respond_to?(:each) && block_given?
  #   assert(obj.all?{ |*a, **k, &b| block.(*a, **k, &b) })
  # end
end












