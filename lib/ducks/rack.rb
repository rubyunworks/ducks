require 'ducks/app'

module Ducks

  # = Rack Adapter
  class RackApp

    def initialize
      @app = App.new
    end

    def call(env)
      @app.call(env)
    end

  end

end

