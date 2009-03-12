-- load driver
require "luasql.sqlite"
-- create environment object
env = assert (luasql.sqlite())
-- connect to data source
con = assert (env:connect("luasql-test"))
-- reset our table
res = con:execute"DROP TABLE people"
res = assert (con:execute[[
  CREATE TABLE people(
    name  varchar(50),
    email varchar(50)
  )
]])
-- add a few elements
list = {
  { name="Jose das Couves", email="jose@couves.com", },
  { name="Manoel Joaquim", email="manoel.joaquim@cafundo.com", },
  { name="Maria das Dores", email="maria@dores.com", },
}
for i, p in pairs (list) do
  res = assert (con:execute(string.format([[
    INSERT INTO people
    VALUES ('%s', '%s')]], p.name, p.email)
  ))
end
-- retrieve a cursor
cur = assert (con:execute"SELECT name, email from people")
-- print all rows, the rows will be indexed by field names
row = cur:fetch ({}, "a")
while row do
  print(string.format("Name: %s, E-mail: %s", row.name, row.email))
  -- reusing the table of results
  row = cur:fetch (row, "a")
end
-- close everything
cur:close()
con:close()
env:close()

