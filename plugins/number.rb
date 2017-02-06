module Number
  module_function

  def next_base!(stream)
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
  def next_int!(stream)
    return unless stream.peek?(/\d/, len: 1)
    num = ''
    catch(:EOF){
      num += stream.next! while stream.peek?(/\d/, len: 1)
    }
    num
  end

  def next_float!(stream)
    start = next_int!(stream) or return
    catch(:EOF){
      return start unless stream.peek?('.')
      return start + stream.next! + next_int!(stream) || '0'
    }
    return start

  end

  def next_token!(stream, _, _)
     next_base!(stream) || next_float!(stream)
  end
  def handle(token, _, universe, _)
    universe << (token.include?('.') ? token.to_f : token.to_i)
  end

end