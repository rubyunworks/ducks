module Ducks

  ### = Stylesheet Container
  ###
  class Style

    attr :href
    attr :opts
    attr :code

    def initialize(href=nil, opts=nil, &block)
      @href = href
      @opts = opts || {}
      @code = Code.new(&block) if block
    end

    #
    def to_html(page)
      h = ''
      if href
        h << %[<link type="text/css"]
        h << %[ rel="stylesheet"]
        h << %[ href="#{page.href(href)}" ]
        h << opts.map{ |k,v| %[#{k}="#{v}"] }.join(' ')
        h << %[/>]
      end
      if code
        h << %[<style type="text/css" ]
        h << opts.map{ |k,v| %[#{k}="#{v}"] }.join(' ')
        h << %[>\n]
        h << code.to_css
        h << %[\n</style>]
        h
      end
      return h
    end

    #
    alias_method :to_s, :to_html

    ### = Coded Stylesheet
    ###
    ### This is a CSS Builder Pattern class. Given a block of code
    ### it will construct a CSS representation.
    ###
    ### TODO: Needs more work!
    class Code

      def initialize(&block)
        @__sheet__ = []
        instance_eval(&block)
      end

      def to_css
        @__sheet__.map do |selector, style|
          "#{selector} { #{style} }"
        end.join("\n")
      end

      alias_method :to_s, :to_css

      #
      def method_missing(*selection, &block)
        @__sheet__ << [Selector.new(*selection), Attributes.new(&block)]
      end

      ### = Stylesheet Code Selector
      ### Encapsulates a CSS selector.
      ###
      class Selector
        def initialize(*selection)
          @__selector__ = selection
        end

        def to_s
          @__selector__.join(' ')
        end
      end

      ### = Stylesheet Code Attributes
      ###
      ### This class encapsulates CSS style attributations.
      ###
      class Attributes
        def initialize(&block)
          @__style__ = []
          instance_eval(&block)
        end

        def to_s
          @__style__.map{|k, v| "#{k}:#{v}"}.join(';')
        end

        def method_missing(name, value)
          @__style__ << [name, value]
        end
      end

    end # class Code

  end # class Stylesheet

end # module Ducks





if __FILE__ == $0

  css = Ducks::Stylesheet.new {
    blue = "#000099"

    id('useracl_loginbox') {
      label {
        width '100px'
        color blue
      }
      input {
        width '10%'
        klass('big') {
          size '150%'
          background_color blue
        }
      }
    }
  }

  puts css
end

