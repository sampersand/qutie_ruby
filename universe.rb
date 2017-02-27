class UniverseOLD

  attr_accessor :stack
  attr_accessor :locals
  attr_accessor :globals
  
  def initialize(stack: nil, locals: nil, globals: nil)
    @stack = stack || []
    @locals = locals || {}
    @globals = globals || {}
  end


  #stream methods

    def next(amnt: 1, env:)
      warn("Asking for `#{amnt.inspect}` elements") unless amnt.is_a?(Integer) && amnt != 0
      throw :EOF if stack_empty?(env)
      return @stack.shift if amnt == 1
      @stack.shift(amnt).reduce{ |a, b| a.qt_add(b, env) }
    end

    def peek(amnt: 1, env:)
      warn("Asking for `#{amnt.inspect}` elements") unless amnt.is_a?(Integer) && amnt != 0
      throw :EOF if stack_empty?(env)
      return @stack.first if amnt == 1
      @stack.first(amnt).reduce{ |a, b| a.qt_add(b, env) }
    end

  # stack
    def stack_empty?(_env)
      @stack.empty?
    end

    def <<(val) # used to be push! but that's removed
      @stack.push val
    end

    def pop
      @stack.pop
    end

  # locals
    def reduced_locals
      @locals.reject{|k, v| k.is_a?(QT_Symbol) && k.sym_val.to_s.start_with?('__')}
    end

    def locals_empty?
      @locals.empty?
    end
    def reduced_locals_empty?
      reduced_locals.empty?
    end

  # locals, globals, and stack
    def [](key)
      stack_incl = @stack.include?(key)
      locals_incl = @locals.include?(key)
      globals_incl = @globals.include?(key)
      STDERR.puts("Both locals and stack respond to `#{key.inspect}`!") if locals_incl && stack_incl
      if locals_incl
        @locals[key] || QT_Null::INSTANCE
      elsif stack_incl
        @stack[key] || QT_Null::INSTANCE
      elsif globals_incl
        @globals[key] || QT_Null::INSTANCE
      else
        # STDERR.puts("Neither Locals, Globals, nor Stack respond to `#{key.inspect}`")
        QT_Null::INSTANCE
      end
    end
    def qt_get(pos, _env, type: QT_Symbol.new( :BOTH )) #ignores type
      return QT_Universe.new(body: '', universe: _env.universe, parens: ['<', '>']) if pos == QT_Symbol.new( :'$' )
      self[pos] || QT_Null::INSTANCE
    end
    def qt_set(pos, val, _env, type: QT_Symbol.new( :BOTH )) #ignores type
      self.locals[pos] = val
    end

  # repr
    def inspect        
      "#{self.class.name}(stack: #{@stack}, locals: #{@locals})"
    end

    def stack_s
      stck = @stack.collect{|e| self.equal?(e.respond_to?(:universe) ? e.universe : e) ? QT_Symbol.new( :'$' ) : e }
      stck.collect(&:to_s).join(', ').dump[1...-1]
    end

    def locals_s
      reduced_locals.collect{|k, v| [k, (self.equal?(v.respond_to?(:universe) ? v.universe : v) ? QT_Symbol.new( :'$' ) : v )]}
                      .collect{|k,v| "#{k}: #{v}"}.join(', ')
    end

    def to_s(parens=['<', '>'])
      parens[0] +(if reduced_locals_empty?
                    stack_s
                  elsif stack_empty?(nil)
                    locals_s
                  else
                    " [#{stack_s}] | {#{locals_s}} "
                  end) + parens[1]
    end

  # cloning
    def spawn_new_stack(new_stack:)
      self.class.new(stack: new_stack,
                     locals: @locals,
                     globals: @globals)
    end

    def clone
      self.class.new(stack: @stack.clone,
                     locals: @locals.clone,
                     globals: @globals.clone)
    end


  def qt_length(_env, type:)
    case type.sym_val
    when :STACK then @stack.length
    when :LOCALS then @locals.length
    when :GLOBALS then @globals.length
    end
  end

  def _peek(env, amnt=1)
    peek(amnt: amnt, env: env)
  end
  def _next(env, amnt=1)
    self.next(amnt: amnt, env: env)
  end
  def _stackeach(_env)
    @stack.each
  end

  def _append(val, env)
    @stack << val
  end
  def ==(other)
    @stack == other.stack && @locals == other.locals
  end
end