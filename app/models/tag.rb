class Tag < ActiveRecord::Base
  has_many :taggings, :dependent => :destroy
  has_many :entries, :through => :taggings
  
  attr_accessible :name
  
  def to_param
    name
  end
end
