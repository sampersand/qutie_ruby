module Keyword
  module_function

  KEYWORDS = {
    get_known: '?',
    eval_univ: '!',
  }

  def handle_get_known(_, universe, _)
    universe << universe.get(universe.pop)
  end

  def handle_eval_univ(_, universe, parser)
    universe << parser.parse_all(universe.pop, universe.to_globals)
  end

  def parse(stream, _, _)
    res = KEYWORDS.find{ |_, sym| sym == stream.peek(sym.length) && stream.next(sym.length) }
    res and res[-1]
  end

  def handle(token, stream, universe, parser)
    case token
    when KEYWORDS[:get_known]
      handle_get_known(stream, universe, parser)
    when KEYWORDS[:eval_univ]
      handle_eval_univ(stream, universe, parser)
    else raise "Unknown keyword #{token}"
    end
  end

end










