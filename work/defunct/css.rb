module Ducks
  require 'facets/dictionary'

  # = CSS Stylesheet
  #
  # :CREDIT: Arne Brasseur
  #
  module Stylesheet

    def self.new(&block)
      Builder.new(&block)
    end

    module Render
      def render(parents = [])
        result = ''
        nesting = parents.dup << self

        if respond_to?(:properties) && properties?
          selektor = nesting.map {|b| b.selector}.join(' ')
          result << "#{selektor} {\n#{properties}}\n\n"
        end

        @blocks.each do |b|
          result << b.render(nesting)
        end

        result
      end
    end

    module Selector
      def self.included(mod)
        if Class === mod
          %w(p display).each &mod.method(:undef_method)
        end
      end

      def id(idname, prop = {}, &blk)
        @blocks << Block.new(:id => idname, :properties => prop, &blk)
      end

      def klass(klassname, prop = {}, &blk)
        @blocks << Block.new(:class => klassname, :properties => prop, &blk)
      end

      def block(prop, &blk)
        @blocks << Block.new(prop, &blk)
      end

      def method_missing(name, prop={}, &blk)
        if block_given?
          @blocks << Block.new(:tag => name, :properties => prop, &blk)
        else
          @properties[name.to_s.gsub('_','-')] = prop
        end
      end
    end

    class Block
      include Selector
      include Render

      attr_accessor :blocks

      def initialize(opt = {}, &blk)
        @tag, @id, @class, @properties =
          [:tag, :id, :class].map {|n| opt[n]}
        @blocks = []
        @properties = Dictionary.new
        @properties.update(opt[:properties]) if opt[:properties]
        instance_eval(&blk) if block_given?
      end

      def selector
        "%s%s%s" % [@tag, ("##{@id}" if @id), (".#{@class}" if @class)]
      end

      def properties
        @properties.inject '' do |s, (k, v)|
          s << "  #{k}: #{v};\n"
        end
      end

      def properties?
        not @properties.empty?
      end
    end

    class Builder
      include Selector
      include Render

      def initialize(&blk)
        @blocks = []
        instance_eval(&blk) if block_given?
        self
      end

      def to_s
        @blocks.map{|b| b.render}.join
      end
    end

  end
end

#module Kernel
#  def css(&blk)
#    CSSBuilder::Builder.new(&blk)
#  end
#end


if __FILE__ == $0

  css = Ducks::Stylesheet.document {
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

