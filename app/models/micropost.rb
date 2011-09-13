class Micropost < ActiveRecord::Base

  attr_accessible :content, :parent_id

#######################################
## MODEL
#######################################
# User association : The post is redacted by the user.
  belongs_to :user

# Reply to micropost.
  has_ancestry :orphan_strategy => :rootify

########################################
## MODEL VALIDATION
########################################
  validates :content, :presence => true, :length => { :maximum => 140 }
  validates :user_id, :presence => true

########################################
## SCOPE
########################################
  default_scope :order => 'microposts.created_at DESC'
  #return microposts from the users being followed by the given user.
  scope :from_users_followed_by, lambda { |user| followed_by(user) }

  # Format the author of the post:
  # @-id-name
  def author
    ['@',self.user.id, self.user.name.split().join].join('-')
  end

  # Is the micropost a reply?
  def is_reply?
    !self.is_root?
  end

  # Returns the micropost it replies to.
  def in_reply_to 
    self.parent
  end

  def replies
    self.descendants
  end

  private

  #Return an SQL condition for users followed by the given user.
  # we include the user's own id as well
  def self.followed_by(user)
    followed_ids = %(SELECT followed_id FROM relationships WHERE follower_id = :user_id)
    # Added table reference to avoid unambiguous SQL request
    where("microposts.user_id IN (#{followed_ids}) OR microposts.user_id = :user_id", { :user_id => user })
  end

end

# == Schema Information
#
# Table name: microposts
#
#  id         :integer(4)      not null, primary key
#  content    :string(255)
#  user_id    :integer(4)
#  created_at :datetime
#  updated_at :datetime
#  ancestry   :string(255)
#

