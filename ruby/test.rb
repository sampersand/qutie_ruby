def foo(&block)
  p block.nil?

  p caller_locations[0]
  p Thread::Backtrace.methods - Object.methods
end
def bar
  env = 1
  foo
end
bar