class RenameAncestryColumnToMicroposts < ActiveRecord::Migration
  def self.up
    rename_column :microposts, :in_reply_to_id, :ancestry
  end

  def self.down
    rename_column :microposts, :ancestry, :in_reply_to_id
  end
end
