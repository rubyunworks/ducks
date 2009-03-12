module RINQ

  def self.update( map, &blk )
    q = Update.new
    q.update(map)
    q.instance_eval(&blk)
    q
  end

  class Update

    def initialize
      @update = {}
    end

    def update( map )
      @update = map
    end

    def set(map)
      @set = map
    end

    def where( cond )
      @where = cond
    end

    def method_missing(m, *args)
      if args.length == 0 && @update[m]
        VariableExpression.new(m)
      else
        super
      end
    end

    def to_sql
      "UPDATE #{ table_list } " \
      "SET #{ set_list } " \
      "WHERE #{ condition_expr };"
    end

    def table_list
      @update.map{ | v, t | "#{ t } AS #{ v }" }.join(", ")
    end

    def set_list
      @set.map{ | r, t | "#{ r.to_sql }=#{t.to_sql}"}.join(", ")
    end

    def condition_expr
      @where.to_sql
    end

  end

end
