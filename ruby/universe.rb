require_relative 'functions' # for global print
class Universe

  attr_accessor :stack
  attr_accessor :locals
  attr_accessor :globals

  def self.from_string(input)
    new(stack: input.each_char.to_a)
  end

  def initialize(stack: nil, locals: nil, globals: nil)
    @stack = stack || []
    @locals = locals || {}
    @globals = globals || {}
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
    def to_globals!
      self.class.new(globals: @globals.update(@locals))
    end
    def to_globals
      self.class.new(globals: @globals.clone.update(@locals))
    end

    def knowns_only
      self.class.new(locals: @locals, globals: @globals)
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
      return self if val == :__current
      @locals.include?(val) ? @locals[val] : @globals[val]
    end
end









