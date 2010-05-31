class TagsController < ApplicationController
  class ExpressionParseError < Exception; end

  before_filter :authenticate_user!

  def index
    @tags = Tag.all(:include => [:taggings, :entries]).sort_by(&:name)
    @tags_appearance_rates = Hash[@tags.map{ |i| [i.id, i.taggings.size] }]
    @tags_expenses = Hash[@tags.map{ |i| [i.id, i.entries.map{ |i| i.amount if i.amount < 0 }.compact.inject{ |a, e| a + e }.to_f.abs]}].reject{ |k, v| 0 == v }
  end
  
  def show
    @tag_list = params[:id].gsub(/\s*([!|])\s*/, ' \1 ').gsub(/\s*,\s*/, ', ')
    @entries = []
    begin
      e = parse_tag_expr(@tag_list)
      tags = Hash[Tag.find_all_by_name(e.reject{ |i| i =~ /[!\(\)|,]/ }.compact,
        :include => {:entries => :tags}).map{ |i| [i.name, i.entries] }]
      stack = []
      e.each do |i|
        case i
        when /[!|,]/
          o1 = stack.pop
          if o1.nil?: raise ExpressionParseError, "missing arguments to '#{i}'"; end
          o2 = stack.pop
          if o2.nil?
             if i != '!': raise ExpressionParseError, "missing second argument to '#{i}'"; end
             o2 = Entry.all(:include => :tags)
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

      if 'expenses' == params[:f_type]
        @entries.reject!{ |i| i.amount > 0 }
      elsif 'incomings' == params[:f_type]
        @entries.reject!{ |i| i.amount < 0 }
      end

      unless params[:f_created_at].blank?
        case params[:f_created_at]
        when 'date' then @entries.reject!{ |i| i.created_at < params[:f_created_at_s] || i.created_at > params[:f_created_at_f] }
        when 'week' then @entries.reject!{ |i| i.created_at < Date.today.beginning_of_week || i.created_at > Date.today.end_of_week }
        when 'yesterday' then @entries.reject!{ |i| i.created_at != Date.yesterday }
        when 'today' then @entries.reject!{ |i| i.created_at != Date.today }
        else
          if params[:f_created_at] =~ /^\d{4}\-\d{2}$/
            d = Date.strptime(params[:f_created_at], "%Y-%m")
            params[:f_created_at] = 'date'
            params[:f_created_at_s] = d.beginning_of_month
            params[:f_created_at_f] = d.end_of_month
            @entries.reject!{ |i| i.created_at < params[:f_created_at_s] || i.created_at > params[:f_created_at_f] }
          elsif params[:f_created_at] =~ /^\d{4}\-\d{2}\-\d{2}$/
            d = Date.strptime(params[:f_created_at], "%Y-%m-%d")
            params[:f_created_at] = 'date'
            params[:f_created_at_s] = d
            params[:f_created_at_f] = d
            @entries.reject!{ |i| i.created_at != params[:f_created_at_s] }
          end
        end
      end
    rescue ExpressionParseError => e
      flash[:error] = "Expression parse error: #{e.to_s}"
    end
  end
  
  def new
    @tag = Tag.new
  end
  
  def create
    @tag = Tag.new(params[:tag])
    if @tag.save
      flash[:notice] = "Successfully created tag."
      redirect_to @tag
    else
      render :action => 'new'
    end
  end
  
  def edit
    @tag = Tag.find(params[:id])
  end
  
  def update
    @tag = Tag.find(params[:id])
    if @tag.update_attributes(params[:tag])
      flash[:notice] = "Successfully updated tag."
      redirect_to @tag
    else
      render :action => 'edit'
    end
  end
  
  def destroy
    @tag = Tag.find(params[:id])
    @tag.destroy
    flash[:notice] = "Successfully destroyed tag."
    redirect_to tags_url
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
            if ops.empty?: raise ExpressionParseError, "'#{s}' contains unbalanced parentheses"; end
          end
          ops.pop
        when /[!|,]/
          while ops.last =~ /[!|,]/: ret << ops.pop; end
          ops << i
        end
      else
        ret << i
      end
    end

    until ops.empty?
      if %w[( )].include?(ops.last): raise ExpressionParseError, "'#{s}' contains unbalanced parentheses"; end
      ret << ops.pop
    end

    ret
  end
end
