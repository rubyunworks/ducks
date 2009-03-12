require 'rb2js'

class Demo
  
  def initialize
    @clicks = 0
    3.times{ self.puts('Hello! I am a Ruby script!') }
  end
  
  def puts(str)
    document.getElementById('debug')['innerHTML'] = 
      document.getElementById('debug')['innerHTML'] + str + "\n"
  end
    
  def clicked
    @clicks += 1
    self.puts("Click number " + @clicks.to_s)
  end
  
end

File.open('demo.js', 'w') do |io| 
  io << RB2JS.class_to_js(Demo, :debug => true, :pretty_print => true)
end

