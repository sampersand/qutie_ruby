module Keyword
  module_function

  KEYWORDS = {
    get_known: '?',
    eval_univ: '!',
    pop_lastv: '$', #not _technically_ a keyword, as it can be constructed from other symbols
  }

  def handle_get_known(universe)
    universe << universe.get(universe.pop)
  end

  def handle_eval_univ(universe, parser)
    last = universe.pop
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

  def parse(stream, u, _)
    res = KEYWORDS.find{ |_, sym| sym == stream.peek(sym.length) && stream.next(sym.length) }
    res and res[-1]
  end

  def handle(token, stream, universe, parser)
    case token
    when KEYWORDS[:get_known] then handle_get_known(universe)
    when KEYWORDS[:eval_univ] then handle_eval_univ(universe, parser)
    when KEYWORDS[:pop_lastv] then handle_pop_lastv(universe, parser)
    else raise "Unknown keyword `#{token}`"
    end
  end

end










