require File.dirname(__FILE__) + '/server.rb'

require 'rack/request'
require 'rack/response'

#use Rack::ShowExceptions
run Cherry::Server.new

