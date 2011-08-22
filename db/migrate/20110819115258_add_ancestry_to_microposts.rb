class AddAncestryToMicroposts < ActiveRecord::Migration
  def self.up
    add_column :microposts, :in_reply_to, :string
    add_index :microposts, :in_reply_to
      
  end

  def self.down
    remove_index :microposts, :in_reply_to
    remove_column :microposts, :in_reply_to
  end
end
