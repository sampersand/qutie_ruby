require_relative 'stream'
class Universe
  attr_reader :stack
  attr_reader :knowns

  def initialize(stack: nil, knowns: nil)
    @stack = stack || []
    @knowns = knowns || {}
  end

  def inspect
    stack_str = @stack.join.strip
    knowns_str = @knowns.join.strip
    "<#{stack_str} | #{knowns_str}>"
  end

  def <<(val)
    @stack << val
  end

  alias :push :val

  def pop
    @stack.pop
  end

end