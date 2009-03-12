require 'red'
require 'red/executable'
require 'red/version'

require 'ruby2ruby'

module Ducks

  class Script

    ###
    class RedCode

      def initialize(&block)
        #@names = []
        @module = Module.new(&block)
      end

      def define_function(name, &code)
        @module.define_method(name, &code)
      end

      def define_ajax_function(name)
        @module.module_eval %{
          def #{name}
            remote_ajax_call('#{name}')
          end
        }
      end

      def to_ruby
        ruby = []
        #@names.each do |name|
          ruby << RubyToRuby.translate(@module) #, name)
        #end
        ruby.join("\n\n")
      end

      def to_sexp
        to_ruby.string_to_node
      end

      def to_js
        to_sexp.compile_node
      end

      def to_html
        "<script>\n#{to_js}\n</script>"
      end

      alias_method :to_s, :to_js

      #def function(name, *args, &block)
      #  args = args.join(',')
      #  "function #{name}(#{args) {\n" + instance_eval(&block) + "\n};"
      #end

      class Module < ::Module
        def initialize(&block)
          module_eval(&block) if block
        end

        public :define_method
      end

    end

  end

end

