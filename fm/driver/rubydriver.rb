
require 'fm/class'
require 'erb'
module FM
  module Driver
    class RubyDriver < DriverBase
      def dump_all
        @reserved = [:int,:long,:double]
        ERB.new(::FM::Heredoc::Ruby::Class_template).result(binding)
      end

      def dump_sign(elem)
        "#{elem[:name]}#{dump_args(elem[:args])} -> #{elem[:return] ? elem[:return] : 'nil'}"
      end

      def dump_args(args)
        if args
          "(" + args.map {|elem|
            "#{elem[:name]}"
          }.join(", ") + ") # (" + 
          args.map {|elem|
            "#{elem[:type]}"
          }.join(", ") + ")"
        else
          " # nil"
        end
      end
    end
  end

  module Heredoc
    module Ruby
Class_template=<<RUBY_CLASS_END
<%for dep in @info[:deps]%>
<%unless @reserved.include? dep.to_sym %>require '<%=dep%>'<%end%><%end%>

class <%=@info[:self]%><%= (@info[:parent])? " < " : ""%><%=@info[:parent]%>
<%for elem in @info[:comps]
  if elem[:acl]
    prefix = "";
    case elem[:acl]
    when /rw|wr/
      prefix = "attr_accessor :"
    when "r"
      prefix = "attr_reader :"
    when "w" 
      prefix = "attr_writer :"
    end%>
  <%=prefix+elem[:name]%><%end
end
%>

  def initialize<%for elem in @info[:comps]%>
    @<%=elem[:name]%>=<%=elem[:type]%>.new<%end%>
  end
<%for mtd in @info[:methods][:public]%>
  def <%=dump_sign(mtd)%>

  end<%end%>

<%for mtd in @info[:methods][:static]%>
  def self.<%=dump_sign(mtd)%>

  end<%end%>
<%for mtd in @info[:methods][:alias]%>
  alias_method :<%=mtd[:name]%>,:<%=mtd[:alias]%>
<%end%>

private
<%for mtd in @info[:methods][:private]%>
  def <%=dump_sign(mtd)%>

  end<%end%>
end
RUBY_CLASS_END
    end
  end
end