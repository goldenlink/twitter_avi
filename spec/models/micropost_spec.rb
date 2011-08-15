require 'spec_helper'

describe Micropost do

  before(:each) do
    @user = Factory(:user)
    @attr = { :content => "value for content" }
  end

  it "should create a new instance given valid attributes" do
    @user.microposts.create!(@attr)
  end

  describe "reply association" do
    before(:each) do
      @micropost = @user.microposts.create(@attr)
      @reply = @user.microposts.create(:content => "Reply to", :in_reply_to => @micropost)
    end

    it "should respond to in_reply_to" do
      @micropost.should respond_to(:in_reply_to)
    end

    it "should respond to replies" do
      @micropost.should respond_to(:replies)
    end

    it "should have a reply" do
      @micropost.replies.should include(@reply)
    end

    it "should have a post in reply" do
      @reply.in_reply_to.should == @micropost
    end

    it "should delete replies" do
      @micropost.destroy
      Micropost.find_by_id(@reply).should be_nil
    end

  end

  describe "user association" do
    
    before(:each) do
      @micropost = @user.microposts.create(@attr)
    end

    it "should have a user attribute" do
      @micropost.should respond_to(:user)
    end

    it "should have the right associated user" do
      @micropost.user_id.should == @user.id
      @micropost.user.should == @user
    end
  end

  describe "validation" do

    it "should require a user id" do
      Micropost.new(@attr).should_not be_valid
    end

    it "should require nonblank content" do
      @user.microposts.build( :content => " " ).should_not be_valid
    end

    it "should reject long content" do
      @user.microposts.build(:content => "a" * 141).should_not be_valid
    end
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

