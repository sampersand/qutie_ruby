class QT_Universe < QT_Object

  attr_reader :universe
  attr_reader :body
  attr_reader :parens
  attr_accessor :__start_line_no 
  def self.from(source, env, parens:)
    # warn("QT_Universe::from doesnt conform to others!")
    new_universe = UniverseOLD.new
    new_universe.stack = source.source_val.to_s.each_char.collect{ |c| QT_Default::from(c, env) }
    # new_universe.locals = current_universe.locals
    # new_universe.globals = current_universe.globals
    new(body: source, universe: new_universe, parens: parens)
  end

  def initialize(body:, universe:, parens:)
    @body = body
    @parens = parens
    @universe = universe
    fail unless @universe.is_a?(UniverseOLD)
    @__start_line_no = 0
  end

  def to_s
    "#{@parens[0]} ... #{@parens[1]}"
    # @body
    @universe.to_s(@parens.collect(&:to_s))
  end
  def inspect_to_s
    "line: #{@__start_line_no}, #{@universe}"
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
      def qt_method(meth, args, env)
        # text_func = qt_get(QT_Variable.new( meth ), env, type: QT_Variable.new( :LOCALS ) )
        uni_meth = @universe.locals[QT_Variable.new( meth )] || QT_Null::INSTANCE
        return super if uni_meth._nil?
        uni = @universe.clone
        uni.globals.update(uni.locals)
        uni.stack.clear
        uni.locals.clear
        uni.qt_set( QT_Variable.new( :__self ), self, env, type: QT_Variable.new( :LOCALS ) )
        args.locals.each{ |k, v| uni.qt_set(k, v, env, type: QT_Variable.new( :LOCALS) ) }
        args.stack.each{ |v| uni._append(v, env) }
        args = self.class.new(body: '', universe: uni , parens: ['{', '}'])
        # uni_meth.qt_call(args, env).qt_get( QT_Number::NEG_1, env, type: QT_Variable.new( :STACK  ) )
        raise "Args have to be a universe, not `#{args.class}`" unless args.is_a?(QT_Universe)
        args.globals.update(args.locals)
        args.locals.clear
        args.locals[ QT_Variable.new :__args ] = args
        stream = @universe.clone
        env.parser.parse!(env.fork(stream: stream, universe: args)).u.qt_get(QT_Number::NEG_1, env, type: QT_Variable.new( :STACK ))
      end

      def __uni_method(meth, var, var_name, env)
        res=qt_method(meth,UniverseOLD.new(stack:[var],locals:{QT_Variable.new(var_name)=>var}),env)
        res._missing? ? nil : res
      end

      def qt_to_text(env)
        res = qt_method(:__text, UniverseOLD.new, env)
        return super if res._missing?
        throw(:ERROR, QTE_Type.new(env, " `__text` returned a non-QT_Text value! `#{res}`")) unless res.is_a?(QT_Text)
        res
      end
      def qt_to_num(env)
        res = qt_method(:__num, UniverseOLD.new, env)
        return super if res._missing?
        throw(:ERROR, QTE_Type.new(env, " `__num` returned a non-QT_Number value! `#{res}`")) unless res.is_a?(QT_Number)
        res
      end
      def qt_to_bool(env)
        res = qt_method(:__bool, UniverseOLD.new, env)
        return QT_Boolean::get(!@universe.stack_empty?(env) || !@universe.reduced_locals_empty?) if res._missing?
        throw(:ERROR, QTE_Type.new(env, " `__bool` returned a non-QT_Boolean value `#{res}`")) unless res.is_a?(QT_Boolean)
        res
      end
      def qt_length(env, type:)
        res = qt_method(:__len, UniverseOLD.new, env)
        if res._missing?
          return QT_Number.new( (case type.var_val.upcase
                                 when :GLOBALS then @universe.globals.length
                                 when :LOCALS then @universe.reduced_locals.length
                                 when :STACK then @universe.stack.length
                                 when :BOTH
                                   lcls = @universe.reduced_locals.length
                                   stck = @universe.stack.length
                                   raise "Both Locals (#{lcls}) and Stack (#{stck}) have a length!" if (lcls != 0) && (stck != 0)
                                  lcls == 0 ? stck : lcls
                                 else raise "unknown length type `#{type.inspect}`"
                                 end or begin
                                   puts "Error: `#{a.inspect}` doesn't repsond to type param `#{type.inspect}`"
                                   exit(1)
                                 end)
                                )
        end

        throw(:ERROR, QTE_Type.new(env, " `__bool` returned a non-QT_Number value `#{res}`")) unless res.is_a?(QT_Number)
        res
      end

    # normal universe methods
      def qt_eval(env)
        universe = env.universe.spawn_new_stack(new_stack: nil)#.clone #removed the .clone here
        res = env.parser.parse!(env.fork(stream: @universe.clone, universe: universe)).u
        QT_Universe.new(body: '', universe: res, parens: @parens) # this is where it gets hacky
      end

      def qt_call(args, env) # fix this
        raise "Args have to be a universe, not `#{args.class}`" unless args.is_a?(QT_Universe)
        args = args.qt_eval(env.clone)
        args.globals.update(args.locals)
        args.locals.clear
        args.locals[ QT_Variable.new :__args ] = args
        stream = @universe.clone
        env.parser.parse!(env.fork(stream: stream, universe: args)).u
        # func.program_stack.push args
        # $QT_CONTEXT.start(stream, self)
        # $QT_CONTEXT.stop(stream)
        # func.program_stack.pop
      end

      def qt_get(pos, env, type:)  # fix this
        # res = qt_method(:__get, UniverseOLD.new(stack:[pos],locals:{QT_Variable.new(:type)=>type}), env)
        # return res unless res._missing?
        return self if pos == QT_Variable.new( :'$' )

        type = type.var_val
        case type
        when :BOTH then type = @universe.locals.include?(pos) ? :LOCALS : :STACK
        when :NON_STACK then type = @universe.locals.include?(pos) ? :LOCALS : :GLOBALS
        end

        case type 
        when :STACK
          stack_val = pos.qt_to_num(env)
          return QT_Missing::INSTANCE unless stack_val.respond_to?(:num_val)
          @universe.stack[stack_val.num_val] or QT_Null::INSTANCE
        when :LOCALS then @universe.locals[pos] or QT_Null::INSTANCE
        when :GLOBALS then @universe.globals[pos] or QT_Null::INSTANCE
        else fail "Unknown qt_get type `#{type}`!"
        end
      end

      def qt_set(pos, val, env, type:)  # fix this
        return QT_Missing::INSTANCE if pos == QT_Variable.new( :'$' ) # undefined?
        type = type.var_val
        case type
        when :BOTH then type = @universe.locals.include?(pos) ? :LOCALS : pos.is_a?(QT_Number) ? :STACK : :LOCALS
        when :NON_STACK then type = @universe.locals.include?(pos) ? :LOCALS : :GLOBALS
        end

        case type 
        when :STACK
          throw(:ERROR, QTE_Type.new(env, " cannot set the non-integer stack position `#{pos}`")) unless pos.is_a?(QT_Number)
          @universe.stack[pos.num_val] = val
        when :LOCALS
          @universe.locals[pos] = val
        when :GLOBALS
          @universe.globals[pos] = val
        else fail "Unknown qt_get type `#{type}`!"
        end
      end

      def qt_del(pos, env, type:)
        type = type.var_val
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

      def qt_cmp(r, e) __uni_method(:__cmp, r, :__right, e) || super end
      def qt_add(r, e) __uni_method(:__add, r, :__right, e) || super end
      def qt_sub(r, e) __uni_method(:__sub, r, :__right, e) || super end
      def qt_mul(r, e) __uni_method(:__mul, r, :__right, e) || super end
      def qt_div(r, e) __uni_method(:__div, r, :__right, e) || super end
      def qt_mod(r, e) __uni_method(:__mod, r, :__right, e) || super end
      def qt_pow(r, e) __uni_method(:__pow, r, :__right, e) || super end

      def qt_cmp_l(r, e) __uni_method(:__cmp_l, r, :__right, e) || super end
      def qt_add_l(r, e) __uni_method(:__add_l, r, :__right, e) || super end
      def qt_sub_l(r, e) __uni_method(:__sub_l, r, :__right, e) || super end
      def qt_mul_l(r, e) __uni_method(:__mul_l, r, :__right, e) || super end
      def qt_div_l(r, e) __uni_method(:__div_l, r, :__right, e) || super end
      def qt_mod_l(r, e) __uni_method(:__mod_l, r, :__right, e) || super end
      def qt_pow_l(r, e) __uni_method(:__pow_l, r, :__right, e) || super end

      def qt_cmp_r(l, e) __uni_method(:__cmp_r, l, :__left, e) || super end
      def qt_add_r(l, e) __uni_method(:__add_r, l, :__left, e) || super end
      def qt_sub_r(l, e) __uni_method(:__sub_r, l, :__left, e) || super end
      def qt_mul_r(l, e) __uni_method(:__mul_r, l, :__left, e) || super end
      def qt_div_r(l, e) __uni_method(:__div_r, l, :__left, e) || super end
      def qt_mod_r(l, e) __uni_method(:__mod_r, l, :__left, e) || super end
      def qt_pow_r(l, e) __uni_method(:__pow_r, l, :__left, e) || super end
end

























