class Entry < ActiveRecord::Base
  has_many :taggings, :dependent => :destroy
  has_many :tags, :through => :taggings
  
  attr_accessible :amount, :comment, :created_at, :tag_names
  attr_writer :tag_names

  validates_numericality_of :amount, :on => :create, :message => "is not a number"
  validates_presence_of :comment, :on => :create, :message => "can't be blank"
  
  after_save :assign_tags
  
  named_scope :created_at, lambda{ |*args|
    if args.empty?
      {}
    elsif 1 == args.size
      {:conditions => ["created_at = ?", args[0]]}
    else
      (s, f) = args.flatten
      _conditions = []
      _conditions << "created_at >= ?" unless s.nil?
      _conditions << "created_at <= ?" unless f.nil?
      {:conditions => [_conditions.join(" AND "), [s, f].compact].flatten}
    end
  }
  
  def tag_names
    @tag_names || tags.map(&:name).join(", ")
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
