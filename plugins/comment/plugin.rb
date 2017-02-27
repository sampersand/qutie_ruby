module Comment
  module_function

  SINGLE_START_HASH = QT_Regex.new( /#/ )
  SINGLE_START_SLASH = QT_Regex.new( /\/{2}/ )
  SINGLE_END = QT_Regex.new( /\n/ )

  def next_single!(env) # this will break if somehow SINGLE_STARTS includes single_end
    stream = env.stream
    return unless SINGLE_START_HASH._match?( stream._peek(env), env) ||  
                 SINGLE_START_SLASH._match?( stream._peek(env, 2), env)
    stream._next(env) until SINGLE_END._match?( stream._peek(env), env)
    stream._next(env) # and ignore
    :retry
  end
  
  MULTI_LINE_START = QT_Regex.new( /\/\*/ )
  MULTI_LINE_END = QT_Regex.new( /\*\// ) 
  def next_multi!(env)
    stream = env.stream
    return unless MULTI_LINE_START._match?(stream._peek(env, 2), env)
    stream._next(env) until MULTI_LINE_END._match?(stream._peek(env, 2), env)
    stream._next(env, 2) # and ignore
    :retry
  end

  def next_token(env)
    next_single!(env) || next_multi!(env)
  end
end










