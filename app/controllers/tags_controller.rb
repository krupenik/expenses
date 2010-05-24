class TagsController < ApplicationController
  class ExpressionParseError < Exception; end

  before_filter :authenticate_user!

  def index
    @tags = Tag.all(:include => :taggings)
  end
  
  def show
    @tag_list = params[:id].gsub(/\s*([!|])\s*/, ' \1 ').gsub(/\s*,\s*/, ', ')
    @entries = []
    begin
      e = parse_tag_expr(@tag_list)
      logger.debug(e.inspect)
      tags = Hash[Tag.find_all_by_name(e.reject{ |i| i =~ /[!\(\)|,]/ }.compact,
        :include => {:entries => :tags}).map{ |i| [i.name, i.entries] }]
      stack = []
      e.each do |i|
        case i
        when /[!|,]/
          o1 = stack.pop
          o2 = stack.pop
          if o2.nil?: raise ExpressionParseError, "missing second argument to '#{i}'"; end
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
        when /[!|,]/ then ops << i
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
