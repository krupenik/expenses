class Milestone < ActiveRecord::Base
  MinInterval = 27

  class IntervalError < Exception; end

  def self.set(date = Date.today)
    prev_milestone = Milestone.first(
      :conditions => ['created_at <= ?', date],
      :order => 'created_at desc', :limit => 1
    )
    prev_date = prev_milestone.created_at + 1 rescue nil
    prev_amount = prev_milestone.amount rescue 0
    raise IntervalError, "Interval between milestones is too small" if (prev_date && MinInterval > (date - prev_date))
    amounts = Entry.created_at(prev_date, date).scoped(:select => 'amount').map(&:amount)
    return Milestone.create(
      :incomings => amounts.select{ |i| i > 0 }.sum + prev_amount,
      :expenses => amounts.select{ |i| i < 0 }.sum.abs,
      :created_at => date
    )
  end

  def amount
    incomings - expenses
  end
end
