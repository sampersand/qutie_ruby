class Universe

  attr_reader :stack
  attr_reader :locals
  attr_reader :globals

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
      "<#{@stack}|{#{@locals.keys.to_s[1...-1]}}|{#{globals.keys.to_s[1...-1]}}>"
    end
    alias :to_s :inspect

  # misc
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

    def next(amnt=nil)
      throw :EOF if @stack.empty?
      return @stack.shift unless amnt
      @stack.shift(amnt).join
    end

    def peek(amnt=nil)
      throw :EOF if @stack.empty?
      return @stack.first unless amnt
      @stack.first(amnt).join
    end

    def peek?(val)
      peek(val.length) == val
    end

    def feed(val)
      val.each_char(&@stack.method(:unshift))
    end

    def push(val)
      @stack.push val
    end

    alias :<< :push

    def pop
      @stack.pop
    end

    def get(val)
      @locals.include?(val) ? @locals[val] : @globals[val]
    end
end









