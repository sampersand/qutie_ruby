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
    assert_is_a(@plugins, Array, msg: "`plugins` passed to Parser#new isn't an Array")
    assert_is_a(@builtins, Hash, msg: "`builtins` passed to Parser#new isn't a Hash ")
  end

  def add_plugin(plugin:)
    assert_respond_to(plugin, :next_token, msg: "`plugin` passed to Parser#add_plugin doesn't respond to `next_token`")
    @plugins.unshift plugin
  end

  def add_builtins(builtins:)
    assert_is_a(builtins, Hash, msg: "`builtins` passed to Parser#add_builtins aren't a Hash")
    builtins.each{ |k, v|
      assert_is_a(k, QT_Symbol, msg: "Passed builtin key `#{k}` isn't a QT_Symbol") &&
      assert_is_a(v, QT_Object, msg: "Passed builtin val `#{v}` isn't a QT_Object")
    }
    @builtins.update builtins
  end

  def process(input:,
              additional_builtins: {},
              universe: nil,
              pre_proc: true)

    assert_is_a(input, String, msg: "`input` passed to Parser#process isn't a String")
    assert_is_any(pre_proc, TrueClass, FalseClass, msg: "`pre_proc` passed to Parser#process isn't a boolean")
    PreParser::pre_process!(input) if pre_proc

    stream = UniverseOLD.new
    assert_is_a(universe, NilClass, QT_Universe, msg: "`universe` passed to Parser#process isn't nil or a QT_Universe")
    universe ||= UniverseOLD.new
    assert_is_a(stream, QT_Universe, msg: "`stream` (from `UniverseOLD.new`) didn't return a QT_Universe")
    assert_is_a(universe, QT_Universe, msg: "`universe` (from `UniverseOLD.new` or passed in) isn't a QT_Universe")

    assert_is_a(@builtins, Hash, msg: "`@builtins` isn't a Hash")
    assert_is_a(additional_builtins, Hash, msg: "`additional_builtins` isn't a Hash")
    universe.globals.update(@builtins)
    universe.globals.update(additional_builtins)

    env = Environment.new(stream: stream,
                          universe: universe,
                          parser: self)
    stream.stack = input.each_char.to_a.collect do |e|
      res = QT_Default::from(e, env)
      assert_is_a(res, QT_Default, msg: "`QT_Default.new` returned a non-QT_Default type: #{res.class}")
      res
    end
    res = parse!(env: env) #dont need to copy stream cause we just made it.
    assert_is_a(res, Environment, msg: "`parse!` didn't return an Environment, bu: #{res.class}")
    res
  end

  def parse!(env:)
    assert_is_a(env, Environment, msg: "`env` passed to Parser#parse! isn't an Environment")
    catch(:EOF){ 
      until env.stream.stack_empty?(env)
        
        res = next_token(env)
        assert_is_a(res, Array, msg: "Parser#next_token didn't return an Array")
        
        token, plugin = res
        assert_is_a(token, QT_Object, msg: "`token` returned from Parser#next_token isn't a QT_Object")

        assert_respond_to(plugin, :handle, msg: "`plugin` returned from Parser#next_token doesn't have attribute `handle`")
        plugin.handle(token, env)

      end
      nil
    }
    assert_is_a(env, Environment, msg: "Somehow env changed from Environment to a `#{env.class}` within Parser#parse!")
    env
  end

  def next_token(env)
    self.class.next_token(env)
  end

  def self.next_token(env)
    assert_is_a(env, Environment, msg: "`env` passed to Parser#next_token isn't an Environment")

    env.p.plugins.each do |pl|
      token = pl.next_token(env)

      assert_is_a(token, NilClass, QT_Object, Symbol, msg: "`#{pl.to_s}`#next_token didn't return nil or a QT_Object")
      next unless token
      if token == :retry
        res = next_token(env)
        assert_is_a(res, Array, msg: "Parser#next_token didn't return an Array")
      else
        assert(!token.is_a?(Symbol), msg: "`#{pl.to_s}`#next_token returned a Symbol that isn't :retry (#{token})")
        res = [token, pl]
      end
      return res
    end
    assert(false, msg: "No token found for Environment: `#{env}`")
  end
end














