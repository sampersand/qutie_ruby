class QT_Object; end

require_relative 'boolean'
require_relative 'null'
require_relative 'missing'

class QT_Object
  def self.from(_source, _env) #used when directly instatiating it, not copying, etc
    new 
  end

  def inspect
    "#{self.class}(#{inspect_to_s})"
  end

  def inspect_to_s
    to_s
  end

  def to_s
    ''
  end

  def eql?(other)
    self == other
  end

  def _rb_false?
    self.class == QT_False || self.class == QT_Null || self.class == QT_Missing
  end
  def _match?(right, env)
    !qt_match(right, env)._rb_false?
  end

  # def to_i; qt_to_num end
  # def +(other)   qt_add(other) end
  # def -(other)   qt_sub(other) end
  # def *(other)   qt_mul(other) end
  # def /(other)   qt_div(other) end
  # def %(other)   qt_mod(other) end
  # def **(other)  qt_pow(other) end
  # def =~(other)
  #   p binding.methods - Object.methods
  #   # p Binding.of_caller do |b|
  #   #   p b
  #   # end
  #   exit
  #   res=qt_match other;res._nil??nil:res.to_i end
  # def <=>(other)res=qt_cmp other;res._nil??nil:res.to_i end
  # def ==(other)qt_eql(other).bool_val end

  # qt methods
    def _missing? # the reason this isn't a qt method is because it's just an alias that i'll be using over and over.
      false
    end
    def _nil?
      false
    end

    # methods
      def qt_method(meth, _env) end
      def qt_length(_env); QT_Missing::INSTANCE end
    # conversion
      def qt_to_num(_env); QT_Missing::INSTANCE end
      def qt_to_text(_env); QT_Text.new(to_s) end
      def qt_to_bool(_env); QT_Boolean::get(true) end

    # operators 
      # access
        def qt_get(pos, _env, type:) QT_Missing::INSTANCE end
        def qt_set(pos, val, _env, type:) QT_Missing::INSTANCE end
        def qt_del(pos, _env, type:) QT_Missing::INSTANCE end
        def _peek(env, amnt=1)
          qt_get(QT_Number.new( amnt ), env, type: :STACK)
        end
        def _next(env, amnt=1)
          res = _peek(amnt)
          qt_del(QT_Number.new( amnt ), env, type: :STACK)
          res
        end
        def _stackeach(_env)
          @universe._stackeach # so bad
        end

      # comp
        def qt_call(args, _env) QT_Missing::INSTANCE end


        # def qt_cmp(right:) end
        def qt_eql(right, env)
          res = qt_eql_l(right, env); return res unless res._missing?
          res = right.qt_eql_r(self, env); return res unless res._missing?
          # return res.qt_equal( QT_Number::ZERO ) unless (res = qt_cmp(right))._missing?
          QT_False::INSTANCE
        end
        def qt_neq(right, env) qt_eql(right, env).qt_not  end
        def qt_gth(right, env)
          cmp = qt_cmp(right, env)
          cmp._missing? ? QT_Missing::INSTANCE : QT_Boolean::get( cmp.num_val > 0 )
        end

        def qt_lth(right, env)
          cmp = qt_cmp(right, env)
          cmp._missing? ? QT_Missing::INSTANCE : QT_Boolean::get( cmp.num_val < 0 )
        end
        def qt_leq(right, env)
          cmp = qt_cmp(right, env)
          cmp._missing? ? QT_Missing::INSTANCE : QT_Boolean::get( cmp.num_val <= 0 )
        end
        def qt_geq(right, env)
          cmp = qt_cmp(right, env)
          cmp._missing? ? QT_Missing::INSTANCE : QT_Boolean::get( cmp.num_val >= 0 )
        end

      #3##

        def __bi_method(right, env)
          callername = caller_locations(1,1)[0].label
          res = method(callername + '_l').(right, env)
          return res unless res._missing?
          res = right.method(callername + '_r').(self, env)
          return res unless res._missing?
          throw(:ERROR, QTError_MethodMissing.new($QT_CONTEXT.current, callername, self, right))
        end

        def qt_match(right, env) __bi_method(right, env) end
        def qt_add(right, env) __bi_method(right, env) end
        def qt_cmp(right, env) __bi_method(right, env) end
        def qt_sub(right, env) __bi_method(right, env) end
        def qt_mul(right, env) __bi_method(right, env) end
        def qt_div(right, env) __bi_method(right, env) end
        def qt_mod(right, env) __bi_method(right, env) end
        def qt_pow(right, env) __bi_method(right, env) end

        def qt_add_r(_left, _env) QT_Missing::INSTANCE end
        def qt_sub_r(_left, _env) QT_Missing::INSTANCE end
        def qt_mul_r(_left, _env) QT_Missing::INSTANCE end
        def qt_div_r(_left, _env) QT_Missing::INSTANCE end
        def qt_mod_r(_left, _env) QT_Missing::INSTANCE end
        def qt_pow_r(_left, _env) QT_Missing::INSTANCE end
        def qt_match_r(_left, _env) QT_Missing::INSTANCE end
        def qt_cmp_r(_left, _env) QT_Missing::INSTANCE end
        def qt_eql_r(_left, _env) QT_Missing::INSTANCE end
        def qt_lth_r(_left, _env) QT_Missing::INSTANCE end
        def qt_gth_r(_left, _env) QT_Missing::INSTANCE end
        def qt_neq_r(_left, _env) QT_Missing::INSTANCE end
        def qt_leq_r(_left, _env) QT_Missing::INSTANCE end
        def qt_geq_r(_left, _env) QT_Missing::INSTANCE end


        def qt_add_l(_right, _env) QT_Missing::INSTANCE end
        def qt_sub_l(_right, _env) QT_Missing::INSTANCE end
        def qt_mul_l(_right, _env) QT_Missing::INSTANCE end
        def qt_div_l(_right, _env) QT_Missing::INSTANCE end
        def qt_mod_l(_right, _env) QT_Missing::INSTANCE end
        def qt_pow_l(_right, _env) QT_Missing::INSTANCE end
        def qt_match_l(_right, _env) QT_Missing::INSTANCE end
        def qt_cmp_l(_right, _env) QT_Missing::INSTANCE end
        def qt_eql_l(_right, _env) QT_Missing::INSTANCE end
        def qt_lth_l(_right, _env) QT_Missing::INSTANCE end
        def qt_gth_l(_right, _env) QT_Missing::INSTANCE end
        def qt_neq_l(_right, _env) QT_Missing::INSTANCE end
        def qt_leq_l(_right, _env) QT_Missing::INSTANCE end
        def qt_geq_l(_right, _env) QT_Missing::INSTANCE end


      # logic
        def qt_not(_env); qt_to_bool.qt_not end

end












