require 'rubygems'
require 'parse_tree'

#
# Ruby to JavaScript
#
class RB2JS
  
  class Unhandled < RuntimeError ; end
  
  METHOD_TRANSLATIONS = {
    :<< => 'push',
    :index => 'indexOf',
    :rindex => 'lastIndexOf',
    :any? => 'some',
    :all? => 'every',
    :find_all => 'filter',
    :to_a => 'toArray',
    :to_s => 'toString',
    :each_with_index => 'each'
  }
  
  #
  # Initialize with S-expression sexp
  #
  def initialize(sexp, options = {})
    @sexp = sexp
    @options = options
  end
  
  #
  # Convert S-expression to JavaScript
  #
  def to_js
    handle(@sexp)
  end
  
  #
  # Convert a Ruby name to a JavaScript one (camelize, remove ?, change = to set*)
  #
  def mutate_name(name)
    name = name.to_s
    if (name =~ /(.*)=$/)
      name = "set_" << $1
    end
    if name =~ /^_[^_]/
      name.gsub!(/^_/, '')
    else
      name.gsub!(/_([a-z])/){ $1.upcase }
    end
    name.gsub(/\?$/, '')
  end
  
  def statement_list(statements)
    statements.map{ |a| handle(a) }.join(";")
  end
  
  def argument_list(arguments)
    arguments.map{ |a| handle(a) }.join(",")
  end
  
  def handle(sexp)
    $stderr.puts sexp.inspect if @options[:debug]
    operand = sexp.shift
    case operand
      
    when :defn
      fname = mutate_name(sexp.shift.to_s)
      if @options[:use_class_syntax]
        s = "#{fname}: function"
      else
        s = "function #{fname}"
      end
      body = sexp[0][1]
      raise Unhandled, "expected :block in :defn" unless body.shift == :block
      s << handle(body.shift)
      s << "{self=this;" << statement_list(body) << "}"
      s
      
    when :scope, :block
      "{" << statement_list(sexp) << "}"
      
    when :args
      "(" << sexp.map{ |a| a.to_s }.join(",") << ")"
      
    when :if
      s = "if(rb_true(" << handle(sexp.shift) << ")){" << handle(sexp.shift) << "}"
      unless sexp.empty?
        s << "else{" << handle(sexp.shift) << "}"
      end
      s
      
    when :lit
      v = sexp.shift
      if v.is_a?(Numeric)
        "Number(#{v})"
      else
        v.to_s
      end
      
    when :return
      "return " << handle(sexp.first)
      
    when :call
      receiver, method, args = sexp
      args ||= []
      args.shift
      case method
      when :==
        "(" << handle(receiver) << "===" << handle(args.shift) << ")"
      when :[]
        handle(receiver) << "[" << handle(args.shift) << "]"
      when :+, :-, :*, :/, :%
        handle(receiver) << method.to_s << handle(args.shift)
      when :new
        "new " << handle(receiver) << 
          "(" << argument_list(args) << ")" 
      else
        handle(receiver) << "." << (METHOD_TRANSLATIONS[method] || mutate_name(method)) << 
          "(" << args.map{ |a| handle(a) }.join(",") << ")" 
      end
      
    when :attrasgn
      receiver, method, args = sexp
      args.shift
      case method
      when :[]=
        handle(receiver) << "[" << handle(args.shift) << "]=" << handle(args.shift)
      else
        handle(receiver) << "." << mutate_name(method) << "(" << handle(args.shift) << ")"
      end
    
    when :iasgn
      "self.instanceVariables['#{sexp.shift.to_s}']=" << handle(sexp.shift)      
      
    when :array
      "[" << sexp.map{ |a| handle(a) }.join(',') << "]"
      
    when :lvar
      mutate_name(sexp.shift)
      
    when :ivar
      "self.instanceVariables['#{sexp.shift.to_s}']"
      
    when :lasgn
      "var " << mutate_name(sexp.shift) << "=" << handle(sexp.shift)
      
    when :zarray
      "new Array()"
      
    when :hash
      h = []
      until sexp.empty?
        h << [handle(sexp.shift), handle(sexp.shift)]
      end
      "{" << h.map{ |k,v| k << ':' << v }.join(',') << "}"
      
    when :str
      sexp.shift.inspect
      
    when :const
      sexp.shift.to_s
      
    when :vcall
      mutate_name(sexp.shift)
      
    when :iter
      iterator = sexp.shift
      vars = sexp.shift
      body = sexp
      raise Unhandled, 'expected :call in :iter' unless iterator.shift == :call
      receiver, method, args = iterator
      (args ||= []).shift
      handle(receiver) << 
        "." << (METHOD_TRANSLATIONS[method] || mutate_name(method)) << 
        "(" << (args.empty? ? '' : args.map{ |a| handle(a) }.join(',') + ',') << 
          "function(" << (vars ? [handle(vars)].flatten.join(',') : '') << "){" <<
          statement_list(body) << "}" <<
        ")" 
        
    when :dasgn, :dasgn_curr
      mutate_name(sexp.shift)
      
    when :masgn
      vars = sexp[0]
      raise Unhandled, "expected :array in :masgn" unless vars.shift == :array
      vars.map{ |a| handle(a) }
      
    when :self
      "self"
      
    when :dvar
      mutate_name(sexp.shift)
      
    when :fcall
      raise Unhandled, "can't perform method dispatch without explicit receiver"
      #"self." << mutate_name(sexp.shift)
            
    when :xstr
      sexp.shift
      
    else
      raise Unhandled, "unknown operand '#{operand}'"
    end
  end
  
  #
  # Convert a Ruby class to Javascript
  #
  def self.class_to_js(klass, options={})
    d = []
    init = ParseTree.new.parse_tree_for_method(klass, :initialize)
    if (init.first)
      # Bit of a hack here
      d << RB2JS.new(init, options).to_js.
           sub("function initialize", "function #{klass}").
           sub(/self=this/, "\\&;self.instanceVariables={}")
    else
      d << "function #{klass}(){self.instanceVariables={}}"
    end
    d << "#{klass}.prototype = {"
    d << (klass.instance_methods - klass.methods).map { |m|
      r = RB2JS.new(
        ParseTree.new.parse_tree_for_method(klass, m.to_sym), 
        options.merge(:use_class_syntax => true)
      ).to_js
    }.join(",\n")
    d << "}"
    js = d.join("\n")
    if (options[:pretty_print])
      return pretty_print(js)
    else
      return js
    end
  end
  
  def self.pretty_print(js)
    buf = ''
    indent = 0
    js.gsub!(/\{|;/, "\\0\n")
    js.gsub!(/\}/, "\n\\0")
    js.gsub!(/\{\s+\}/, "{}")
    js.gsub!(/(\s*\n)+/, "\n")
    js.split("\n").each do |line|
      indent -= 1 if line =~ /^\s*\}/
      buf << ("  " * indent) << line << "\n"
      indent += 1 if line =~ /\{$/
    end
    return buf
  end
  
end
