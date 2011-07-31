class Entry < ActiveRecord::Base
  has_many :taggings, :dependent => :destroy
  has_many :tags, :through => :taggings

  attr_accessible :amount, :comment, :created_at, :tag_names
  attr_writer :tag_names
  after_save :assign_tags
  serialize :edit_history, Array

  validates_numericality_of :amount
  validates_presence_of :comment
  validate :unsealed_creation_date

  scope :expenses, where("#{self.table_name}.amount < 0")
  scope :incomings, where("#{self.table_name}.amount > 0")

  def self.created_at(*args)
    args = *args if args[0].is_a?(Array)
    if args.compact.empty?
      scoped
    elsif 1 == args.size
      where(:created_at => args[0])
    else
      (s, f) = args
      entries = scoped
      entries = entries.where("#{self.table_name}.created_at >= ?", s) unless s.nil?
      entries = entries.where("#{self.table_name}.created_at <= ?", f) unless f.nil?
      entries
    end
  end

  def initialize(*args)
    super(*args)
    self.edit_history ||= []
  end

  def tag_names
    unless @tag_names.blank?
      @tag_names.split(/\s*,\s*/)
    else
      self.tags.map(&:name)
    end.sort.join(", ")
  end

  def amount=(amount)
    if amount =~ /[\+\-\*\/\(\)]/
      amount.gsub!(/[^\d\.\+\-\*\/\(\)]/, '')
      write_attribute(:amount, eval(amount).to_f)
    else
      write_attribute(:amount, amount.to_f)
    end
  end

  def save(*args)
    possible_matches = Entry.where(:created_at => self.created_at).includes(:tags)
    unless self.new_record?
      possible_matches = possible_matches.where("id != ?", self.id)
    end
    possible_matches.each do |e|
      if e.tag_names == self.tag_names
        e.amount += self.amount
        e.comment += ", %s" % self.comment
        e.edit_history.concat(self.edit_history)
        self.destroy unless self.new_record?
        return e.save
      end
    end

    super(*args)
  end

  private

  def unsealed_creation_date
    if self.amount_changed? and m = Milestone.where("created_at >= ?", self.created_at).first
      errors.add(:base, "This period is sealed at #{m.created_at}")
    end
  end

  def assign_tags
    if @tag_names
      self.tags = @tag_names.split(/\s*,\s*/).map do |tag_name|
        Tag.find_or_create_by_name(tag_name)
      end
    end
  end
end
