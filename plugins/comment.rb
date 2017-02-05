module Comment
  module_function

  def next_single!(stream)
    return unless stream.peek?('#') || stream.peek?('//')
    stream.next until stream.peek == "\n"
    stream.next
    :retry
  end
  def next_multi!(stream)
    return unless stream.peek?('/*')
    stream.next until stream.peek?('*/') # this will fail inside strings, but that's ok C does as well.
    stream.next(2)
    :retry
  end

  def next_token!(stream, _, _)
    next_single!(stream) || next_multi!(stream)
  end
end
