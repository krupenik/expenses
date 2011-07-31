class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time
  protect_from_forgery # See ActionController::RequestForgeryProtection for details

  before_filter :restore_context

  def default_context
    {
      :type => nil,
      :date => [nil, [Milestone.where("created_at < ?", Date.today).last.try(:created_at).try(:tomorrow), nil]],
    }
  end

  def restore_context
    unless session[:context]
      session[:context] = default_context
    end
  end

  def apply_context(params)
    session[:context][:date] = case params[:f_created_at].to_s
    when 'date' then [:date, [params[:f_created_at_s], params[:f_created_at_f]].map{ |i| i.to_date rescue nil }]
    when 'week' then [:week, [Date.today.beginning_of_week, Date.today.end_of_week]]
    when 'month' then [:month, [Date.today.beginning_of_month, Date.today.end_of_month]]
    when 'overall' then [:overall, [nil, nil]]
    when 'today' then [:today, [Date.today, nil]]
    else default_context[:date]
    end
    session[:context][:type] = params[:f_type]
  end

  helper_method :date_contexts
  def date_contexts
    [nil, :today, :week, :month, :overall, :date]
  end

  helper_method :type_contexts
  def type_contexts
    [nil, 'expenses', 'incomings']
  end
end
