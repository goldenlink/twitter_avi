class UpdateAncestryColumnToMicroposts < ActiveRecord::Migration
  def self.up
    rename_column :microposts, :in_reply_to, :in_reply_to_id
  end

  def self.down
    rename_column :microposts, :in_reply_to_id, :in_reply_to
  end
end
