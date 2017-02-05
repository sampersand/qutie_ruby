module Number
  module_function

  NUMBER_START = /\d/
  NUMBER_CONT = /\d/
  def next_token!(stream, _, _)
    return unless stream.peek?(NUMBER_START, 1)
    num = ''
    catch(:EOF){
      num += stream.next!(1) while stream.peek?(NUMBER_CONT, 1)
    }
    num
  end

  def handle(token, _, universe, _)
    universe << token.to_i
  end

end