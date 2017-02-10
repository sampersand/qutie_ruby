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

    def next(amnt: 1)
      warn("Asking for `#{amnt.inspect}` elements") unless amnt.is_a?(Integer) && amnt != 0
      throw :EOF if stack_empty?
      return @stack.shift if amnt == 1
      @stack.shift(amnt).join
    end

    def peek(amnt: 1)
      warn("Asking for `#{amnt.inspect}` elements") unless amnt.is_a?(Integer) && amnt != 0
      throw :EOF if stack_empty?
      return @stack.first if amnt == 1
      QT_Text.new( @stack.first(amnt).collect(&:text_val).join ) # assumes all of them are QT_Texts
    end

  # stack
    def stack_empty?
      @stack.empty?
    end

    def <<(val) # used to be push! but that's removed
      @stack.push val
    end

    def pop
      @stack.pop
    end

  # locals
    def shortened_locals
      @locals.reject{|k, v| k.is_a?(QT_Variable) && k.var_val.to_s.start_with?('__')}
    end

    def locals_empty?
      @locals.empty?
    end
    def shortened_locals_empty?
      shortened_locals.empty?
    end

  # locals, globals, and stack
    def [](val)
      stack_incl = @stack.include?(val)
      locals_incl = @locals.include?(val)
      globals_incl = @globals.include?(val)
      STDERR.puts("Both locals and stack respond to `#{val.inspect}`!") if locals_incl && stack_incl
      if locals_incl
        @locals[val]
      elsif stack_incl
        @stack[val]
      elsif globals_incl
        @globals[val]
      else
        # STDERR.puts("Neither Locals, Globals, nor Stack respond to `#{val.inspect}`")
        QT_Null::INSTANCE
      end
    end
    def qt_get(pos:, type: :BOTH) #ignores type
      self[pos]
    end

  # repr
    def inspect        
      "#{self.class.name}(stack: #{@stack}, locals: #{@locals})"
    end

    def stack_s
      "[#{@stack.collect(&:to_s).join(', ')}]"
    end

    def locals_s
      "{ " + shortened_locals.collect{|k,v| "#{k}: #{v}"}.join(', ') + " }"
    end

    def to_s
      if shortened_locals_empty?
        stack_s
      elsif stack_empty?
        locals_s
      # elsif shortened_locals_empty? && !stack_empty?
      else
        "< #{stack_s} | #{locals_s} >"
      #   '()'
      end
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


  def qt_throw(err:, **kw)
    throw err, kw
  end

  def qt_length(type:)
    case type
    when :STACK then @stack.length
    when :LOCALS then @locals.length
    when :GLOBALS then @globals.length
    end
  end

  def qt_peek(amnt)
    peek(amnt: amnt.num_val.to_i)
  end
  def qt_next(amnt)
    self.next(amnt: amnt.num_val.to_i)
  end

end







