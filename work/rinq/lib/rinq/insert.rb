module RINQ

  def self.insert(&blk)
    q = Insert.new
    q.instance_eval(&blk)
    q
  end

  class Insert

    def initialize
      @into = {}
      @columns = nil
    end

    def into(map)
      @into = map
    end

    def columns(*list)
      @columns = list
    end

    def values(*list)
      @values = list
    end

    def where(cond)
      @where = cond
    end

    def method_missing(m, *args)
      if args.length == 0 && @into[m]
        VariableExpression.new(m)
      else
        super
      end
    end

    def to_sql
      s = ''
      s << "INSERT INTO #{ table_list } "
      s << "(#{ columns_list }) " if @columns
      s << "VALUES #{ values_list } "
      s << "WHERE #{ condition_expr };"
      s
    end

    def table_list
      @into.map{ |v, t| "#{ t } AS #{ v }" }.join(", ")
    end

    def columns_list
      @columns.map{ |c| "#{ c.to_sql }"}.join(", ")
    end

    def values_list
      @values.map{ |v| "#{ v.to_sql }"}.join(", ")
    end

    def condition_expr
      @where.to_sql
    end

  end

end

