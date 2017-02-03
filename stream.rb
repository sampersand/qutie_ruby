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
    return shift unless amnt
    shift(amnt).join
  end

  def peek(amnt=nil)
    raise if empty?
    return first unless amnt
    first(amnt).join
  end

  alias :feed :unshift
end
