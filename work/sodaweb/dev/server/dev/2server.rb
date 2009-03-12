
# web server

request = ?

class Server

  attr :controllers

  def run
    loop do
      response = respond_to(request)
      request  = deliver(response)
    end
  end

  def respond_to(request)
    responses = []
    controllers.each do |controller|
      responses << controller.call(request)
    end
    return responses.last
  end

end



def cherry_controller
  Object.new do
    @model_response = model.call(request)
    @view_response  = view.call(@model_response)
  end
end


