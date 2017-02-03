module Whitespace
  module_function
  def parse(stream, _, _)
    if stream.peek =~ /\s/
      stream.next # and ignore
      :retry
    end
  end
  
end