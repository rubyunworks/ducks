require 'rinq/core_ext'

class Expression

  def ==( other )
    BinaryOpExpression.new( self, other, '=' )
  end

  #def ===( other )
  #  BinaryOpExpression.new( self, other, 'IN?' )
  #end

  def >( other )
    BinaryOpExpression.new( self, other, '>' )
  end

  def <( other )
    BinaryOpExpression.new( self, other, '<' )
  end

  def >=( other )
    BinaryOpExpression.new( self, other, '>=' )
  end

  def <=( other )
    BinaryOpExpression.new( self, other, '<=' )
  end

  def &( other )
    BinaryOpExpression.new( self, other, 'AND' )
  end

  def |( other )
    BinaryOpExpression.new( self, other, 'OR' )
  end

  def =~( other )
    BinaryOpExpression.new( self, other, 'REGEXP' )
  end

  #def =~( other )
  #  BinaryOpExpression.new( self, other, 'LIKE' )
  #end

  def <=>( range )
    RangeExpression.new( self, range )
  end

  def method_missing( m, *args )
    if args.length == 0
      FieldExpression.new( self, m )
    else
      super
    end
  end

end

#
class VariableExpression < Expression

  attr_reader :varname

  def initialize( varname )
     @varname = varname
  end

  def to_sql
    @varname.to_s
  end

  def to_s
    @varname.to_s
  end

end

#
class FieldExpression < Expression

  def initialize( expression , field )
    @expression , @field = expression, field
  end

  def to_sql
    @expression.to_sql + '.' + @field.to_s
  end

end

#
class BinaryOpExpression < Expression

  def initialize( expr1 , expr2 , op )
    @expr1 , @expr2 , @op = expr1 , expr2 , op
  end

  def to_sql
    ex1 = @expr1.to_sql #Expression===@expr1 ? @expr1.to_sql : "#{@expr1.to_s}"
    ex2 = @expr2.to_sql #Expression===@expr2 ? @expr2.to_sql : "#{@expr2.to_s}"
    "#{ex1} #{@op} #{ex2}"
  end

end

#
class RangeExpression < Expression

  def initialize( expr, range )
    @expr, @range = expr, range
  end

  def to_sql
    ex = Expression===@expr ? @expr.to_sql : "'#{@expr.to_s}'"
    "#{ex} BETWEEN #{@range.begin} AND #{@range.end}"
  end

end


