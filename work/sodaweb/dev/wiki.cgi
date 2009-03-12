#!/usr/bin/ruby

# wiki.cgi

require 'cgi'

HOME = 'HomePage'
LINK = 'wiki.cgi?name=%s'

query = CGI.new 'html4'

# fetch query data
page_name    = if query['name'] == '' then HOME else query['name'] end
page_changes = query['changes']

# fetch file content for this page, unless it's a new page
content = File.read(page_name) rescue content = ''

# save page changes, if needed
unless page_changes == ''
  content = CGI.escapeHTML(page_changes)
  File.open(page_name, 'w') { |f| f.write content }
end

# output requested page
query.instance_eval do
  out do 
    h1 { page_name } +
    a(LINK % HOME) { HOME } +
    pre do            # content area
      content.gsub(/([A-Z]\w+){2}/) do |match|
        a(LINK % match) { match }
      end
    end +
    form('get') do    # update from
      textarea('changes') { content } +
      hidden('name', page_name) +
      submit
    end
  end
end
