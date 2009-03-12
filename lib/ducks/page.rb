module Ducks
  require 'ducks/html'
  require 'ducks/css'
  require 'ducks/script'
  require 'ducks/service'
  #require 'ducks/remote'

  ### = Page
  ###
  ### The page class can represent nearly any HTML document. There are,
  ### however, some limitations.
  ###
  ### * Scripts cannot be inline. They can only come before or after the body.
  ###   This will probably need to be address ultimately, but requires either
  ###   augments Markaby and Builder, or replacing them.
  ### *
  ###
  ### TODO: Add postscritps.
  ###
  class Page

    attr :app
    attr :name
    attr :icon
    attr :title

    attr :styles
    attr :scripts
    attr :services

    attr :service_class

    attr :build_extension

    #
    def initialize(app, name, code=nil, &block)
      @app      = app
      @name     = name
      #@remotes  = []

      @styles   = []
      @scripts  = []
      @services = []

      @service_class = Class.new do
        class << self
          public :include
          public :define_method
        end
      end

      @build_extension = Module.new

      code ? instance_eval(code, __FILE__, __LINE__) : instance_eval(&block)
    end

    # Access Pages services.
    def service
      @service ||= service_class.new
    end

    # Page title
    def title(string=nil)
      string ? @title = string : @title
    end

    # Page icon
    def icon(icon_file=nil)
      icon_file ? @icon = icon_file : @icon
    end

    #def head(&block)
    #  @head ||= Html.new.head(&block)
    #end

    # Page Body (HTML)
    # TODO: bodies (?)
    def body(attrs={}, &block)
      @body ||= (
        Html.new(self){ body(attrs, &block) }
      )
    end

    # Stylesheet (CSS)
    def style(href=nil, opts=nil, &block)
      case href
      when Style
        @styles << href
      else
        @styles << Style.new(href, opts, &block)
      end
    end

    # Client-side scripting (Javascript).
    # TODO: remove duplicate file scripts (?)
    def script(src=nil, opts=nil, &block)
      case src
      when Script
        @scripts << src
      else
        @scripts << Script.new(src, opts, &block)
      end
    end

    # Client-side procedure (Javascript).
    def function(name, &block)
      @scripts << Script.new{} if @scripts.empty?
      @scripts.last.define_function(name, &block)
    end

    # Client-side remote procedure call to server-side function.
    # TODO: Should track remotes so only they can be remotely called.
    def remote(name, &block)
      #@remotes << Remote.new(name, &block)
      @scripts << Script.new{} if @scripts.empty?
      @scripts.last.define_ajax_function(name)
      @service_class.define_method(name, &block)
    end

    # Server-side scripting.
    def serve(mod=nil, &block)
      case mod
      when Service, Module
        @services << mod
        @service_class.include mod
      else
        mod = Service.new(&block)
        @services << mod
        @service_class.include mod
      end
    end

    # Server-side procedure.
    def method(name, &block)
      @service_class.define_method(name, &block)
    end

    # Server-side procedure.
    def define(name, &block)
      @build_extension.module_eval do
        define_method(name, &block)
      end
    end

    # Convert page to HTML document.
    def to_html
      h = []
      h << "<html>"
      h << "<head>"

        if icon
          h << %[<link rel="SHORTCUT ICON" href="#{icon}">]
        end

        styles.each do |s|
          h << s.to_html(self)
        end

        scripts.each do |s|
          h << s.to_html(self)
        end

        #remotes.each do |remote|
        #  s << "<script>\n#{remote}\n</script>"
        #end

      h << "</head>"

      h << body.to_s

      h << "</html>"

      h.join("\n")
    end

    alias_method :to_s, :to_html

    def href(href)
      if href =~ /^\//
        app.env['rack.url_scheme'] + '://' + app.env['HTTP_HOST'] + href
      else
        href
      end
    end

  end # class Page
end # module Ducks

