class UpdateInReplyToMicroposts < ActiveRecord::Migration
  def self.up
    rename_column :microposts, :in_reply_to_id, :parent_id
  end

  def self.down
    rename_column :microposts, :parent_id, :in_reply_to_id
  end
end
