require 'cherry/page'

module Cherry
  class Route
    attr :route

    attr :view_template
    attr :view_layout
    attr :view_style

    attr :action_behavior
    attr :action_controller

    attr :feeds

    def self.load(file)
      new(YAML.load(File.new(file)))
    end

    def initialize(settings)
      @route = settings['route']

      @view_template = settings['view']['template']
      @view_layout   = settings['view']['layout']
      @view_styles   = settings['view']['style']

      @action_behavior   = settings['action']['behavior']
      @action_controller = settings['action']['controller']

      @feeds = settings['feeds']
    end

    def match(url)
      @route == url
      #Regexp.new(@route).match(url)
    end

    def respond(request)
      page = Page.new(
        :template   => view_template,
        :layout     => view_layout,
        :style      => view_style,
        :behavior   => action_behavior,
        :controller => action_controller,
        :feeds      => feeds
      )
      body = page.render

      return 200, {"Content-Type" => "text/html"}, body
    end

  end
end

