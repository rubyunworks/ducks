reuqire 'ducks/blockup'

module Ducks

  # XML blockup builder

  class Xml < BlockUp

    def __node__(tag, attrs=nil, &block)
      attrs ||= []

      t = [tag]
      t.concat(attrs.collect{ |a,v| %[#{a}="#{v}"] })

      s = "\n<" + t.join(' ') + ">"
      if block
        if block.arity > 0
          sb = block.call(self)
        else
          sb = instance_eval(&block)
        end
        s << sb
      end
      s << "</#{tag}>\n"
    end    

  end

end

