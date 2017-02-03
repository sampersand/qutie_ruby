module Escape
  module_function

  def parse(stream, tokens, parser)
    if stream.peek =~ /\\/
      stream.next #pop current one
      tokens.push stream.next # and ignore
    end
  end

end