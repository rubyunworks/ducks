require 'cherry/server'

require 'rack/request'
require 'rack/response'

#use Rack::ShowExceptions
run Cherry::Server.new

