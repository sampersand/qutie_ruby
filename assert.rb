module Assertions
  AssertionError = Class.new(Exception)

  module_function
  def assert(statement=nil, msg: '', &block)
    if statement
      fail msg unless statement
    elsif block_given?
      fail msg unless block.call()
    else
      fail "No statement or block given!"
    end
  end

end
