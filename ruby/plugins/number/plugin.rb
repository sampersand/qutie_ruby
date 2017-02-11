require_relative 'number'
module Number

  BASES = {
    'b' => [QT_Regex.new( /[01]/     ), 2 ],
    'd' => [QT_Regex.new( /\d/       ), 10],
    'o' => [QT_Regex.new( /[0-7]/    ), 8 ],
    'x' => [QT_Regex.new( /[\da-f]/i ), 16],
  }

  DECIMAL_REGEX          = BASES['d'][0]
  BASE_START_REGEX       = QT_Regex.new( /0(?:#{BASES.keys.join('|')})/i    )
  DECIMAL_POINT          = QT_Regex.new( /\./                               )
  EXPONENT_START         = QT_Regex.new( /e/i                               )
  EXPONENT_SIGN_MODIFIER = QT_Regex.new( /[+-]/                             )
  DECIMAL_POINT_REGEX   =  QT_Regex.new( /#{DECIMAL_POINT.regex_val}#{DECIMAL_REGEX.regex_val}/ )
  module_function

  def next_number!(stream:)
    res = stream._next
    catch(:EOF) do
      res += stream._next while DECIMAL_REGEX =~ stream._peek
      if stream.qt_length(type: :STACK) > 1 && # this will fail
          DECIMAL_POINT_REGEX =~ stream._peek(2)
        res += stream._next
        res += stream._next while DECIMAL_REGEX =~ stream._peek
      end
      if stream.qt_length(type: :STACK) > 0 && EXPONENT_START =~ stream._peek
        res += stream._next
        res += stream._next if stream._peek =~ EXPONENT_SIGN_MODIFIER
        res += stream._next while DECIMAL_REGEX =~ stream._peek
      end
    end
    QT_Number::from( res )
  end

  def next_base!(stream:)
    res = ''
    catch(:EOF) do
      res = stream._next(2) 
      fail unless res =~ BASE_START_REGEX
      base_regex = BASES[res[1]][0]
      res += stream._next while stream.peek =~ base_regex
    end
    fail unless res.length >= 2
    raise "No digits following based number `#{res}`" unless res.length > 2
    res
  end

  def next_token!(stream:,  **_)
    return unless stream._peek =~ DECIMAL_REGEX

    # if stream._peek(amnt: 2) =~ BASE_START_REGEX
    #   next_base!(stream: stream)
    # else
      next_number!(stream: stream)
    # end
  end

  def handle(token:, universe:, **_)
    universe << token
  end

end






