class EntriesController < ApplicationController
  before_filter :authenticate_user!

  def index
    @entries = Entry.scoped(:include => :tags, :order => 'id desc', :limit => 50)
    
    if params[:f_date]
      begin
        @date = Date.strptime(params[:f_date], "%Y-%m-%d")
        @entries = @entries.created_at(@date)
      rescue ArgumentError
        @date = Date.strptime(params[:f_date], "%Y-%m")
        @entries = @entries.created_at(@date.beginning_of_month, @date.end_of_month)
      end
    end
  end
  
  def calendar
    @date = params[:date] ? Date.strptime(params[:date], "%Y-%m") : Date.today
    @entries = Entry.created_at(@date.beginning_of_month, @date.end_of_month)
  end
  
  def new
  end
  
  def create
    @entry = Entry.new(params[:entry])
    @entry.edit_history << [current_user.id, Time.now]
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
    @entry.edit_history << [current_user.id, Time.now]
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
