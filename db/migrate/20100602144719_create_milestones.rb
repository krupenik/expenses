class CreateMilestones < ActiveRecord::Migration
  def self.up
    create_table :milestones do |t|
      t.decimal :incomings
      t.decimal :expenses
      t.date :created_at
    end
  end

  def self.down
    drop_table :milestones
  end
end
