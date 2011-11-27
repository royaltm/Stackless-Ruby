require "./stackless.rb"

class Test
	def test; pass; end
end

raise "Something wrong" unless [
	"Test.stackless_method(:test) == [:test]",
	"Test.method_defined?(:test__no_stackless)",
	"Test.method_defined?(:test)",
	"Test.stackless_method?(:test)",
	"Test.remove_stackless(:test) == [:test]",
	"not Test.method_defined?(:test__no_stackless)",
	"Test.method_defined?(:test)",
	"not Test.stackless_method?(:test)",
].all? {|cmd| puts cmd; eval cmd; }

