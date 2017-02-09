module Keyword
  module_function

  def handle_get_known(universe:, **_)
    # universe << universe.qt_get(pos: universe.pop, type: :BOTH)
    universe << (universe[universe.pop] || QT_Boolean::NULL)
  end

  def handle_eval(universe:, **kw)
    last = universe.pop
    universe << last.qt_eval(universe: universe.spawn_new_stack(new_stack: nil).clone, **kw)
    # if last == nil || last == false
    #   universe << last
    # else
    #   # this isn't parse! cause i dont want it being destroyed each time we read it
    #   universe << parser.parse(stream: last,
    #                            universe: universe.spawn_new_stack(new_stack: nil).clone)
    # end
  end

  def next_token!(stream:, **_)
    res = KEYWORDS.find{ |val, _| stream.peek?(str: val) }
    res and stream.next(amnt: res[0].length)
  end

  def handle(token:, stream:, universe:, parser:)
    KEYWORDS[token].call(stream: stream,
                         universe: universe,
                         parser: parser)
  end

  KEYWORDS = {
    '?' => method(:handle_get_known),
    '!' => method(:handle_eval),
  }

end





