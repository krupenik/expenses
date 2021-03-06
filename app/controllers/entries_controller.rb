class EntriesController < ApplicationController
  before_filter :authenticate_user!

  def index
    unless params[:f_created_at].blank?
      if params[:f_created_at] =~ /^(\d{4})-(\d{2})-(\d{2})$/
        params[:f_created_at_s] = params[:f_created_at_f] = Date.new($1.to_i, $2.to_i, $3.to_i)
      elsif params[:f_created_at] =~ /^(\d{4})-(\d{2})$/
        params[:f_created_at_s] = Date.new($1.to_i, $2.to_i)
        params[:f_created_at_f] = params[:f_created_at_s].end_of_month
      end
      params[:f_created_at] = 'date'
      apply_context(params)
      redirect_to entries_path
    end

    e = Entry.includes(:tags).order('id desc')

    if 'expenses' == session[:context][:type]
      e = e.expenses
    elsif 'incomings' == session[:context][:type]
      e = e.incomings
    end

    e = e.created_at(*session[:context][:date][1])

    if session[:context][:date][0].nil?
      @last_milestone = Milestone.where('created_at <= ?', Date.today).last
    end

    @entries = e
    @tags = {:incomings => Hash.new(0), :expenses => Hash.new(0)}
    @entries.each do |entry|
      entry.tags.each do |tag|
        type = entry.amount < 0 ? :expenses : :incomings
        @tags[type][tag] += entry.amount
      end
    end
  end

  def new
    @entry = Entry.new
  end

  def create
    @entry = Entry.new(params[:entry])
    @entry.edit_history << [current_user.id, Time.now]
    if @entry.save
      redirect_to entries_url, :notice => "Successfully added an entry."
    else
      render :action => 'new'
    end
  end

  def show
    redirect_to edit_entry_path(params[:id])
  end

  def edit
    @entry = Entry.find(params[:id])
  end

  def update
    @entry = Entry.find(params[:id])
    @entry.edit_history << [current_user.id, Time.now]
    if @entry.update_attributes(params[:entry])
      redirect_to entries_url, :notice => "Successfully updated entry."
    else
      render :action => 'edit'
    end
  end

  def destroy
    redirect_to entries_path
  end

  def set_context
    redirect_to root_url unless request.referer
    apply_context params
    redirect_to request.referer
  end

  def set_milestone
    redirect_to root_url unless request.referer
    begin
      Milestone.set(Date.today.beginning_of_month - 1)
    rescue Milestone::IntervalError => e
      flash[:notice] = e.to_s
    end
    redirect_to request.referer
  end
end
