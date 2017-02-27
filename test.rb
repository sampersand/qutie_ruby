require 'test/unit'

module Test::Unit::Assertions
  def assert_contains(expected_substring, string, *args)
    assert_match expected_substring, string, *args
  end
end

puts Test::Unit::Assertions::methods.select{|e| e.to_s =~ /assert/ }