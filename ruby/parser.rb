require_relative 'universe'
require_relative 'plugins/default/plugin'

class Parser

  attr_accessor :plugins
  attr_accessor :builtins

  def initialize(plugins: nil, builtins: nil)
    @plugins = plugins || []
    @builtins = builtins || {}
    @plugins.push Default
  end

  def add_plugin(plugin:)
    @plugins.unshift plugin
  end

  def add_builtins(builtins:)
    @builtins.update builtins
  end

  def process(input:, additional_builtins: {})
    universe = UniverseOLD.new
    stream = UniverseOLD.new(stack: input.each_char.to_a)
    universe.globals.update(@builtins)
    universe.globals.update(additional_builtins)
    catch(:EOF){
      parse(stream: stream,
            universe: universe)
    }
  end

  def parse(stream:, universe:)
    parse!(stream: stream.clone, universe: universe)
  end

  def catch_EOF(universe, &block)
    levels = catch(:EOF, &block) or return false

    if levels[0] > 0
      throw :EOF, [levels[0]-1, levels[1]]
    elsif levels[0] == 0
      universe << levels[1];
    end
  end

  def parse!(stream:, universe:)
    catch_EOF(universe){ 
      until stream.stack_empty?
        token, plugin = next_token!(stream: stream,
                                    universe: universe,
                                    parser: self)
        plugin.handle(token: token,
                      stream: stream,
                      universe: universe,
                      parser: self)
      end
      nil
    }
    universe
  end

  def next_token!(stream:, universe:, parser:)
    self.class.next_token!(stream: stream,
                           universe: universe,
                           parser: parser)
  end

  def self.next_token!(stream:, universe:, parser:)
    parser.plugins.each{ |pl|
      token = pl.next_token!(stream: stream,
                             universe: universe,
                             parser: parser)
      next unless token
      return token != :retry ? [token, pl] : next_token!(stream: stream,
                                                         universe: universe,
                                                         parser: parser)
    } or fail "Nothing found!"
  end
end








 