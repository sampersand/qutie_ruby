module Keyword
  module_function

  POP_STACK = '$'
  GET_KNOWN = '?'
  UNPACK_TOKENS = '!'
  # GET_LAST = '!'

  def parse_known(stream, tokens, parser)
    return unless stream.peek(GET_KNOWN.length) == GET_KNOWN
    stream.next(GET_KNOWN.length) # and throw it away
    tokens.push tokens.knowns[tokens.pop]
    true
  end
  def parse_pop(stream, tokens, parser)
    return unless stream.peek(POP_STACK.length) == POP_STACK
    stream.next(POP_STACK.length) # and throw it away
    tokens.pop # and throw it away
    :retry
  end
  def parse_unpack(stream, tokens, parser, override=false)
    unless override
      return unless stream.peek(UNPACK_TOKENS.length) == UNPACK_TOKENS
      stream.next(UNPACK_TOKENS.length) # and throw it away
    end
    to_unpack = (tokens.pop + ["\n"]).to_stream
    result = parser.parse(to_unpack, tokens.clone_knowns)
    tokens.push result
    true
  end
  # def parse_last(stream, tokens, parser)
  #   return unless stream.peek(GET_LAST.length) == GET_LAST
  #   stream.next(GET_LAST.length)
  #   parse_unpack(stream, tokens, parser, true)
  #   tokens.push tokens.pop.last
  #   true
  # end

  def parse(stream, tokens, parser)
    parse_known(stream, tokens, parser) || 
    parse_pop(stream, tokens, parser)   ||
    parse_unpack(stream, tokens, parser)
    # parse_last(stream, tokens, parser)
  end

end










