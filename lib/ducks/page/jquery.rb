module Ducks

  module Jquery

    def jquery(id)
      @script << %[$("#{id}")]
    end

  end

end

