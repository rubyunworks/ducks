module Ducks

  class System

    def initialize(app, &block)
      @app = app
      @sys = Class.new
      instance_eval(&block)
    end

    def init(&block)
      @sys.define_method(:initialize, &block)
    end

    def to(name)
      @sys.define_method(name, &block)
    end

    def func(name)
      @sys.define_method(name, &block)
    end

    def const(name, &block)
      @sys.const_set(name, block.call)
    end

    def app
      @app
    end

  end

end

