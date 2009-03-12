require 'ducks/page'

def page(name, &block)
  Ducks::Page.create(name, &block)
end

