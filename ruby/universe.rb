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
    def next!(amnt)
      return next!(amnt.length) if amnt.is_a?(String)
      throw :EOF if stack_empty?
      @stack.shift(amnt).join
    end

    def peek(amnt) # deprecated
      warn('Universe.peek is depreciated!')
      peek?(/./, len: 1)
    end

    def peek?(*vals, len: nil)
      throw :EOF, [-1] if @stack.empty?
      vals.any? do |val|
        if val.is_a?(Regexp)
          @stack.first(len || val.source.length).join =~ val 
        else
          @stack.first(len || val.length).join == val
        end
      end
    end

  # stack
    def stack_empty?
      @stack.empty?
    end

  # locals
    def locals_empty?
      @locals.empty?
    end

  # repr
    def inspect        
      # "<#{@stack}|{#{locals_s}}|{#{globals_s}}>"
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

    def push!(val)
      @stack.push val
    end

    alias :<< :push!

    def pop!
      @stack.pop
    end

    def get(val)
      @locals.include?(val) ? @locals[val] : @globals[val]
    end
end







