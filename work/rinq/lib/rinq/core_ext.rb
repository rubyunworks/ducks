
class String

  def to_sql
    "'#{self}'"
  end

end

class Symbol

  def to_sql
    "'#{self}'"
  end

end

class Regexp

  def to_sql
    to_s
  end

end

