# Presently we use Markaby and Builder for the HTML DSL.
# In the future we will probably internalize this using libxml
# for speed.

#begin
#  require 'nokogiri'
#rescue LoadError
  require 'markaby'
#end


module Ducks

  class Html
    def self.new(page, &block)
      if block.arity == 1
        Builder.new(&block)
      else
        #Nokogiri::HTML::Builder.new(&block).to_html
        #h = Nokogiri::HTML::Builder.new do
        #  insert(Nokogiri::XML::Node.new('body', @doc), &block)
        #end
        #h.to_html
        builder = Class.new(Markaby::Builder)
        builder.class_eval do
          include StandardBuildExtension
          include page.build_extension
        end
        builder.new(&block)
      end
    end

    module StandardBuildExtension
      def errors; []; end
      def params; {}; end
      def h(text); text; end
      def wallpaper_thumb(i); end

      # temporary
      def sites; []; end
      def videos; []; end
    end

  end

=begin

  require 'ducks/blockup'

  # = HTML blockup builder
  #
  class Html < BlockUp

    def to_s
      __convert__(@__tree__)
    end

    def __convert__(tree)
      html = []
      tree.each do |t, a, b|
        attrs = (Hash===a.last ? a.pop : {})

        tag = [t]
        tag.concat(attrs.collect{ |k,v| %[#{k}="#{v}"] })

        html << "<" + tag.join(' ') + ">"
        html << a.join("\n")
p b
        html << __convert__(b) if b
        html << "</#{t}>\n"
      end
      return html.join("\n")
    end

  end
=end

end


if __FILE__ == $0

  $DEBUG = true

  h = Ducks::Html.new
  s = h.body(:a=>1){
    trip {
      "this"
    }
  }
  puts s

end

