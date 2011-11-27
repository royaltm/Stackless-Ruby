#Stackless Ruby

It depends on the taste, needs and skills (in that order), but I like to write programs recursively.
When too many control variables are floating around it will get messy in the end.

Writing recursive is easy and it looks good.

Let's write some recursive program... how about... power?

Hmmm there is no Math.power by default in Ruby (or did I miss something?)

let's make one (easier than searching for):

    module Math
      def self.power(x)
        x.zero? ? 1 : x * power(x.abs - 1)
      end
    end

test it then

    Math.power(0)
    => 1
    Math.power(2)
    => 2
    Math.power(3)
    => 6
    Math.power(4)
    => 24
    Math.power(24)
    => 620448401733239439360000

allrighty, looks good

hmmm.... how about

    Math.power(9000)
    SystemStackError: stack level too deep

booooooo (that's what the recursion haters will say probably),
but i like my recursive func and don't want to loopeedise it

what to do? what to do?

probably increase stack... yeah but what limit should be set?
How would I know if it should be enough (for everyone)?

but.. wait... there it is, YES!

###SHINY, BRILLIANT AND TASTY

(yes I think programs have their own smell and taste)

## S.T.A.C.K.L.E.S.S

*Your recursive funcs may no longer fear the wrath of the SystemStackError error!*

Yeah... right... let's try it then

    require 'stackless'
    class << Math
      stackless_method :power
    end

wait... what? is that it? no special settings? no refactoring?

    Math.power(30000)

(tapity tapity tap...)

WHOA!!!

    => 27595372462193845993799421664254627839807620445293309855296350368000758688503
    60565832972977651204254341650306308369180105720079889211173647623998433383137184
    96725428585731122241126651370462320856666351384397125584539286776700159352122985
    76717678590883778530258331792037082631553698416050421549360425989090758564308520
    44551518050502194448043519497955816834830283123674559621734939901731624301201076
    12718497501643507858275814074921674864730917905059002296437405578024841684270884
    60293197031261147128807459366136729883280460118301927914420580317557853670289608
    (...)

ok... how? why? what? did it mess with some Ruby internals?

Nope, the solution is simple, pure Ruby and it uses:

###Fibers

They appeared in 1.9 Ruby and have been announced as
"primitives for implementing light weight cooperative concurrency in Ruby".

Which means that every Fiber instance is some kind of independent
thread-like entity, with it's own stack but doesn't run anything unless told to.
You can create a fiber from proc, call it and it can yield control
(and some variables) back to you and you can told to continue it's work
(passing again some variables to it).

Quite complex.. but also it means we can just create a fiber, call it
and wait for it to return... sooo... yeah I think you've got the idea by now.

stackless.rb is just a bunch of module/class functions that wraps a method
call into a Fiber. As you would expect creating a fiber is slower than
just calling a function, so it checks for current stack level with
Kernel.caller and creates fibers only if it grew too much, up to the
configurable limit.

##Usage:

###set up

    class Someclass
      def my_recursive(*args, &blk)
        ...
      end
      stackless_method :my_recursive, allow_stack
    end
    
The `allow_stack` is optional and defaults to 200.
The greater it is the faster wrapped method performs (less frequent fiber creation),
but you risk of going over the fiber stack which is only 4KB.

###call

    Someclass.new.my_recursive ...

###check if stackless

    Someclass.stackless_method? :my_recursive
    => true

###remove stackless wrapper

    Someclass.remove_stackless :my_recursive
    Someclass.stackless_method? :my_recursive
    => false

##Known Bugs & Limitations

You can't wrap calls to stackless methods with throw/catch as it is based purely on local stack.
The throw() will not be catched by catch() if there will be a fiber call between them.
However you can still use it inside stackless methods and between non-stackless calls.
If you need to throw/catch from stackless method, use raise/rescue instead.

Stackless through fibers is very fresh idea, still untested in many environments,
including interoperability with Threads.
