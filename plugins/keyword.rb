module Keyword
  module_function

  def handle_get_known(_, universe, _)
    universe << universe.get(universe.pop!)
  end

  def handle_eval_univ(_, universe, parser)
    last = universe.pop!
    if last == nil || last == false
      universe << last
    else
      universe << parser.parse(last, universe.knowns_only) # this isn't parse! cause i dont want it being destroyed each time we read it
    end
  end

  def handle_pop_lastv(_stream, universe, parser)
    handle_eval_univ(_stream, universe, parser)
    universe << universe.pop!.pop!
  end

  def next_token!(stream, _, _)
    res = KEYWORDS.find{ |val, _| stream.peek?(val) }
    res and stream.next!(res[0].length)
  end

  def handle(token, stream, universe, parser)
    KEYWORDS[token].(stream, universe, parser)
  end

  KEYWORDS = {
    '?' => method(:handle_get_known),
    '!' => method(:handle_eval_univ),
    '$' => method(:handle_pop_lastv),
  }


end










