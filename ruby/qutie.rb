require_relative 'pre_parser'
require_relative 'contexts'
require_relative 'parser'
require_relative 'exceptions/exception'
require_relative 'plugins/whitespace/plugin'
require_relative 'plugins/universe/plugin'
require_relative 'plugins/number/plugin'
require_relative 'plugins/operator/plugin'
require_relative 'plugins/variable/plugin'
require_relative 'plugins/comment/plugin'
require_relative 'plugins/text/plugin'

require_relative 'functions'
require_relative 'constants'
parser = Parser.new
parser.add_plugin(plugin: Whitespace)
parser.add_plugin(plugin: Variable)
parser.add_plugin(plugin: Number)
parser.add_plugin(plugin: Universe)
parser.add_plugin(plugin: Operators)
parser.add_plugin(plugin: Comment)
parser.add_plugin(plugin: Text)
parser.add_builtins(builtins: Functions::FUNCTIONS)
parser.add_builtins(builtins: Constants::CONSTANTS)
# ARGV[0] = '/Users/westerhack/code/ruby/qutie/examples/users.qt'
file = ARGV[0] or fail "No file!"
text = open(file, 'r').read
# PreParser::pre_process!(text)

# puts text
# exit
$QT_CONTEXT = Contexts.new
res=nil
err = catch(:ERROR) do 
  res = parser.process(input: text)
  nil
end

if err
  puts "--ERROR--\n#{err}\n\n"
  exit(1)
end

require 'pp'
puts '----[end]----'
res.stack.each_with_index{ |i,j| puts "\t#{j}: #{i.inspect}"}
puts '-------------'

