class Universe

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
      @stack.shift(amnt).join
    end

    def peek(amnt: 1)
      warn("Asking for `#{amnt.inspect}` elements") unless amnt.is_a?(Integer) && amnt != 0
      throw :EOF if stack_empty?
      @stack.first(amnt).join
    end

    def peek?(str:)
      peek(amnt: str.length ) == str
    end

    def peek_any?(vals:)
      vals.any?{ |val| peek?(str: val) }
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
    def locals_empty?
      @locals.empty?
    end

  # All
    def [](val)
      if @local
      @locals.include?(val) ? @locals[val] : @globals[val]
    end

  # repr
    def inspect        
      "#{self.class.name}(stack: #{@stack}, locals: #{@locals})"
    end

    def to_s
      if locals_empty?
        "[#{@stack.collect(&:to_s).join}]"
      elsif stack_empty?
        "{#{@locals.collect{|k,v| "#{k}: #{v}"}.join(', ')}"
      else
        '()'
      end
    end

  # misc
    def spawn_frame
      self.class.new(globals: @globals.clone.update(@locals))
    end

    def spawn_new_stack(new_stack:)
      self.class.new(stack: new_stack, locals: @locals, globals: @globals)
    end

    def clone
      self.class.new(stack: @stack.clone,
                     locals: @locals.clone,
                     globals: @globals.clone)
    end
end







