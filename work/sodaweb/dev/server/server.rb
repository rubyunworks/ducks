#require 'cherry/route.rb'
require 'yaml'


module Cherry

  # FIXME
  def self.root
    Dir.pwd
  end

  class Server

    def initialize
      load_config
#      load_routes
    end

    # Load server configuration.
    def load_config
      #@config ||= YAML.load(File.new("server/config.yaml"))
    end

#     # Load routes.
#     def load_routes
#       @routes = []
#       routes = Dir.glob("actions/routes/*")
#       routes.each do |file|
#         puts "[Add Route] " + file
#         #name = file[7..-1]
#         #name = name.chomp(File.extname(name))
#         load_route(file)
#       end
#     end
#
#     # Load a route.
#     def load_route(file)
#       @routes << Route.load(file)
#     end

    # Rack call.
    #
    #   REQUEST_METHOD      GET or POST
    #
    #   SCRIPT_NAME         The initial portion of the request URL’s "path" that corresponds to the application object,
    #                       so that the application knows its virtual "location". This may be an empty string, if the
    #                       application corresponds to the "root" of the server.
    #
    #   PATH_INFO           The remainder of the request URL’s "path", designating the virtual "location" of the
    #                       request’s target within the application. This may be an empty string, if the request URL
    #                       targets the application root and does not have a trailing slash.
    #
    #   QUERY_STRING        The portion of the request URL that follows the ?, if any. May be empty, but is always required!
    #
    #   SERVER_NAME         When combined with SCRIPT_NAME and PATH_INFO, these variables can be used to complete the URL.
    #                       Note, however, that HTTP_HOST, if present, should be used in preference to SERVER_NAME for
    #                       reconstructing the request URL. SERVER_NAME and SERVER_PORT can never be empty strings, and so
    #                       are always required.
    #
    #   SERVER_PORT         Port number to serve site to.
    #
    #   HTTP_???
    #
    def call(env)
      req = Request.new(
        :method => env['REQUEST_METHOD'],
        :script => env['SCRIPT_NAME'],
        :path   => env['PATH_INFO'],
        :query  => env['QUERY_STRING'],
        :domain => env['SERVER_NAME'],
        :port   => env['SERVER_PORT']
                   #env['HTTP_???']
      )
      return respond(req)
    end

    # Respond to request.
    def respond(request)
      puts "[Request] " + request.path

      #route = find_route(request.path)
      #if route
      #  status, header, body = route.respond(request)
      #else
        path = request.path
        path = path[1..-1] if path[0,1] == '/'
        if File.exist?(path) # pass through to webserver?
          status = 200
          header, body = handle(path)
          #header = {"Content-Type" => "text/html"}  # how to decipher?
          #body   = File.new(path)
        else
          status = 404
          header = {"Content-Type" => "text/html"}
          body = File.new('view/errors/404.html')  # FIX return rack exception page if development mode.
        end
      #end

      return status, header, body
    end

    # TODO Ultimately use plug-in services for non-passthru handlers.
    # These plug-in handlers will be used by the site compiler too.
    # (The site compiler allows Cherry sites to be served without this
    # special server script, i.e. all you need is a properly configured
    # webserver.)
    def handle(path)
      ext = File.extname(path)
      case ext.downcase
      when '.html'
        header = {"Content-Type" => "text/html"}
        body   = File.new(path)
      when '.png', '.jpg', '.jpeg', '.gif'
        header = {"Content-Type" => "text/plain"}
        body   = File.new(path)
      when '.xml'
        header = {"Content-Type" => "text/xml"}
        body   = File.new(path)
      when '.json'
        header = {"Content-Type" => "text/x-json"}
        body   = File.new(path)
      when '.yaml'
        header = {"Content-Type" => "text/x-json"}
        body   = YAML.load(File.new(path)).to_json
      when '.sql'
        # use dbi and convert to json.
        header = {"Content-Type" => "text/x-json"}
        body = "{}" # TODO
      when '.sqlx'
        # use dbi and convert to xml.
        header = {"Content-Type" => "text/xml"}
        body = "<records></records>" # TODO
      else
        header = {"Content-Type" => "text/plain"}
        body   = File.new(path)
      end
      return header, body
    end

#     # Find a route for the given url.
#     def find_route(url)
#       @routes.each do |route|
#         if route.match(url)
#           return route
#         end
#       end
#       nil
#     end

  end

  class Request
    attr_accessor :method
    attr_accessor :script
    attr_accessor :path
    attr_accessor :query
    attr_accessor :domain
    attr_accessor :port

    def initialize(options)
      options.each do |k,v| send("#{k}=", v) end
    end
  end

end
