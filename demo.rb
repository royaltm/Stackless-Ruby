require './stackless.rb'

def timer
	start = Time.now
	ret = yield
	puts "#{Time.now - start}s"
	ret
end

module Math
	def self.power(x)
		x.zero? ? 1 : x * power(x.abs - 1)
	end
end

def test_eval cmd
	print "#{cmd}: "
	eval cmd
end

def demo
	begin
		x = 0
		loop { test_eval "timer { Math.power(#{x+=1000}) }" }
	rescue SystemStackError
		puts "ups...#{$!.inspect}"
		print "press enter"
		gets
		class << Math
			stackless_method :power
		end
		puts "\nBehold the Power Of The Stackless!"
		retry
	end
end

demo
