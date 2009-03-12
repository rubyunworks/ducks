require 'facets/basicobject'

class BlockUp < BasicObject

  def initialize
    @__tree__ = []
  end

  def method_missing(s, *a, &b)
    if b
      if b.arity > 0
        sb = b[self]
      else
        sb = instance_eval(&b)
      end
      @__tree__ << [s, a, sb]
    else
      @__tree__ << [s, a, nil]
    end
  end

end

