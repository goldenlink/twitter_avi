# -*- coding: utf-8 -*-
require 'digest'

class User < ActiveRecord::Base
  ##################################
  ## STATE MACHINE
  ##################################
  include AASM
  aasm_column :status
  aasm_initial_state :inactive
  aasm_state :inactive
  aasm_state :active
  aasm_state :suspended

  aasm_event :activate, :after => :delete_reset_code do
    transitions :to => :active, :from => [:inactive, :suspended, :active]
  end
  aasm_event :suspend, :before => :create_reset_code do
    transitions :to => :suspended, :from => [:active, :inactive, :suspended]
  end
  ##################################
  ## ACCESSORS
  ##################################
  attr_accessor :password
  attr_accessible :name, :email, :password, :password_confirmation

  ##################################
  ## MODEL
  ##################################
  has_many :microposts, :dependent => :destroy
  has_many :relationships, :foreign_key => "follower_id", :dependent => :destroy
  has_many :following, :through => :relationships, :source => :followed
  has_many :reverse_relationships, :foreign_key => "followed_id", :class_name => "Relationship",
  :dependent => :destroy
  has_many :followers, :through => :reverse_relationships, :source => :follower

  #####################################
  ## VALIDATORS
  #####################################
  email_regex = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i

  validates :name,      :presence     => true,
                        :length       => { :maximum => 50 }
  validates :email,     :presence     => true,
                        :format       => { :with => email_regex },
                        :uniqueness   => { :case_sensitive => false }
  validates :password,  :presence     => true,
                        :confirmation => true,
                        :length       => { :within => 6..40 }
  # Status :limit => [:inactive, :active, :suspended] used for the state machine
  validates_columns :status
  before_save :encrypt_password

  # A callback after object initialization to set up the reset code for activation
  after_create   { self.create_reset_code }

  # Return true if the user's password matches witht he submitted password
  def has_password?(submitted_password)
    encrypted_password == encrypt(submitted_password)
  end

  def self.authenticate(email,submitted_password)
    user = find_by_email(email)
    return nil if user.nil?
    return user if user.has_password?(submitted_password)
  end

  def self.authenticate_with_salt(id, cookie_salt)
    user = find_by_id(id)
    (user && user.salt == cookie_salt) ? user : nil
  end

  def feed
    Micropost.from_users_followed_by(self).roots
  end

  def following?(followed)
    relationships.find_by_followed_id(followed)
  end

  def follow!(followed)
    relationships.create!(:followed_id => followed.id)
  end

  def unfollow!(followed)
    relationships.find_by_followed_id(followed).destroy
  end

  # Creates a reset random code to send by email. This uniquely identifies user to reset the password²
  def create_reset_code
    self.reset_code = Digest::SHA1.hexdigest(Time.now.to_s.split(//).sort_by{ rand }.join)
    save(:validate => false)
  end

  # Delete the reset code once the reset has been done.
  def delete_reset_code
    self.reset_code = nil
    save(:validate => false)
  end

  private

  def encrypt_password
    self.salt = make_salt if new_record?
    self.encrypted_password = encrypt(password)
  end

  def encrypt(string)
    secure_hash("#{salt}--#{string}")
  end

  def make_salt
    secure_hash("#{Time.now.utc}--#{password}")
  end

  def secure_hash(string)
    Digest::SHA2.hexdigest(string)
  end

end


# == Schema Information
#
# Table name: users
#
#  id                 :integer(4)      not null, primary key
#  name               :string(255)
#  email              :string(255)
#  created_at         :datetime
#  updated_at         :datetime
#  encrypted_password :string(255)
#  salt               :string(255)
#  admin              :boolean(1)      default(FALSE)
#  reset_code         :string(255)
#  status             :enum([:inactive
#

