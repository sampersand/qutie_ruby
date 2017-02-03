module Functions
  module_function

  FUNCITONS = {
    if: 'if',
    disp: 'disp',
    while: 'while',
  }

  def handle_if(stream, universe, parser)

    cond = parser.parse(stream, universe)
      raise unless cond[1] == Parenthesis
      cond_univ = universe.to_globals
      cond[1].handle(cond[0], stream, cond_univ, parser)
      cond = cond_univ.stack.pop
      raise unless cond_univ.stack.empty?
      cond = parser.parse_all(cond.clone, universe.knowns_only).stack.pop

    if_true = parser.parse(stream, universe)
      raise unless if_true[1] == Parenthesis
      if_true_univ = universe.to_globals
      if_true[1].handle(if_true[0], stream, if_true_univ, parser)
      if_true = if_true_univ.stack.pop
      raise unless if_true_univ.stack.empty?
    p [cond, cond != false && cond != nil && cond != 0]
    if(cond != false && cond != nil && cond != 0)
      universe << parser.parse_all(if_true.clone, universe.knowns_only)
      return
    end
    p [cond, cond != false && cond != nil && cond != 0]
    if_false = parser.parse(stream, universe)
      if_false = parser.parse(stream, universe) if if_false[0] == 'else'
      if if_false[1] == Parenthesis
        if_true_univ = universe.to_globals
        if_false[1].handle(if_false[0], stream, if_true_univ, parser)
        if_false = if_true_univ.stack.pop
        raise unless if_true_univ.stack.empty?
      if_false = parser.parse_all(if_false.clone, universe.knowns_only)
      else
        stream.feed(if_false[0])
        if_false = nil
      end
    universe << if_false
  end

  def handle_disp(universe, parser)
    # universe << parser.parse_all(universe.pop.clone, universe.to_globals)
  end

  def handle_while(universe, parser)
    # handle_eval_univ(universe, parser)
    # universe << universe.pop.pop
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
      handle_disp(universe, parser)
    when FUNCITONS[:while]
      handle_while(universe, parser)
    else raise "Unknown function `#{token}`"
    end
  end

end










