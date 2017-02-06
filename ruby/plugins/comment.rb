module Comment
  module_function

  SINGLE_START_1 = '#'
  SINGLE_START_2 = '//'
  SINGLE_END = "\n"
  def next_single!(stream)
    return unless stream.peek?(SINGLE_START_1) || stream.peek?(SINGLE_START_2)
    stream.next! until stream.peek?(SINGLE_END)
    stream.next!
    :retry
  end
  MULTI_LINE_START = '/*'
  MULTI_LINE_END = '*/'
  
  def next_multi!(stream)
    return unless stream.peek?(MULTI_LINE_START)
    stream.next! until stream.peek?(MULTI_LINE_END) # this will fail inside strings, but that's ok C does as well.
    stream.next!(MULTI_LINE_END)
    :retry
  end

  def next_token!(stream, _, _)
    next_single!(stream) || next_multi!(stream)
  end
end
