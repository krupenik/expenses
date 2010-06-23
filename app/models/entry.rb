class Entry < ActiveRecord::Base
  has_many :taggings, :dependent => :destroy
  has_many :tags, :through => :taggings
  
  attr_accessible :amount, :comment, :created_at, :tag_names
  attr_writer :tag_names
  after_save :assign_tags
  serialize :edit_history, Array

  validates_numericality_of :amount, :on => :create, :message => "is not a number"
  validates_presence_of :comment, :on => :create, :message => "can't be blank"
  
  named_scope :created_at, lambda{ |*args| {:conditions => created_at_conditions(*args)} }
  
  named_scope :expenses, :conditions => "amount < 0"
  named_scope :incomings, :conditions => "amount > 0"
  
  def self.created_at_conditions(*args)
    args = *args if args[0].is_a?(Array)
    if args.compact.empty?
      nil
    elsif 1 == args.size
      ["#{self.table_name}.created_at = ?", args[0]]
    else
      (s, f) = args
      _conditions = []
      _conditions << "#{self.table_name}.created_at >= ?" unless s.nil?
      _conditions << "#{self.table_name}.created_at <= ?" unless f.nil?
      [_conditions.join(" AND "), [s, f].compact].flatten
    end
  end

  def initialize(*params)
    super(*params)
    self.edit_history ||= []
  end

  def tag_names
    @tag_names || tags.map(&:name).join(", ")
  end
  
  def amount=(amount)
    if amount =~ /[\+\-\*\/\(\)]/
      amount.gsub!(/[^\d\.\+\-\*\/\(\)]/, '')
      write_attribute(:amount, eval(amount).to_f)
    else
      write_attribute(:amount, amount.to_f)
    end
  end

  private
  
  def assign_tags
    if @tag_names
      self.tags = @tag_names.split(/\s*,\s*/).map do |tag_name|
        Tag.find_or_create_by_name(tag_name)
      end
    end
  end
end
