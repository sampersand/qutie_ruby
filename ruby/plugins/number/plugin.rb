require_relative 'number'
module Number

  BASES = {
    'b' => [/[01]/, 2],
    'd' => [/[[:digit:]]/, 10],
    'o' => [/[0-7]/, 8],
    'x' => [/[[:xdigit:]]/, 16],
  }

  BASE_START_REGEX = /0(?:#{BASES.keys.join('|')})/i
  DECIMAL_POINT = /\./
  DECIMAL_REGEX = BASES['d'][0]
  DECIMAL_POINT_REGEX = /#{DECIMAL_POINT}#{DECIMAL_REGEX}/
  module_function

  def next_number!(stream:)
    res = ''
    catch(:EOF) do
      res += stream.next while stream.peek =~ DECIMAL_REGEX
      if stream.qt_length(type: :STACK) >= 2 && stream.peek(amnt: 2) =~ DECIMAL_POINT_REGEX
        res += stream.next
        res += stream.next while stream.peek =~ DECIMAL_REGEX
      end
    end
    fail if res.empty?
    res
  end

  def next_base!(stream:)
    res = ''
    catch(:EOF) do
      res = stream.next(amnt: 2) 
      fail unless res =~ BASE_START_REGEX
      base_regex = BASES[res[1]][0]
      res += stream.next while stream.peek =~ base_regex
    end
    fail unless res.length >= 2
    raise "No digits following based number `#{res}`" unless res.length > 2
    res
  end

  def next_token!(stream:,  **_)
    return unless stream.peek =~ DECIMAL_REGEX

    if stream.peek(amnt: 2) =~ BASE_START_REGEX
      next_base!(stream: stream)
    else
      next_number!(stream: stream)
    end
  end

  # def next_token!(stream:,  **_)
  #   return unless stream.peek =~ /\d/
  #   num = ''
  #   catch(:EOF) do
  #     num += stream.next while stream.peek =~ /\d/
  #     if stream.peek(amnt: 2) =~ /\.\d/
  #       num += stream.next(amnt: 2)
  #       num += stream.next while stream.peek =~ /\d/
  #     end
  #   end
  #   num
  # end

  def handle(token:, universe:, **_)
    universe << QT_Number::from(source: token)
  end

end

