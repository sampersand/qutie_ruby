require_relative 'functions' # for global print
class Universe

  attr_accessor :stack
  attr_accessor :locals
  attr_accessor :globals
  attr_accessor :program_stack

  def self.from_string(input)
    new(stack: input.each_char.to_a)
  end

  def initialize(stack: nil, locals: nil, globals: nil, program_stack: nil, add_to_stack: true)
    @stack = stack || []
    @locals = locals || {}
    @globals = globals || {}
    @program_stack = program_stack || []
    @program_stack += [self] if add_to_stack
  end

  # repr
    def inspect        
      "<#{@stack}|{#{@locals.keys.to_s[1...-1]}}|{#{globals_s}}>"
    end
    alias :to_s :inspect

    def globals_s
      @globals.reject{ |k, v| v.respond_to?(:to_s?) && !v.to_s? }.keys.to_s[1...-1]
    end

  # misc
    def spawn_frame
      self.class.new(program_stack: @program_stack, globals: @globals.clone.update(@locals))
    end

    def new_stack(stack)
      self.class.new(program_stack: @program_stack, stack: stack, locals: @locals, globals: @globals, add_to_stack: false)
    end

    def clone
      self.class.new(program_stack: @program_stack, #we dont need to copy this
                     stack: @stack.clone,
                     locals: @locals.clone,
                     globals: @globals.clone,
                     add_to_stack: false)
    end

  #stream methods

    def next!(amnt=nil)
      return next!(amnt.length) if amnt.is_a?(String)
      throw :EOF if @stack.empty?
      return @stack.shift unless amnt
      @stack.shift(amnt).join
    end

    def peek(amnt=nil)
      throw :EOF if @stack.empty?
      return @stack.first unless amnt
      @stack.first(amnt).join
    end

    def peek?(*vals, len: nil)
      vals.any? do |val|
        if val.is_a?(Regexp)
          self.peek(len || val.source.length) =~ val 
        else
          self.peek(len || val.length) == val
        end
      end
    end

    def push!(val)
      @stack.push val
    end

    alias :<< :push!

    def pop!
      @stack.pop
    end

    def stream_empty?
      @stack.empty?
    end

    def get(val)
      @locals.include?(val) ? @locals[val] : @globals[val]
    end
end









