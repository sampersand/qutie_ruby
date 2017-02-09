module Keyword
  module_function

  def handle_get_known(_, universe, _)
    to_get = universe.pop!
    # if to_get == :'$'
    #   universe << universe.spawn_new_stack(new_stack: universe.program_stack)
    # else
      universe << universe.get(to_get)
    # end
  end

  def handle_eval_univ(_, universe, parser)
    last = universe.pop!
    if last == nil || last == false
      universe << last
    else
      # this isn't parse! cause i dont want it being destroyed each time we read it
      universe << parser.parse(stream: last, universe: universe.spawn_new_stack(new_stack: nil).clone)
    end
  end

  # def handle_pop_lastv(_stream, universe, parser)
  #   handle_eval_univ(_stream, universe, parser)
  #   universe << universe.pop!.pop!
  # end

  def next_token!(stream, _, _)
    res = KEYWORDS.find{ |val, _| stream.peek?(str: val) }
    res and stream.next(amnt: res[0].length)
  end

  def handle(token, stream, universe, parser)
    KEYWORDS[token].(stream, universe, parser)
  end

  KEYWORDS = {
    '?' => method(:handle_get_known),
    '!' => method(:handle_eval_univ),
    # '$' => method(:handle_pop_lastv),
  }

end