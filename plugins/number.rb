module Number
  module_function

  def parse(stream, _, _)
    return unless stream.peek =~ /\d/
    num = ''
    catch(:EOF) do
      num += stream.next while stream.peek =~ /\d/
    end
    num
  end

  def handle(token, _, universe, _)
    universe << token.to_i
  end

end





















