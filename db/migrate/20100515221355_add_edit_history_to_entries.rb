class AddEditHistoryToEntries < ActiveRecord::Migration
  def self.up
    add_column :entries, :edit_history, :text
  end

  def self.down
    remove_column :entries, :edit_history
  end
end
