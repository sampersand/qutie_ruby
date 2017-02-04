module KeywordFunctions
  module_function

  FUNCTIONS = {
    if: 'if',
    while: 'while',
  }

  def next_argument(stream, universe, parser, do_eval: false, do_crash: true, do_pop: true)
    to_clone = parser.parse(stream, universe)
      unless to_clone[1] == Parenthesis
        stream.feed(to_clone[0])
        raise to_clone.to_s if do_crash
        return nil
      end
      cond_univ = universe.to_globals
      to_clone[1].handle(to_clone[0], stream, cond_univ, parser)
      to_clone = cond_univ.stack.pop
      raise unless cond_univ.stack.empty?
    to_clone = parser.parse_all(to_clone, universe.knowns_only) if do_eval
    to_clone = to_clone.stack.pop if do_eval && do_pop
    to_clone
  end

  def handle_if(stream, universe, parser)
    cond = next_argument(stream, universe, parser, do_eval: true)
    if_true = next_argument(stream, universe, parser)
    is_else = parser.parse(stream, universe)
    stream.feed(is_else[0]) unless is_else[0] == 'else'
    if_false = next_argument(stream, universe, parser, do_crash: false)
    universe <<(cond ? parser.parse_all(if_true, universe.knowns_only).stack.pop :
                       parser.parse_all(if_false, universe.knowns_only).stack.pop)
  end

  def handle_while(stream, universe, parser)
    cond = next_argument(stream, universe, parser)
    body = next_argument(stream, universe, parser)

    while(parser.parse_all(cond, universe.knowns_only).stack.pop)
      parser.parse_all(body, universe.knowns_only)
    end
  end

  def parse(stream, _, _)
    res = FUNCTIONS.find{ |_, sym| sym == stream.peek(sym.length) && stream.next(sym.length) }
    res and res[-1]
  end

  def handle(token, stream, universe, parser)
    case token
    when FUNCTIONS[:if]
      handle_if(stream, universe, parser)
    when FUNCTIONS[:while]
      handle_while(stream, universe, parser)

    else raise "Unknown keyword_function `#{token}`"
    end
  end

end










