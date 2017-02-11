require_relative '../text/text'
module Comment
  module_function

  SINGLE_START_HASH = QT_Default.new :'#'
  SINGLE_START_SLASH = QT_Default.new :'//'
  SINGLE_END = QT_Default.new :"\n"

  def next_single!(stream:, **_) # this will break if somehow SINGLE_STARTS includes single_end
    return unless SINGLE_START_HASH == stream._peek || SINGLE_START_SLASH == stream._peek(2)
    stream._next until SINGLE_END == stream._peek
    stream._next # and ignore
    :retry
  end
  
  MULTI_LINE_START = QT_Default.new :'/*'
  MULTI_LINE_END = QT_Default.new :'*/'
  
  def next_multi!(stream:, **_)
    return unless MULTI_LINE_START == stream._peek(2)
    stream._next until MULTI_LINE_END == stream._peek(2)
    stream._next(2) # and ignore
    :retry
  end

  def next_token!(stream:, **kw)
    next_single!(stream: stream, **kw) || next_multi!(stream: stream, **kw)
  end
end










