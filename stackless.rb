require 'fiber'
# Warning: can't use throw/catch with stackless 
# catch/throw implementation is stack based
# fibers break stack
# use raise/rescue instead
#
# otherwise stackless should be fully transparent
# to callers
#
# not tested with threads yet
#
# usage:
#
# class Deep
#   def my_recursive(x=0)
#     puts x
#     my_recursive x + 1
#   end
#   stackless_method :my_recursive
# end
#
# > d = Deep.new
# > d.my_recursive
# CTRL-C
# > Deep.remove_stackless :my_recursive
# d.my_recursive
# ...SystemStackError
#
# to make stackless module methods:
#
# class << modulename; stackless_method :method_name; end
#
class Module
	NoStacklessMethodSuffix = '__no_stackless'
  def stackless_method(*names)
		allow_stack = Numeric===names.last ? names.pop : 200
		names.each do |name|
			raise NameError, "method `#{name}' for class `#{self}'" \
				" is already stackless" if stackless_method? name
			stk_name = (name.to_s + ::Module::NoStacklessMethodSuffix).intern
			alias_method stk_name, name
			define_method(name) do |*args, &blk|
				if caller(allow_stack).nil?
					send stk_name, *args, &blk
				else
					Fiber.new(&method(stk_name)).resume(*args, &blk)
				end
			end
		end
  end

	def stackless_method?(name)
		method_defined?((name.to_s + ::Module::NoStacklessMethodSuffix).intern)
	end

	def remove_stackless(*names)
		names.each do |name|
			raise NameError, "unknown stackless method `#{name}' " \
				"for class `#{self}'" unless stackless_method? name
			stk_name = (name.to_s + ::Module::NoStacklessMethodSuffix).intern
			alias_method name, stk_name
			remove_method stk_name
		end
	end
end
# enjoy...
