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

  def next_number!(env)
    stream = env.stream
    res = stream._next(env)
    catch(:EOF) do
      res = res.qt_add( stream._next(env), env) while DECIMAL_REGEX._match?(stream._peek(env), env)
      if stream.qt_length(env, type: QT_Variable.new( :STACK ) ) > 1 && # this will fail when I upgrade it to QT_Number
          DECIMAL_POINT_REGEX._match?(stream._peek(env, 2), env)
        res = res.qt_add( stream._next(env), env)
        res = res.qt_add( stream._next(env), env) while DECIMAL_REGEX._match?( stream._peek(env), env )
      end
      if stream.qt_length(env, type: QT_Variable.new( :STACK ) ) > 0 && EXPONENT_START._match?( stream._peek(env), env )
        res = res.qt_add( stream._next(env), env)
        res = res.qt_add( stream._next(env), env) if EXPONENT_SIGN_MODIFIER._match?( stream._peek(env), env )
        res = res.qt_add( stream._next(env), env) while DECIMAL_REGEX._match?( stream._peek(env), env )
      end
    end
    QT_Number::from( res, env )
  end

  def next_base!(env)
    stream = env.stream
    raise unless stream._next(env).text_val == '0' #too lazy to do a real comparison
    base = stream._next(env)
    base_regex = BASES[base.source_val][0]
    res = QT_Default::from( '', env )
    catch(:EOF) do
      res = res.qt_add( stream._next(env), env) while base_regex._match?(stream._peek(env), env)
    end
    raise "No digits following based number `#{res}`" if res.source_val.empty?
    QT_Number::from( res, env, base: base )
  end

  def next_token!(env)
    return unless DECIMAL_REGEX._match?(env.stream._peek(env), env)

    if BASE_START_REGEX._match?(env.stream._peek(env, 2), env)
      next_base!(env)
    else
      next_number!(env)
    end
  end

  def handle(token, env)
    env.universe << token
  end

end






