
module Cherry

  module HtmlResponse
    extend self

    def html(keys={})
      raise unless keys[:layout]
      raise unless keys[:feed]

      page = ''
      page << html_header(keys)
      page << html_body(keys)
      page << html_footer

      return page
    end

    def html_header(keys)
      header = ''
      header << %{<html>\n<head>}
      header << %{<title>#{keys[:title]}</title>}
      header << %{<link rel="stylesheet" href="../styles/#{keys[:style]}">\n} if keys[:style]
      header << %{<script language="javascript" src="../javascript/jquery-latest.js"></script>\n}
      header << %{<script language="javascript" src="../javascript/jquery.cherry.js"></script>\n}
      header << %{<script language="javascript" src="../behaviors/#{keys[:behvaior]}"></script>\n} if keys[:behavior]
      header << %{
          <script language="javascript">
            $(document).ready(function() { $.cherry_ajax("../feeds/#{keys[:feed]}"); });
          </script>
      }
      header << %{</head>\n}
      header
    end

    def html_body(layout)
      body = File.read("../layouts/#{layout}")
      "<body>#{body}</body>"
    end

    def html_footer
      "</html>"
    end

  end

end
