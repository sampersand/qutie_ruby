require_relative 'universe'
require_relative 'plugins/builtins/object'
require_relative 'plugins/default/plugin'

class Parser

  attr_accessor :plugins
  attr_accessor :builtins
  def initialize(plugins: nil,
                 builtins: nil)
    @plugins  = plugins || []
    @builtins = builtins || {}
    @plugins.push Default
    assert_is_a(@plugins, Array, '@plugins')
    assert_is_a(@builtins, Hash, '@builtins')
  end

  def add_plugin(plugin:)
    assert_respond_to(plugin, :next_token, 'plugin')
    @plugins.unshift plugin
  end

  def add_builtins(builtins:)
    assert_is_a(builtins, Hash, 'builtins')
    builtins.each{ |k, v|
      assert_is_a(k, QT_Symbol, "passed builtin key")
      assert_is_a(v, QT_Object, "passed builtin val")
    }
    @builtins.update builtins
  end

  def process(input:,
              additional_builtins: {},
              universe: nil,
              pre_proc: true)

    assert_is_a(input, String, 'input')
    assert_is_any(pre_proc, TrueClass, FalseClass, 'pre_proc')
    PreParser::pre_process!(input) if pre_proc

    stream = UniverseOLD.new

    assert_is_any(universe, NilClass, QT_Universe, 'universe')
    universe ||= UniverseOLD.new
    assert_is_a(stream, QT_Universe, 'stream')
    assert_is_a(universe, QT_Universe, 'universe')

    assert_is_a(@builtins, Hash, '@builtins')
    assert_is_a(additional_builtins, Hash, 'additional_builtins')

    universe.globals.update(@builtins)
    universe.globals.update(additional_builtins)

    env = Environment.new(stream: stream,
                          universe: universe,
                          parser: self)
    stream.stack = input.each_char.to_a.collect do |e|
      res = QT_Default::from(e, env)
      assert_is_a(res, QT_Default, 'QT_Default::from')
      res
    end
    res = parse!(env: env) #dont need to copy stream cause we just made it.
    assert_is_a(res, Environment, 'parse!')
    res
  end

  def parse!(env:)
    assert_is_a(env, Environment, 'env')
    catch(:EOF){ 
      until env.stream.stack_empty?(env)
        
        res = next_token(env)
        assert_is_a(res, Array, 'next_token')
        
        token, plugin = res
        assert_is_a(token, QT_Object, 'token')

        assert_respond_to(plugin, :handle, 'plugin')
        plugin.handle(token, env)

      end
      nil
    }
    assert_is_a(env, Environment, 'env')
    env
  end

  def next_token(env)
    self.class.next_token(env)
  end

  def self.next_token(env)
    assert_is_a(env, Environment, 'env')

    env.p.plugins.each do |pl|
      token = pl.next_token(env)

      assert_is_any(token, NilClass, QT_Object, Symbol, 'token')
      next unless token
      if token == :retry
        res = next_token(env)
        assert_is_a(res, Array, 'res')
      else
        assert(!token.is_a?(Symbol), "`#{pl.to_s}`##{__callee__} returned a non-:retry Symbol: #{token}")
        res = [token, pl]
      end
      return res
    end
    assert(false, "No token found for Environment: `#{env}`")
  end
end














