require_relative 'universe'
require_relative 'plugins/builtins/object'
require_relative 'plugins/default/plugin'

class Parser

  attr_accessor :plugins
  attr_accessor :builtins

  def initialize(plugins: nil, builtins: nil)
    @plugins  = plugins || []
    @builtins = builtins || {}
    @plugins.push Default
  end

  def add_plugin(plugin:)
    @plugins.unshift plugin
  end

  def add_builtins(builtins:)
    @builtins.update builtins
  end

  def process(input:, additional_builtins: {}, universe: nil)
    stream = UniverseOLD.new(stack: input.each_char.to_a.collect(&QT_Default::method(:from)))
    universe ||= UniverseOLD.new
    universe.globals.update(@builtins)
    universe.globals.update(additional_builtins)
    $QT_CONTEXT.start(stream, universe)
    res = parse!(stream: stream, universe: universe) #dont need to copy stream cause we just made it.
    $QT_CONTEXT.stop(stream)
    res
  end

  def parse!(stream:, universe:)
    env = Environment.new(stream, universe, self)
    catch(:EOF){ 
      until stream.stack_empty?
        token, plugin = next_token!(env)
        plugin.handle(token, env)
      end
      nil
    }
    env
  end

  def next_token!(env)
    self.class.next_token!(env)
  end

  def self.next_token!(env)
    env.parser.plugins.each do |pl|
      token = pl.next_token!(env)
      next unless token
      return :retry != token  ? [token, pl] : next_token!(env)
    end or fail "Nothing found!"
  end
end








 