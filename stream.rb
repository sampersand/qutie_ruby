class Stream < Array
  def self.from(input)
    new input.each_char.to_a
  end

  def initialize(arr)
    super()
    concat arr
  end

  def next(amnt=nil)
    raise if empty?
    [shift(amnt)].flatten.join
  end

  def peek(amnt=nil)
    raise if empty?
    [first(amnt)].flatten.join
  end

  def feed(*vals)
    unshift(*vals)
  end
end