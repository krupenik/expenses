class TagsController < ApplicationController
  before_filter :authenticate_user!

  def index
    @tags = Tag.all(:include => :taggings)
  end
  
  def show
    if params[:id] =~ /\|/
      @tags = Tag.find_all_by_name(params[:id].split(/\s*\|\s*/))
      @entries = @tags.map(&:entries).flatten.uniq
      @join_op = " | "
    else
      @tags = Tag.find_all_by_name(params[:id].split(/\s*,\s*/))
      @entries = @tags.map(&:entries).inject([]) { |a, e| a = a.empty? ? e : a & e }
      @join_op = " & "
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
end
