module Ducks

  ### = Backend Service
  ###
  ### The backend service provides the server side control for
  ### a ducks Page.
  ###
  ### The Service class is a Module, that is included into
  ### a Service Class per Page.
  ###
  class Service < Module

    def initialize(&block)
      module_eval(&block) if block
    end

    public :include
    public :define_method

  end # class Service

end # module Ducks

