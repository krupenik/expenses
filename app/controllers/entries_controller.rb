class EntriesController < ApplicationController
  before_filter :authenticate_user!

  def index
    e = Entry.scoped(:include => :tags, :order => 'id desc')

    if 'expenses' == params[:f_type]
      e = e.expenses
    elsif 'incomings' == params[:f_type]
      e = e.incomings
    end
    
    unless params[:f_created_at].blank?
      e = case params[:f_created_at]
      when 'date' then e.created_at(*[params[:f_created_at_s], params[:f_created_at_f]].map{ |i| i.to_date rescue nil })
      when 'week' then e.created_at(Date.today.beginning_of_week, Date.today.end_of_week)
      when 'yesterday' then e.created_at(Date.yesterday)
      when 'today' then e.created_at(Date.today)
      else
        params[:f_created_at] = 'date'
        if params[:f_created_at] =~ /^\d{4}\-\d{2}$/
          d = Date.strptime(params[:f_created_at], "%Y-%m")
          params[:f_created_at_s] = d.beginning_of_month
          params[:f_created_at_f] = d.end_of_month
          e.created_at(params[:f_created_at_s], params[:f_created_at_f])
        elsif params[:f_created_at] =~ /^\d{4}\-\d{2}\-\d{2}$/
          d = Date.strptime(params[:f_created_at], "%Y-%m-%d")
          params[:f_created_at_s] = d
          params[:f_created_at_f] = d
          e.created_at(params[:f_created_at_s])
        end
      end
    end

    @entries = e
  end
  
  def calendar
    @date = Date.strptime(params[:date], "%Y-%m") rescue Date.today
    @entries = Entry.created_at(@date.beginning_of_month, @date.end_of_month)
  end
  
  def new
    @entry = Entry.new
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
