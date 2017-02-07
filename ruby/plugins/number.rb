module Number
  module_function

  def next_base!(stream, _, _)
    return unless stream.peek?(/0[oxdb]/i, len: 2)
    res = stream.next!(2)
    case res[1]
    when 'b' then res += stream.next! while stream.peek?(/[01]/, len: 1)
    when 'o' then res += stream.next! while stream.peek?(/[0-7]/, len: 1)
    when 'd' then res += stream.next! while stream.peek?(/[0-9]/, len: 1)
    when 'x' then res += stream.next! while stream.peek?(/[0-9A-F]/i, len: 1)
    else raise "Unknown base `#{res}`"
    end
    res
  end
  def next_int!(stream, universe, parser)
    return unless stream.peek?(/\d/, len: 1)
    num = ''
    parser.catch_EOF(universe) {
      num += stream.next! while stream.peek?(/\d/, len: 1)
      nil
    }
    num
  end

  def next_float!(stream, universe, parser)
    start = next_int!(stream, universe, parser) or return
    parser.catch_EOF(universe) {
      return start unless stream.peek?('.')
      return start + stream.next! + next_int!(stream, universe, parser) || '0'
      nil
    }
    start

  end

  def next_token!(stream, universe, parser)
     next_base!(stream, universe, parser) || next_float!(stream, universe, parser)
  end
  def handle(token, _, universe, _)
    universe << (token.include?('.') ? token.to_f : token.to_i)
  end

end