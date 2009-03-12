#!/usr/bin/env ruby

# File IO RESTful interface.
#
# TODO Must add authentication to this!

require 'cgi'
require 'dbi'

cgi  = CGI.new('html4')
root = ENV['DOCUMENT_ROOT']

conn = {}
path = cgi.path_info.sub(/^\//,'')
if path.empty?
  database = cgi.params['database']
  server   = cgi.params['server']
else
  database = File.filename(path)
  server   = File.filename(File.dirname(path))
end

sql  = cgi.params['sql']
user = cgi.params['user']  # TODO Use proper https authentication.
pass = cgi.params['pass']

def query(server, database, user, pass, sql)
  rec = []
  begin
    dbh = DBI.connect("DBI:#{server}:#{database}:localhost", user, pass)
    sth = dbh.execute(sql)
    while row = sth.fetch do
      rec << row.to_h
    end
    sth.finish
  rescue DBI::DatabaseError => e
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

case cgi.request_method
when 'GET'
  sql = "SELECT " + sql
  rec = query(server, database, user, pass, sql)
  cgi.out('type' => 'text/x-json'){ rec.to_json } if rec
when 'POST'
  sql = "SELECT " + sql
  rec = query(server, database, user, pass, sql)
  cgi.out('type' => 'text/x-json'){ rec.to_json } if rec
when 'PUT'
  cgi.out('status'=> "405 Method Not Allowed", 'type' => 'text/plain'){ "405 Method Not Allowed" }
when 'DELETE'
  cgi.out('status'=> "405 Method Not Allowed", 'type' => 'text/plain'){ "405 Method Not Allowed" }
end
