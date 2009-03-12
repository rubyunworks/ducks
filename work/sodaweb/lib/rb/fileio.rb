#!/usr/bin/env ruby

# File IO RESTful interface.
#
# TODO Must add authentication to this!

require 'cgi'

cgi  = CGI.new('html4')
root = ENV['DOCUMENT_ROOT']

path = cgi.path_info.sub(/^\//,'')
if path.empty?
  path = cgi.params['path']
end

file = File.join(root, path)

case cgi.request_method
when 'GET'
  data = File.read(file)
  cgi.out('type' => 'text/plain'){ data }
when 'POST'
  content = cgi.params['content']
  File.open(file, 'wb'){ |f| f << content }
  cgi.out('status'=> "OK", 'type' => 'text/plain'){ "OK" }
when 'PUT'
  content = cgi.params['content']
  File.open(file, 'wb'){ |f| f << content }
  cgi.out('status'=> "OK", 'type' => 'text/plain'){ "OK" }
when 'DELETE'
  FileUtils.rm(file)
  cgi.out('status'=> "OK", 'type' => 'text/plain'){ "OK" }
end
