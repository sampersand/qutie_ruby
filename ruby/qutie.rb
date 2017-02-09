$LOAD_PATH << '/Users/westerhack/code/ruby/qutie/ruby'
require_relative 'pre_parser'
require_relative 'parser'
require_relative 'plugins/whitespace'
require_relative 'plugins/parenthesis'
require_relative 'plugins/number'
require_relative 'plugins/operator'
require_relative 'plugins/variable'
require_relative 'plugins/comment'
require_relative 'plugins/text'
require_relative 'plugins/keyword'

require_relative 'functions'
require_relative 'constants'
parser = Parser.new
parser.add_plugin(plugin: Whitespace)
parser.add_plugin(plugin: Variable)
parser.add_plugin(plugin: Number)
parser.add_plugin(plugin: Parenthesis)
parser.add_plugin(plugin: Operator)
parser.add_plugin(plugin: Comment)
parser.add_plugin(plugin: Keyword)
parser.add_plugin(plugin: Text)
parser.add_builtins(builtins: Functions::FUNCTIONS)
parser.add_builtins(builtins: Constants::CONSTANTS)

# ARGV[0] = '/Users/westerhack/code/ruby/qutie/examples/users.qt'
file = ARGV[0] or fail "No file!"
text = open(file, 'r').read
PreParser::pre_process!(text)

# puts text
# exit
res = parser.process(input: text)

require 'pp'
puts '----[end]----'
res.stack.each_with_index{ |i,j| puts "\t#{j}: #{i.inspect}"}
puts '-------------'

