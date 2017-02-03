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
      # "<#{@stack} | #{@locals} | #{@globals}>"
      "<#{@stack},#{@locals}>"
    end

    def to_s
      stack_s = @stack.collect(&:to_s).join(', ')
      locals_s = @locals.collect{|k, v| "#{k}: #{v}"}.join(', ')
      # globals_s = @globals.collect{|k, v| "#{k}: #{v}"}.join(', ')
      globals_s = @globals.length.to_s#collect{|k, v| "#{k}: #{v}"}.join(', ')
      "< [#{stack_s}]|{#{locals_s}}|{#{globals_s}} >"
    end

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

    def feed(*vals)
      @stack.unshift(*vals)
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










