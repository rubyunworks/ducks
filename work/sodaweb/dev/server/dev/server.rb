require 'cherry/html_response'

module Cherry

  #
  module ControlParameters
    attr_accessor :route, :feed, :layout, :behavior, :style, :script

    def initialize(properties)
      properties.each do |prop, val|
        instance_variable_set("@#{prop}", val)
      end
    end

    def controller_properties
      { :route => route,
        :feed => feed,
        :layout => layout,
        :behavior => behavior,
        :style => style,
        :script => script
      }
    end
  end

  #
  module ControlResponse
    def respond(request)
      return 200, 'text/plain', HtmlResponse.html(contoller_properties)
    end
  end

  #
  class Controller
    include ControlParameters
    include ControlResponse
  end



  class Base < WEBrick::HTTPServlet::AbstractServlet

    def do_GET(request, response)
      status, content_type, body = do_stuff_with(request)
      response.status = status
      response['Content-Type'] = content_type
      response.body = body
    end
    alias_method :do_POST, :do_GET

    def do_stuff_with(request)
      return 200, "text/plain", "you got a page"
    end
  end

end
