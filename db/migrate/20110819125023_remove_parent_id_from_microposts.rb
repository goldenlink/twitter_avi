class RemoveParentIdFromMicroposts < ActiveRecord::Migration
  def self.up
    remove_column :microposts, :parent_id
  end

  def self.down
    add_column :microposts, :parent_id, :integer
  end
end
