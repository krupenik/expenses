class TagsController < ApplicationController
  class ExpressionParseError < Exception; end

  before_filter :authenticate_user!

  def index
    @tags = Tag.all(:include => :entries, :conditions => Entry.created_at_conditions(*session[:context][:date][1])).sort_by(&:name)
    @tags_appearance_rates = Hash[@tags.map{ |i| [i.id, i.entries.size] }]
    @tags_expenses = Hash[@tags.map{ |i| [i.id, i.entries.map{ |i| i.amount if i.amount < 0 }.compact.inject{ |a, e| a + e }.to_f.abs]}].reject{ |k, v| 0 == v }
  end

  def show
    @tag_list = params[:id].gsub(/\s*([!|])\s*/, ' \1 ').gsub(/\s*(,)\s*/, '\1 ')
    @entries = []
    begin
      e = parse_tag_expr(@tag_list)
      tags = Hash[Tag.find_all_by_name(e.reject{ |i| i =~ /[!\(\)|,]/ }.compact,
        :include => {:entries => :tags}, :conditions => Entry.created_at_conditions(*session[:context][:date][1])
        ).map{ |i| [i.name, i.entries] }]
      stack = []
      e.each do |i|
        case i
        when /[!|,]/
          o1 = stack.pop
          o2 = stack.pop
          if o1.nil? or o2.nil?
            raise ExpressionParseError, "missing arguments to '#{i}'"
          end
          case i
          when '!' then stack << (o2 - o1)
          when '|' then stack << (o2 + o1)
          when ',' then stack << (o2 & o1)
          end
        else
          stack << tags[i]
        end
      end
      @entries = stack.flatten.uniq

      if 'expenses' == session[:context][:type]
        @entries.reject!{ |i| i.amount > 0 }
      elsif 'incomings' == session[:context][:type]
        @entries.reject!{ |i| i.amount < 0 }
      end

      @entries.compact!
    rescue ExpressionParseError => e
      flash[:alert] = "Expression parse error: #{e.to_s}!"
    end
  end

  private

  def parse_tag_expr(s)
    ops = []
    ret = []
    s.gsub(/\s*([()!|,])\s*/, '\1').split(/([()!|,])/).reject{ |i| '' == i }.each do |i|
      if %w[( ) ! | ,].include?(i)
        case i
        when '(' then ops << i
        when ')'
          while ops.last != '('
            ret << ops.pop
            if ops.empty?
              raise ExpressionParseError, "'#{s}' contains unbalanced parentheses"
            end
          end
          ops.pop
        when /[!|,]/
          while ops.last =~ /[!|,]/
            ret << ops.pop
          end
          ops << i
        end
      else
        ret << i
      end
    end

    until ops.empty?
      if %w[( )].include?(ops.last)
        raise ExpressionParseError, "'#{s}' contains unbalanced parentheses"
      end
      ret << ops.pop
    end

    ret
  end
end
