# Ducks Web Application

page 'index' do

  title "Ducks Demo"

  style 'default.css'

  style do
    h1 do
      color 'green'
    end
    title do
      font_size '1.1em'
    end
  end

  function :fly do
    alert('here');
    e = document.getElementById('duck')
    e[:style][:font_size] = '100px'
    # jQuery('.duck').hide();
  end

  remote :pic do |opts|
    @a ||= 0
    return "Hello World #{@a += 1}", 'text/plain'
  end

  method :bye do |opts|
    "Good Bye!"
  end

  body do
    #div.title "Ducks Demo"
    h1 "Your the Wobbles with Ducks!", :class => 'title'
    p %{ Trouble is web feet make for hard walks. What we need
         is wings. }

    h2 "WINGS", :id => 'duck'

    button "On Click", :onclick=>"fly();"

    p %{ Copyright (c) 2008 TigerOps }
  end

end

