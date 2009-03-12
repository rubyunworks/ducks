# File IO RESTful interface shared library.
#
# TODO Must add authentication to this!

require 'cgi'
require 'dbi'

module Cherry

  class DatabaseService
    attr_reader :database, :table, :record

    def initialize

      cgi  = CGI.new('html4')
      root = ENV['DOCUMENT_ROOT']

      config = YAML.load(File.new(File.join(root, 'config', 'database.yaml')))

      server = config[database]['server']

      user = cgi.params['user']  # TODO Use proper https authentication.
      pass = cgi.params['pass']

      where = cgi.params['where']
      sql   = cgi.params['sql']

      path = cgi.path_info.sub(/^\//,'')

      if path.empty?
        @database = cgi.params['database']
        @table    = cgi.params['table']
        @record   = cgi.params['record']
      else
        @database, @table, @record = *path.split('/')
      end




case cgi.request_method
when 'GET', 'POST'
  sql = "SELECT " + sql
  data = query(server, database, user, pass, sql)
  cgi.out('type' => 'text/plain'){ data }
when 'POST'
  sql = "INSERT " + sql
  data = query(server, database, user, pass, sql)
  cgi.out('status'=> "OK", 'type' => 'text/plain'){ "OK" }
when 'PUT'
  sql = "UPDATE " + sql
  data = query(server, database, user, pass, sql)
  cgi.out('status'=> "OK", 'type' => 'text/plain'){ "OK" }
when 'DELETE'
  sql = "DELETE " + sql
  data = query(server, database, user, pass, sql)
  cgi.out('status'=> "OK", 'type' => 'text/plain'){ "OK" }
end

def query(server, database, user, pass, sql)
  begin
    # connect to the MySQL server
    dbh = DBI.connect("DBI:#{server}:#{database}:localhost", user, pass)
    # get server version string and display it
    sth = dbh.execute(sql)
    rec = []
    while row = sth.fetch do
      rec << row.to_h
    end
    sth.finish
  rescue DBI::DatabaseError => e
    puts "An error occurred"
    puts "Error code: #{e.err}"
    puts "Error message: #{e.errstr}"
  ensure
    # disconnect from server
    dbh.disconnect if dbh
  end