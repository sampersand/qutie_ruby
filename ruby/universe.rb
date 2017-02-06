require_relative 'functions' # for global print
class Universe

  attr_accessor :stack
  attr_accessor :locals
  attr_accessor :globals

  
  Universe::PROGRAM_STACK = []

  def self.from_string(input)
    new(stack: input.each_char.to_a)
  end

  def initialize(stack: nil, locals: nil, globals: nil)
    self.class::PROGRAM_STACK[0] = self if self.class::PROGRAM_STACK.empty?
    @stack = stack || []
    @locals = locals || {}
    @globals = globals || {}
  end

  def program_stack
    self.class::PROGRAM_STACK
  end

  # repr
    def inspect        
      "<#{@stack}|{#{locals_s}}|{#{globals_s}}>"
    end
    alias :to_s :inspect

    def globals_s
      @globals.reject{ |k, v| v.respond_to?(:to_s?) && !v.to_s? || k[0..1]=='__'}.keys.to_s[1...-1]
    end
    def locals_s
      @locals.reject{ |k, v| v.respond_to?(:to_s?) && !v.to_s? || k[0..1]=='__'}.keys.to_s[1...-1]
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