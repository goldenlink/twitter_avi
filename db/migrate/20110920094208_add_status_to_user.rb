class AddStatusToUser < ActiveRecord::Migration
  def self.up
    add_column :users, :status, :enum, :limit => [:inactive, :active, :suspended]
  end

  def self.down
    remove_column :users, :status
  end
end
