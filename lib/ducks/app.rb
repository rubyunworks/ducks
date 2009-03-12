module Ducks
  require 'json'
  require 'ducks/page'

  # = Duck Application
  #
  class App

    # Root directory of ducks web applicaiton.
    attr :root
    attr :env
    attr :pages

    #
    def initialize(root=Dir.pwd)
      @root  = root
      @pages = {}

      @file_server = Rack::File.new(root)

      load_app
    end

    # Currently load all .rb scripts. In future
    # check for a start.rb script or something.
    def load_app
      context = LoadContext.new(self)
      files = Dir.glob(File.join(root,'*.rb'))
      files.each do |file|
        context.instance_eval(File.read(file), file) #, __LINE__)
      end
    end

    #
    def call(env)
      @env = env

      meth = env['REQUEST_METHOD']

      path = env['PATH_INFO'].sub(/^\//, '')
      path = 'index' if path == ''

      if page = pages[path]
        status = 200
        header = { "Content-Type"=>"text/html" }
        body   = page.to_html
      elsif File.file?(path)
        status, header, body = *@file_server.call(env)
      else
        path, part = File.split(path)
        if page = pages[path]
          # how to handle ajax call?
          opts   = env['rack.input'] #.to_json
          val, type = *page.service.send(part, opts)
          type = type || 'text/plain'
          status = 200
          header = { "Content-Type" => type }
          body   = val
        else
          status = 401
          header = { "Content-Type"=>"text/plain" }
          body   = "#{path} not found."
        end
      end
      return [status, header, body]
    end

    #def get
    #end

    #def post
    #end

    ### Load Context
    class LoadContext

      def initialize(app)
        @app = app
      end

      def page(route, &block)
        @app.pages[route.to_s] = Page.new(@app, route, &block)
      end

    end # class LoadContext

  end # class Application

end # module Ducks

