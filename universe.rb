class Universe

  attr_reader :stack
  attr_reader :knowns

  def self.from_string(input)
    new(stack: input.each_char.to_a)
  end

  def initialize(stack: nil, knowns: nil)
    @stack = stack || []
    @knowns = knowns || {}
  end

  def inspect
    "<#{@stack} | #{@knowns}>"
  end

  def next(amnt=nil)
    raise EOFError if @stack.empty?
    return @stack.shift unless amnt
    @stack.shift(amnt).join
  end

  def peek(amnt=nil)
    raise EOFError if @stack.empty?
    return @stack.first unless amnt
    @stack.first(amnt).join
  end

  def feed(*vals)
    @stack.unshift(*vals)
  end

  def push(val)
    @stack.push val
  end
  alias :<< :push
end












