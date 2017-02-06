module Keyword
  module_function

  def handle_get_known(_, universe, _)
    # universe << universe.get(universe.pop!)
    to_get = universe.pop!;
    universe << (to_get == :__current ? universe : universe.get(to_get))
  end

  def handle_eval_univ(_, universe, parser)
    last = universe.pop!
    if last == nil || last == false
      universe << last
    else
      # this isn't parse! cause i dont want it being destroyed each time we read it
      universe << parser.parse(last, universe.knowns_only)
    end
  end

  def handle_pop_lastv(_stream, universe, parser)
    handle_eval_univ(_stream, universe, parser)
    universe << universe.pop!.pop!
  end

  def next_token!(stream, _, _)
    res = KEYWORDS.find{ |val, _| stream.peek?(val) }
    res and stream.next!(res[0])
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




a = {
  b: {
    c: :d
  }
}
e = {
  b: {
    g: :h
  }
}
a.clone[:b].update(e[:b])
p a








