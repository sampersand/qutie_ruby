module Functions
  module_function

  FUNCITONS = {
    if: 'if',
    disp: 'disp',
    while: 'while',
    clone: 'clone',
  }

  def handle_if(stream, universe, parser)

    cond = parser.parse(stream, universe)
      raise unless cond[1] == Parenthesis
      cond_univ = universe.to_globals
      cond[1].handle(cond[0], stream, cond_univ, parser)
      cond = cond_univ.stack.pop
      raise unless cond_univ.stack.empty?
      cond = parser.parse_all(cond, universe.knowns_only).stack.pop

    if_true = parser.parse(stream, universe)
      raise unless if_true[1] == Parenthesis
      if_true_univ = universe.to_globals
      if_true[1].handle(if_true[0], stream, if_true_univ, parser)
      if_true = if_true_univ.stack.pop
      raise unless if_true_univ.stack.empty?
      if_true = parser.parse_all(if_true, universe.knowns_only)
    if_false = parser.parse(stream, universe)
      if_false = parser.parse(stream, universe) if if_false[0] == 'else'
      if if_false[1] == Parenthesis
        if_true_univ = universe.to_globals
        if_false[1].handle(if_false[0], stream, if_true_univ, parser)
        if_false = if_true_univ.stack.pop
        raise unless if_true_univ.stack.empty?
      if_false = parser.parse_all(if_false, universe.knowns_only)
      else
        stream.feed(if_false[0])
        if_false = nil
      end
    universe << cond ? if_true : if_false
  end

  def handle_disp(stream, universe, parser)
    to_print = parser.parse(stream, universe)

    if to_print[1] == Parenthesis
      to_print_univ = universe.to_globals
      to_print[1].handle(to_print[0], stream, to_print_univ, parser)
      to_print = to_print_univ.stack.pop
      raise unless to_print_univ.stack.empty?
      to_print = parser.parse_all(to_print, universe.knowns_only)
    end
    endl = to_print.get('end') || "\n"
    sep  = to_print.get('sep') || " "
    print to_print.stack.collect(&:to_s).join(sep) + endl
  end


  def handle_while(stream, universe, parser)
    cond = parser.parse(stream, universe)
      raise unless cond[1] == Parenthesis
      cond_univ = universe.to_globals
      cond[1].handle(cond[0], stream, cond_univ, parser)
      cond = cond_univ.stack.pop
      raise unless cond_univ.stack.empty?

    body = parser.parse(stream, universe)
      raise unless body[1] == Parenthesis
      if_true_univ = universe.to_globals
      body[1].handle(body[0], stream, if_true_univ, parser)
      body = if_true_univ.stack.pop
      raise unless if_true_univ.stack.empty?

    while(parser.parse_all(cond, universe.knowns_only).stack.pop)
      parser.parse_all(body, universe.knowns_only)
    end
  end

  def handle_clone(stream, universe, parser)
    to_clone = parser.parse(stream, universe)
      raise unless to_clone[1] == Parenthesis
      cond_univ = universe.to_globals
      to_clone[1].handle(to_clone[0], stream, cond_univ, parser)
      to_clone = cond_univ.stack.pop
      raise unless cond_univ.stack.empty?
    to_clone = parser.parse_all(to_clone, universe.knowns_only)
    raise unless to_clone.stack.length == 1
    to_clone = to_clone.stack.pop
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










