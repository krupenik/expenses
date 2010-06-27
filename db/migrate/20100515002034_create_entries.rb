class CreateEntries < ActiveRecord::Migration
  def self.up
    create_table :entries do |t|
      t.decimal :amount
      t.string :comment
      t.date :created_at
    end
  end

  def self.down
    drop_table :entries
  end
end
