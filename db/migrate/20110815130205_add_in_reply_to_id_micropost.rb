class AddInReplyToIdMicropost < ActiveRecord::Migration
  def self.up
    add_column :microposts, :in_reply_to_id, :integer, :default => nil
    remove_column :microposts, :in_reply_to
  end

  def self.down
    remove_column :microposts, :in_reply_to_id
    add_column :microposts, :in_reply_to, :integer
  end
end
