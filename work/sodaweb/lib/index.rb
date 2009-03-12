#!/usr/bin/env ruby

# Frontsite Minimalist Web Framework
#
# Ruby Implementation
#
#
# Occam's Razor
#

begin
  require 'rubygems'
rescue LoadError
end

require 'yaml'
require 'cgi'
require 'erb'
require 'dbi'
require 'json'

#

module Soda

  class Site
    attr :cgi
    attr :routes
    attr :config

    def initialize(adapter)
      @cgi    = adapter
      @routes = Routes.load(self, routes_file)
      @config = Config.load(self, config_file)
    end

    # Root directory.

    def root
      @root ||= ENV['DOCUMENT_ROOT']
    end

    #

    def config_file
      File.join(root, 'config.yaml')
    end

    #

    def routes_file
      File.join(root, 'routes.yaml')
    end

    #

    def log(msg, *objs)
      File.open(logfile, 'a') do |f|
        f << msg.to_s
        f << ": " unless objs.empty?
        f << objs.collect{ |o| o.inspect }.join("\n")
        f << "\n"
      end
    end

    #

    def logfile
      @logfile ||= File.join(root, 'log/debug.log')
    end

    #

    def start
      if script = cgi.script_name
        path  = script.sub(/^\//,'')
        #path = cgi.params['path'] if path.empty?
        type = File.extname(path)
        name = path.chomp(type)
        name = 'index' if name == ''
        type = '.html' if type == ''
      else
        name = 'index'  # default configuration (configurable?)
        type = '.html'
      end

# if $DEBUG
  log "------------------------------------"
  log "cgi", cgi
  log "script", cgi.script_name
  log "path", path
  log "type", type
  log "name", name
#end

      #route = Route.new(routes[route])
      route = routes[name]

      status = 200  # default status

      case type
      when '.html'
        content, body = *route.page
      when '.js'
        content, body = *route.script
      when '.css'
        content, body = *route.style
      when '.json'
        content, body = *route.json
      when '.xml'
        content, body = *route.xml
      else
        # TODO: Proper Error Page
        status  = 400
        content = "text/html"
        body    = 'ERROR' # File.read('error/#{status.html}"
      end

      return status, {"Content-Type" => content}, body
    end

    #def page
    #  @html_page ||= <<-END
    # END
    #end

  end

  #
  #
  #

  class Config
    attr_accessor :path

    def self.load(site, file)
      if File.file?(file)
        data = YAML.load(File.new(file))
      else
        data = {}
      end
      new(site, data)
    end

    def initialize(site, data)
      @path = 'sodaweb'

      data.each do |k,v|
        send("#{k}=", v)
      end
    end
  end

  #
  #
  #

  class Routes
    attr :site
    attr :root
    attr :routes
    attr :config

    def self.load(site, file)
      new(site, YAML.load(File.new(file)))
    end

    def initialize(site, config)
      @site   = site
      @config = config
      @routes = {}
    end

    def [](path)
      return nil unless config.key?(path)
      routes[path] ||= Route.new(site, path, config[path])
    end
  end

  #
  #
  #

  class Route
    attr :site
    attr :root
    attr :path

    attr :title
    attr :icon
    attr :layout
    attr :template
    attr :styles

    attr :actions
    attr :scripts
    attr :events

    attr :feeds

    # Database access.
    attr :server
    attr :database
    attr :username
    attr :password

    attr :context

    #

    def initialize(site, path, settings)
      @site  = site
      @root  = site.root
      @path  = path

      # view
      @title    = settings['title']
      @icon     = settings['icon']
      @layout   = settings['layout']
      @template = settings['template']
      @styles   = settings['styles']

      # controls
      @actions = [settings['actions']].flatten  # server side  # NOTE Shoulo this trigger an action NOW!?
      @scripts = [settings['scripts']].flatten  # client side
      @events  = [settings['events']].flatten   # client side *

      # model
      @feeds   = settings['feeds']

      # database
      @server   = settings['server']
      @database = settings['database']
      @username = settings['username']
      @password = settings['password']  # Security issue!

      # context
      # TODO: (should this be per site, or per route?)
      @context = Context.new(site.cgi)
    end

    # Match route to URI.

    def match?(url)
      path == url  #Regexp.new(path).match(url)
    end

    #

    def log(*args)
      site.log(*args)
    end

    # Template
    #
    # Support for rhtml, redcloth, html, etc...?

    def page
      #if layout
      #  layout = File.read(File.join(root, layout))
      #else
      #  layout = File.read(File.join(root, layout))
      #end
      # TODO: layout + title + icon + template
      body = File.read(File.join(root, template))
      body = page_layout(title, path, body)

      return "text/html", body
    end

    # Style

    def style
      css = ''
      styles.each do |file|
        css << File.read(File.join(root, file)) << "\n\n"
      end
      return "text/css", css
    end

   # Script

    def script
      script = ''
      (basescripts + scripts).uniq.each do |s|
        script << File.read(s) << "\n\n"
      end
      return "text/javascript", script
    end

    def basescripts
      SCRIPTS.collect{ |script| File.join(site.config.path, script) }
    end

    # XML Data

    def xml
      output = ''
      feeds.each do |feed|
        data = File.read(File.join(root,feed))
        data = context.render(data)        # interpolate cgi parameters

        case (type = File.extname(feed))
        when '.xml'
          output << data
        #when '.json'
        #  output << json2xml(data)
        #when '.yaml'
        #  output << yaml2xml(data)
        when '.sql'
          output << sql2xml(data)
        else
          # raise "unsupported data source type #{type} for xml."
        end
      end
      return "text/xml", output
    end

    # JSON Data

    def json
      output = []
      feeds.each do |feed|
        data = File.read(File.join(root,feed))
        data = context.render(data)       # interpolate cgi parameters

        case (type = File.extname(feed))
        #when '.xml'
        #  output << xml2json(data)
        when '.json'
          output << data
        when '.yaml'
          output << yaml2json(data)
        when '.sql'
          output << sql2jsonl(data)
        else
          # raise "unsupported data source type #{type} for json."
        end
      end
      return "text/xml", output
    end

    #

    def yaml2json(data)
      YAML::load(data).to_json
    end

    #

    def sql2json(data)
      rec = sql_query(data)
      rec.to_json
    end

    # TODO How does to_xml work here? Could that work for json->xml too?

    def sql2xml(data)
      rec = sql_query(data)
      rec.to_xml
    end

    # SQL query using DBI,

    def sql_query(sql)
      rec = []
      begin
        dbh = DBI.connect("DBI:#{server}:#{database}:localhost", username, password)
        sth = dbh.execute(sql)
        while row = sth.fetch do
          rec << row.to_h
        end
        sth.finish
      rescue DBI::DatabaseError => e
        # FIXME: How to handle error here?
        cgi.out('status'=> "405 Method Not Allowed", 'type' => 'text/plain') do
          "Error code: #{e.err}\n" +
          "Error message: #{e.errstr}\n"
        end
        rec = nil
      ensure
        dbh.disconnect if dbh
      end
      return rec
    end

    #

    def page_layout(title, path, body)
      <<-END
      <html>
      <head>
        <title>#{title}</title>
        <link REL="shortcut icon" HREF="sodaweb/img/cherry-sm.png" />
        <link REL="stylesheet" HREF="#{path}.css" TYPE="text/css" />

        <script language="javascript" src="#{path}.js"></script>
        <script>
          $(document).ready(function(){
            $.cherry_ajax("#{path}.xml");
          });
        </script>
      </head>
      <body>
        #{body}
      </body>
      </html>
      END
    end

#     # Build response.
#
#     def response
#       r = {
#         'page'   => page,
#         'events' => events,
#         'data'   => data
#       }.to_json
#       #r.compress!
#       return r
#     end


#     def respond(request)
#       page = Page.new(
#         :template   => view_template,
#         :layout     => view_layout,
#         :style      => view_style,
#         :behavior   => action_behavior,
#         :controller => action_controller,
#         :feeds      => feeds
#       )
#       body = page.render
#
#       return 200, {"Content-Type" => "text/html"}, body
#     end

  end

  # This is the binding context int which Erb is evaluated.
  #
  # Eventually this could be extensible providing server-side scripts.

  class Context

    def initialize(cgi)
      @cgi = cgi
    end

    def render(data)
      template = ERB.new(data)
      template.result(binding)
    end

    def method_missing(s, *a, &b)
      @cgi.params[s.to_s]
    end

  end


  #

  STATUS = {
    200 => "OK",                  # "200 OK"
    206 => "PARTIAL_CONTENT",     # "206 Partial Content"
    300 => "MULTIPLE_CHOICES",    # "300 Multiple Choices"
    301 => "MOVED",               # "301 Moved Permanently"
    302 => "REDIRECT",            # "302 Found"
    304 => "NOT_MODIFIED",        # "304 Not Modified"
    400 => "BAD_REQUEST",         # "400 Bad Request"
    401 => "AUTH_REQUIRED",       # "401 Authorization Required"
    403 => "FORBIDDEN",           # "403 Forbidden"
    404 => "NOT_FOUND",           # "404 Not Found"
    405 => "METHOD_NOT_ALLOWED",  # "405 Method Not Allowed"
    406 => "NOT_ACCEPTABLE",      # "406 Not Acceptable"
    411 => "LENGTH_REQUIRED",     # "411 Length Required"
    412 => "PRECONDITION_FAILED", # "412 Precondition Failed"
    500 => "SERVER_ERROR",        # "500 Internal Server Error"
    501 => "NOT_IMPLEMENTED",     # "501 Method Not Implemented"
    502 => "BAD_GATEWAY",         # "502 Bad Gateway"
    506 => "VARIANT_ALSO_VARIES"  # "506 Variant Also Negotiates"
  }

  SCRIPTS = [
    "js/xml2json.js",
    "js/parseuri.js",
    "js/support.js",
    "js/jquery.js",
    "js/jquery.cherry.js"
  ]

end

#if $0 == __FILE__
#  puts "here"
#else

  cgi  = CGI.new('html4')
  site = Soda::Site.new(cgi)
  status, content, body = *site.start
  cgi.out(content) { body }

#end

#   index: {
#     route: '/',
#     title: 'Your Site',
#     view: {
#       layout: 'standard.html',
#       template: 'home.html',
#       styles: [
#         'stars.css'
#       ]
#     },
#     action: {
#       controller:  '',
#       behaviors: [ 'home.json' ]
#     },
#     feeds: [ 'posts.xml' ]
#   }
# };
#
