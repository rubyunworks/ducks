module Ducks

  # = Remote Procedure Call
  #
  # Remote procedures use Ajax and JSON to
  # transmit arguments and return values.
  class Remote < Module
    attr :name

    def initialize(name, &block)
      @name = name
      define_method(name, &block)
    end

    def to_js
      "function #{name}(){ remote_ajax_call('#{name}'); };"
    end

    alias_method :to_s, :to_js
  end

end

