module Keyword
  module_function

  def handle_get_known(universe:, **_)
    universe << universe[universe.pop]
  end

  def handle_eval_univ(universe:, parser:, **_)
    last = universe.pop
    if last == nil || last == false
      universe << last
    else
      # this isn't parse! cause i dont want it being destroyed each time we read it
      universe << parser.parse(stream: last,
                               universe: universe.spawn_new_stack(new_stack: nil).clone)
    end
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
    '!' => method(:handle_eval_univ),
  }

end





