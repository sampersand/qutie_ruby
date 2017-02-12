class QT_Universe < QT_Object

  attr_reader :universe
  attr_reader :body
  attr_reader :parens

  def self.from(source:, current_universe:, parens:, __starting_line_no: )
    # warn("QT_Universe::from doesnt conform to others!")
    new_universe = UniverseOLD.new
    new_universe.stack = source.source_val.to_s.each_char.collect{ |c| QT_Default::from(c) }
    # new_universe.locals = current_universe.locals
    # new_universe.globals = current_universe.globals
    new(body: source, universe: new_universe, parens: parens, __starting_line_no: __starting_line_no)
  end

  def initialize(body:, universe:, parens:, __starting_line_no: -1)
    @body = body
    @parens = parens
    @universe = universe
    @__starting_line_no = __starting_line_no
  end

  def to_s
    # "#{@parens[0]} ... #{@parens[1]}"
    # @body
    @universe.to_s 
  end
  def inspect_to_s
    "line: #{@__starting_line_no}, #{@universe}"
  end

  def clone
    self.class.new(body: @body.clone,
                   universe: @universe.clone,
                   parens: @parens.clone)
  end

  def method_missing(meth, *a)
    @universe.method(meth).call(*a)
  end

  # qt methods
    # methods
      # def qt_method(meth:)
      #   # this method is deprecated for now
      #   case meth
      #   when :append then proc{|args|
      #     @universe.stack << args.stack[0]
      #   }
      #   else qt_get(QT_Variable::from(source: '__' + meth.to_s), type: :LOCALS)#fail "Unknown method `#{meth}`"
      #   end
      # end
    # conversion
      def qt_to_bool
        QT_Boolean::get(@universe.stack_empty? && @universe.shortened_locals_empty?)
      end


    def qt_eval(universe, _stream, parser)
      universe = universe.spawn_new_stack(new_stack: nil).clone
      res = parser.parse!(stream: @universe.clone, universe: universe)
      QT_Universe.new(body: '', universe: res, parens: ['<', '>']) # this is where it gets hacky
    end

    def qt_call(args, universe, _stream, parser) # fix this
      raise "Args have to be a universe, not `#{args.class}`" unless args.is_a?(QT_Universe)
      passed_args = args.clone
      passed_args.globals.update(passed_args.locals)
      passed_args.locals.clear
      # passed_args.stack.clear
      passed_args.locals[QT_Variable.new :__args ] = args
      # func.program_stack.push args
      parser.parse!(stream: @universe.clone, universe: passed_args)
      # func.program_stack.pop
    end
    def qt_get(pos, type:)  # fix this
      return self if pos == QT_Variable.new( :'$' )
      case type
      when :BOTH then type = @universe.locals.include?(pos) ? :LOCALS : :STACK
      when :NON_STACK then type = @universe.locals.include?(pos) ? :LOCALS : :GLOBALS
      end

      case type 
      when :STACK then @universe.stack[(pos.qt_to_num or return QT_Null::INSTANCE).num_val] or QT_Null::INSTANCE
      when :LOCALS then @universe.locals[pos] or QT_Null::INSTANCE
      when :GLOBALS then @universe.globals[pos] or QT_Null::INSTANCE
      else fail "Unknown qt_get type `#{type}`!"
      end
    end
    def qt_del(pos:, type:)
      if type == :BOTH
        if @universe.locals.include?(pos)
          type = :LOCALS
        else
          type = :STACK
        end
      end
      case type 
      when :STACK then @universe.stack.delete((pos.qt_to_num or return QT_Null::INSTANCE).num_val)
      when :LOCALS then @universe.locals.delete(pos)
      when :GLOBALS then @universe.globals.delete(pos)
      else fail "Unknown qt_get type `#{type}`!"
      end
      QT_Null::INSTANCE
    end


    def qt_throw(err:, **kw)
      throw err, **kw
    end
end

























