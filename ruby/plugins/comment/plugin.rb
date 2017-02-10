require_relative '../text/text'
module Comment
  module_function

  SINGLE_START_HASH = QT_Text.new '#'
  SINGLE_START_SLASH = QT_Text.new '//'
  SINGLE_END = QT_Text.new "\n"

  def next_single!(stream:, **_) # this will break if somehow SINGLE_STARTS includes single_end
    return unless stream.qt_peek(QT_Number::ONE).qt_eql(SINGLE_START_HASH).bool_val ||
                  stream.qt_peek(QT_Number::TWO).qt_eql(SINGLE_START_SLASH).bool_val
    stream.qt_next(QT_Number::ONE) until stream.qt_peek(QT_Number::ONE).qt_eql(SINGLE_END).bool_val
    stream.qt_next(QT_Number::ONE) # and ignore
    :retry
  end
  
  MULTI_LINE_START = QT_Text.new '/*'
  MULTI_LINE_END = QT_Text.new '*/'
  
  def next_multi!(stream:, **_)
    return unless stream.qt_peek(QT_Number::TWO).qt_eql(MULTI_LINE_START).bool_val
    stream.qt_next(QT_Number::ONE) until stream.qt_peek(QT_Number::TWO).qt_eql(MULTI_LINE_END).bool_val
    stream.qt_next(QT_Number::TWO) # and ignore
    :retry
  end

  def next_token!(stream:, **kw)
    next_single!(stream: stream, **kw) || next_multi!(stream: stream, **kw)
  end
end










