class Micropost < ActiveRecord::Base

  attr_accessible :content, :in_reply_to_id
  
# User association : The post is redacted by the user.
  belongs_to :user

# Reply to micropost.
  has_many :replies, :class_name => "Micropost", :foreign_key => "in_reply_to_id", 
  :dependent => :destroy
  belongs_to :in_reply_to, :class_name => "Micropost"

  validates :content, :presence => true, :length => { :maximum => 140 }
  validates :user_id, :presence => true

  default_scope :order => 'microposts.created_at DESC', :conditions => { :in_reply_to_id => nil }

  #return microposts from the users being followed by the given user.
  scope :from_users_followed_by, lambda { |user| followed_by(user) }
  # Including replies of the microposts
  scope :including_replies, includes({ :replies => [ :user, { :in_reply_to => :user } ] })

  # Format the author of the post:
  # @-id-name
  def author
    ['@',self.user.id, self.user.name].join('-')
  end

  # Is the micropost a reply?
  def is_reply?
    !self.in_reply_to_id.nil?
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
#  id             :integer(4)      not null, primary key
#  content        :string(255)
#  user_id        :integer(4)
#  created_at     :datetime
#  updated_at     :datetime
#  in_reply_to_id :integer(4)
#
