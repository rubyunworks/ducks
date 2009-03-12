require 'rinq/expression'

module RINQ

  def self.select(&blk)
    q = Query.new
    q.instance_eval(&blk)
    q
  end

  class Query

    def initialize
      @from = {}
    end

    def from(map)
      @from = map
    end

    def where(cond)
      @where = cond
    end

    def select(*map)
      @select = map
    end

    def method_missing(m, *args)
      if args.length == 0 && @from[m]
        VariableExpression.new(m)
      else
        super
      end
    end

    def to_sql
      "SELECT #{ return_list } " \
      "FROM #{ table_list } " \
      "WHERE #{ condition_expr };"
    end

    def table_list
      @from.map{ | v, t | "#{ t } AS #{ v }" }.join(", ")
    end

    def return_list
      @select.map{ | r | r.to_sql }.join(",")
    end

    def condition_expr
      @where.to_sql
    end

  end

end

