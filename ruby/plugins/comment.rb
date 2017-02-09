module Comment
  module_function

  SINGLE_STARTS = ['#', '//']
  SINGLE_END = "\n"
  def next_single!(stream) # this will break if somehow SINGLE_STARTS includes single_end
    return unless stream.peek_any?(vals: SINGLE_STARTS]
    stream.next until stream.peek?(str: SINGLE_END)
    stream.next # and ignore
    true
  end
  
  MULTI_LINE_START = '/*'
  MULTI_LINE_END = '*/'
  
  def next_multi!(stream)
    return unless stream.peek?(str: MULTI_LINE_START)
    stream.next until stream.peek?(str: MULTI_LINE_END) # this will fail inside strings, but that's ok C does as well.
    stream.next(amnt: MULTI_LINE_END) # and ignore
    true
  end

  def next_token!(stream, _, _)
    next_single!(stream) || next_multi!(stream) and :retry
  end
end
