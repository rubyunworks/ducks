function Demo(){
  self=this;
  self.instanceVariables={};
  self.instanceVariables['@clicks']=Number(0);
  Number(3).times(function(){
    self.puts("Hello! I am a Ruby script!")
  })
}
Demo.prototype = {
  puts: function(str){
    self=this;
    document.getElementById("debug")["innerHTML"]=document.getElementById("debug")["innerHTML"]+str+"\n"
  },
  clicked: function(){
    self=this;
    self.instanceVariables['@clicks']=self.instanceVariables['@clicks']+Number(1);
    self.puts("Click number "+self.instanceVariables['@clicks'].toString())
  }
}
