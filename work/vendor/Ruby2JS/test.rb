require 'rb2js'

class DemoClass
  def cond(arg)
    if arg == 0
      return 1
    else
      return 0
    end
  end
  
  def ary
    my_array = []
    my_array << 3
    return my_array
  end
  
  def strings(s, t)
    return [s, t].join(' ')
  end
  
  def hsh
    h = {'a' => 1, :b => 2}
    h['foo'] = 'bar'
    return h['foo']
  end
  
  def asgn
    h = OpenStruct.new
    h.foo = bar
  end
  
  def iter
    a = [1,2,3]
    a.each do |x|
      self.cond(x)
    end
    a.each_with_index do |x, i|
      self.strings(x.to_s, i.to_s)
    end
  end
  
  def puts(str)
    `document.getElementById('debug')`.innerHTML = str
  end
end

puts RB2JS.class_to_js(DemoClass, :debug => true)