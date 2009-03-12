require 'ducks/script/red'

module Ducks

  ### = Script
  ###
  class Script

    attr :src
    attr :opts
    attr :code

    ###
    def initialize(src=nil, opts=nil, &block)
      @src  = src
      @opts = opts || {}
      if @opts[:raw]
        @code = RawCode.new(opts.delete(:raw))
      else
        @code = Code.new(&block) if block
      end
    end

    ###
    def to_html(page)
      s = page.href(src)
      h = ''
      h << %[<script]
      h << %[ src="#{s}"] if src && !src.empty?
      h << %[ type="text/javascript"] unless opts[:type]
      h << opts.map{ |k,v| %[#{k}="#{v}"] }.join(' ')
      h << %[>]
      if code
        h << "\n"
        h << code.to_js
        h << "\n"
      end
      h << %[</script>]
      h
    end

    alias_method :to_s, :to_html

    ###
    def define_function(name, &block)
      @code = Code.new unless @code
      @code.define_function(name, &block)
    end

    ###
    def define_ajax_function(name)
      @code = Code.new unless @code
      @code.define_ajax_function(name)
    end

    ### = Script Code
    ###
    ### The Code class currently sublasses to the Red class,
    ### which provides the needed Ruby to Javascript translator.
    ### In the future we may support other mechinisms such as
    ### HotRuby.
    ###
    class Code < RedCode
    end

    #
    class RawCode
      def initialize(text)
        @text = text
      end
      def to_js
        @text
      end
    end

  end # class Script

end # module Ducks

