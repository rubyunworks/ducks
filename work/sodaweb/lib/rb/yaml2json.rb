#!/usr/bin/env ruby

# Simple Ruby CGI script that opens a yaml file
# and converts it to JSON.

require 'cgi'
require 'yaml'
require 'open-uri'

require 'rubygems'
require 'blow/json'

cgi = CGI.new('html4')

host  = 'http://' + cgi.host  # TODO protocol?
path = cgi.path_info.sub(/^\//,'')
#path = cgi.params['path'][0]

resource = URI.join(host, path)

#cgi.out(){ resource.to_s }

data = YAML::load(open(resource))
#data = YAML::load(File.new(path))

cgi.out('nph' => true, 'type' => 'text/x-json'){ data.to_json }
