require_relative 'number'
module Number

  BASES = {
    :b => [ QT_Regex.new( /[01]/     ), QT_Number.new( 2  ) ],
    :d => [ QT_Regex.new( /\d/       ), QT_Number.new( 10 ) ],
    :o => [ QT_Regex.new( /[0-7]/    ), QT_Number.new( 8  ) ],
    :x => [ QT_Regex.new( /[\da-f]/i ), QT_Number.new( 16 ) ],
  }

  DECIMAL_REGEX          = BASES[:d][0]
  BASE_START_REGEX       = QT_Regex.new( /0(?:#{BASES.keys.join('|')})/i                        )
  DECIMAL_POINT          = QT_Regex.new( /\./                                                   )
  EXPONENT_START         = QT_Regex.new( /e/i                                                   )
  EXPONENT_SIGN_MODIFIER = QT_Regex.new( /[+-]/                                                 )
  DECIMAL_POINT_REGEX   =  QT_Regex.new( /#{DECIMAL_POINT.regex_val}#{DECIMAL_REGEX.regex_val}/ )

  module_function

  def next_number!(stream:)
    res = stream._next
    catch(:EOF) do
      res += stream._next while DECIMAL_REGEX =~ stream._peek
      if stream.qt_length(type: :STACK) > 1 && # this will fail when I upgrade it to QT_Number
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
    raise unless stream._next.text_val == '0' #too lazy to do a real comparison
    base_regex, base = BASES[stream._next.source_val]
    res = QT_Default::from( '' )
    catch(:EOF) do
      res += stream._next while base_regex =~ stream._peek
    end
    raise "No digits following based number `#{res}`" if res.source_val.empty?
    QT_Number::from( res, base: base )
  end

  def next_token!(stream:,  **_)
    return unless stream._peek =~ DECIMAL_REGEX

    if BASE_START_REGEX =~ stream._peek(2)
      next_base!(stream: stream)
    else
      next_number!(stream: stream)
    end
  end

  def handle(token:, universe:, **_)
    universe << token
  end

end






