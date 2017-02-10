require_relative '../text/text'
module Comment
  module_function

  SINGLE_START_HASH = QT_Text.new '#'
  SINGLE_START_SLASH = QT_Text.new '//'
  SINGLE_END = "\n"

  def next_single!(stream:, **_) # this will break if somehow SINGLE_STARTS includes single_end
    return if stream.qt_peek(QT_Number::ONE).qt_eql(SINGLE_START_HASH).qt_false? &&
              stream.qt_peek(QT_Number::TWO).qt_eql(SINGLE_START_SLASH).qt_false?
    stream.next until stream.peek?(str: SINGLE_END)
    stream.next # and ignore
    :retry
  end
  
  MULTI_LINE_START = '/*'
  MULTI_LINE_END = '*/'
  
  def next_multi!(stream:, **_)
    return unless stream.peek?(str: MULTI_LINE_START)
    stream.next until stream.peek?(str: MULTI_LINE_END) # this will fail inside strings, but that's ok C does as well.
    stream.next(amnt: MULTI_LINE_END.length) # and ignore
    :retry
  end

  def next_token!(stream:, **kw)
    return
    next_single!(stream: stream, **kw) || next_multi!(stream: stream, **kw)
  end
end
