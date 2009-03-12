require 'red'
require 'red/executable'
require 'red/version'

require 'ducks/js'


module Ducks

  class Script < Module

    def initialize(&block)
      @javascript = []

      extend self

      instance_eval(&block)
    end

    def javascript(string=nil)
      @javascript << string || Javascript.new
    end

  end


  class ScriptProcessor

    def initialize(script)
      @script = script
    end

    def output
      output = []
      javascript_output(output)
      output.join("\n\n")
    end

    def javascript_output(output)
      javascripts = @script.instance_variable_get("@javascript")
      javascripts.each do |js|
puts js
        sexp_array = nil
        #hush_warnings {
          sexp_array = ParseTree.translate(js)
          p sexp_array
        #}
        output << sexp_array.build_node.compile_node
      end
      output
    end

  end

end


if $0 == __FILE__

  include Red

  #Red.init

  script = Ducks::Script.new do

    javascript %{

      class Foo
        def initialize(foo)
          @foo = foo
        end
      end

      class Bar
        def initialize(bar)
          @bar = bar
        end
      end

    }

  end

  sp = Ducks::ScriptProcessor.new(script)
  puts sp.output

end

