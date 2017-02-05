module Keyword
  module_function

  KEYWORDS = {
    get_known: '?',
    eval_univ: '!',
    pop_lastv: '$', #not _technically_ a keyword, as it can be constructed from other symbols
  }

  def handle_get_known(universe)
    universe << universe.get(universe.pop!)
  end

  def handle_eval_univ(universe, parser)
    raise
    last = universe.pop!
    if last == nil || last == false
      universe << last
    else
      universe << parser.parse_all(last, universe.knowns_only)
    end
  end

  def handle_pop_lastv(universe, parser)
    handle_eval_univ(universe, parser)
    universe << universe.pop.pop
  end

  def next_token!(stream, _, _)
    res = KEYWORDS.find{ |_, sym| stream.peek?(sym) }
    KEYWORDS.find{ |_, sym| puts sym, stream.peek(1) == sym }
    res and stream.next!(res[-1].length)
  end

  def handle(token, stream, universe, parser)
    raise
    case token
    when KEYWORDS[:get_known] then handle_get_known(universe)
    when KEYWORDS[:eval_univ] then handle_eval_univ(universe, parser)
    when KEYWORDS[:pop_lastv] then handle_pop_lastv(universe, parser)
    else raise "Unknown keyword `#{token}`"
    end
  end

end










