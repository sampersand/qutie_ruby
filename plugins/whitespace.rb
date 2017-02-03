module Whitespace
  module_function

  def parse(stream, tokens, parser)
    if stream.peek =~ /\s/
      stream.next # and ignore
      :retry
    end
  end

end