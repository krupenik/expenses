class EntriesController < ApplicationController
  def index
    @entries = Entry.scoped(:include => :tags)
    
    if params[:f_date]
      @entries = @entries.created_at(params[:f_date])
    end
  end
  
  def calendar
    @entries = Entry.all
  end
  
  def new
  end
  
  def create
    @entry = Entry.new(params[:entry])
    if @entry.save
      flash[:notice] = "Successfully created entry."
      redirect_to :action => 'index'
    else
      render :action => 'new'
    end
  end
  
  def show
  end
  
  def edit
    @entry = Entry.find(params[:id])
  end
  
  def update
    @entry = Entry.find(params[:id])
    if @entry.update_attributes(params[:entry])
      flash[:notice] = "Successfully updated entry."
      redirect_to :action => 'index'
    else
      render :action => 'edit'
    end
  end
  
  def destroy
  end
end
