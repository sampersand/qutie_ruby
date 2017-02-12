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

  def process(input:, additional_builtins: {})
    stream = UniverseOLD.new(stack: input.each_char.to_a.collect(&QT_Default::method(:from)))
    p stream.stack.select{|e|e.source_val == :"\n"}.length
    stream.__line_no = 
    universe = UniverseOLD.new
    universe.globals.update(@builtins)
    universe.globals.update(additional_builtins)
    parse!(stream: stream, universe: universe) #dont need to copy stream cause we just made it.
  end

  def parse!(stream:, universe:)
    catch(:EOF){ 
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
      return :retry != token  ? [token, pl] : next_token!(stream: stream,
                                                         universe: universe,
                                                         parser: parser)
    } or fail "Nothing found!"
  end
end








 