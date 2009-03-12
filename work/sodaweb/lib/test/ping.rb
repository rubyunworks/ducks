#!/usr/bin/env ruby

# Ruby CGI script that simple
# dumps the CGI evnironment.

require 'cherry.rb'

require 'yaml'
require 'cgi'

cgi = CGI.new('html4')

vars = %w{
  AUTH_TYPE               HOST                REMOTE_IDENT
  CONTENT_LENGTH          NEGOTIATE           REMOTE_USER
  CONTENT_TYPE            PRAGMA              REQUEST_METHOD
  GATEWAY_INTERFACE       REFERER             SCRIPT_NAME
  ACCEPT                  USER_AGENT          SERVER_NAME
  ACCEPT_CHARSET          PATH_INFO           SERVER_PORT
  ACCEPT_ENCODING         PATH_TRANSLATED     SERVER_PROTOCOL
  ACCEPT_LANGUAGE         QUERY_STRING        SERVER_SOFTWARE
  CACHE_CONTROL           REMOTE_ADDR
  FROM                    REMOTE_HOST
}

data = vars.collect{ |v| "#{v.downcase}: #{cgi.send(v.downcase)}" }


s = %{
<html>
<head>
  <title>Cherry Ping</title>
</head>
<body>
<h1>Cherry Ping</h1>
<h2>Parameters/Cookies</h2>
<pre>
}

s += CGI::escapeHTML(
  "params: " + cgi.params.inspect + "\n" +
  "cookies: " + cgi.cookies.inspect + "\n\n"
)

s += %{
</pre>
<h2>Environment</h2>
<pre>
}

s += CGI::escapeHTML(
  ENV.collect do |key, value|
    key + " --> " + value + "\n"
  end.join("")
)

s += %{
</pre>
<h2>Attributes</h2>
<pre>
}

s += CGI::escapeHTML(data.join("\n"))

s += %{
</pre>
<h2>Configuration</h2>
<pre>
}

s += $configuration.to_yaml

s += %{
</pre>
</body>
</html>
}

cgi.out{s}

