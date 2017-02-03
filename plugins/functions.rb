module Functions
  module_function

  FUNCITONS = {
    if: 'if',
    disp: 'disp',
    while: 'while',
    clone: 'clone',
    exit: 'exit',
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

  def handle_disp(stream, universe, parser)
    to_print = next_argument(stream, universe, parser, do_eval: true, do_pop: false)
    endl = to_print.get('end') || "\n"
    sep  = to_print.get('sep') || " "
    print(to_print.stack.collect do |e|
      e.respond_to?(:__str) ? e.__str(stream, universe, parser) : e.to_s
    end.join(sep) + endl)
  end


  def handle_while(stream, universe, parser)
    cond = next_argument(stream, universe, parser)
    body = next_argument(stream, universe, parser)

    while(parser.parse_all(cond, universe.knowns_only).stack.pop)
      parser.parse_all(body, universe.knowns_only)
    end
  end

  def handle_clone(stream, universe, parser)
    to_clone = next_argument(stream, universe, parser, do_eval: true)
    universe <<(case to_clone
                when true, false, nil, Numeric then to_clone
                else to_clone.clone
                end)
    # while(parser.parse_all(cond, universe.knowns_only).stack.pop)
    #   parser.parse_all(body, universe.knowns_only)
    # end
  end

  def parse(stream, _, _)
    res = FUNCITONS.find{ |_, sym| sym == stream.peek(sym.length) && stream.next(sym.length) }
    res and res[-1]
  end

  def handle(token, stream, universe, parser)
    case token
    when FUNCITONS[:if]
      handle_if(stream, universe, parser)
    when FUNCITONS[:disp]
      handle_disp(stream, universe, parser)
    when FUNCITONS[:while]
      handle_while(stream, universe, parser)
    when FUNCITONS[:clone]
      handle_clone(stream, universe, parser)
    else raise "Unknown function `#{token}`"
    end
  end

end










