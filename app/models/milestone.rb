class Milestone < ActiveRecord::Base
  class IntervalError < Exception; end
  
  def self.set(date = Date.today)
    prev_date = Milestone.first(:conditions => ['created_at <= ?', date]).created_at + 1 rescue nil
    raise IntervalError, "too small" if (prev_date && 28 >= (date - prev_date))
    amounts = Entry.created_at(prev_date, date).map(&:amount)
    return Milestone.create(
      :incomings => amounts.select{ |i| i > 0 }.sum,
      :expenses => amounts.select{ |i| i < 0 }.sum.abs,
      :created_at => date
    )
  end
  
  def amount
    incomings - expenses
  end
end
