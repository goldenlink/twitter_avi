class Micropost < ActiveRecord::Base

  attr_accessible :content, :in_reply_to
  
  belongs_to :user
  has_many :replies, :class_name => "Micropost", :foreign_key => "in_reply_to_id"
  belongs_to :in_reply_to, :class_name => "Micropost"

  validates :content, :presence => true, :length => { :maximum => 140 }
  validates :user_id, :presence => true

  default_scope :order => 'microposts.created_at DESC'

  #return microposts from the users being followed by the given user.
  scope :from_users_followed_by, lambda { |user| followed_by(user) }

  private

  #Return an SQL condition for users followed by the given user.
  # we include the user's own id as well
  def self.followed_by(user)
    followed_ids = %(SELECT followed_id FROM relationships WHERE follower_id = :user_id)

    where("user_id IN (#{followed_ids}) OR user_id = :user_id", { :user_id => user })
  end

end



# == Schema Information
#
# Table name: microposts
#
#  id             :integer(4)      not null, primary key
#  content        :string(255)
#  user_id        :integer(4)
#  created_at     :datetime
#  updated_at     :datetime
#  in_reply_to_id :integer(4)
#

