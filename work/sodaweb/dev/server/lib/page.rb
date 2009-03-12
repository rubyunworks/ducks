
module Cherry

  class Page
    attr_accessor :title

    attr_accessor :layout
    attr_accessor :template
    attr_accessor :style

    attr_accessor :behavior
    attr_accessor :controller

    attr_accessor :feeds

    def initialize(keys)
      keys.each do |k,v|
        send("#{k}=", v) rescue nil
      end
    end

    def feed() feeds[0] end

    def render
      raise unless layout
      raise unless feed

      return html
    end

    def html
      h = view_layout
      h.sub!("$head$", html_head)
      h.sub!("$body$", html_body)
      h
    end

    def html_head
      "<head>"             <<
      html_head_title      <<
      html_head_style      <<
      html_head_javascript <<
      "\n</head>\n"
    end

    def html_head_title
      %{
        <title>#{title}</title>
      }
    end

    def html_head_style
      %{
        <link rel="stylesheet" href="views/styles/#{style}">
      }
    end

    def html_head_javascript
      %{
   <!-- <script language="javascript" src="server/javascript/test.js"></script> -->

        <script language="javascript" src="server/javascript/jquery-latest.js"></script>
        <script language="javascript" src="server/javascript/jquery.cherry.js"></script>

        <script language="javascript" src="actions/behaviors/#{behavior}"></script>

        <script language="javascript">
            $(document).ready(function() { $.cherry_ajax("feeds/#{feed}"); });
        </script>
      }
    end

    def html_body
      "<body>\n#{view_template}\n</body>\n"
    end

    # views

    def view_layout
      @view_layout ||= File.read("#{Cherry.root}/views/layouts/#{layout}")
    end

    def view_template
      @view_template ||= File.read("#{Cherry.root}/views/templates/#{template}")
    end

    #def view_style
    #  @view_style ||= File.read("#{Cherry.root}/view/styles/#{style}")
    #end

  end

end

