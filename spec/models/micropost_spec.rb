require 'spec_helper'

describe Micropost do

  before(:each) do
    @user = Factory(:user)
    @attr = { :content => "value for content", :parent_id => nil }
  end

  it "should create a new instance given valid attributes" do
    @user.microposts.create!(@attr)
  end

  describe "reply association" do

    before(:each) do
      @micropost = @user.microposts.create(@attr)
      @reply = @user.microposts.create(@attr.merge({ :content => "Reply to", :parent_id => @micropost }))
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

    it "should rootify replies" do
      @micropost.destroy
      reply_tmp = Micropost.find_by_id(@reply)
      reply_tmp.should_not be_nil
      reply_tmp.should be_is_root
    end

    it "should have a is_reply? method" do
      @micropost.should respond_to(:is_reply?)
    end

    it "should determine that it is not a reply" do
      @micropost.should_not be_is_reply
    end

    it "should determine that it is a reply" do
      @reply.should be_is_reply
    end

    describe "micropost author" do
      
      it "should respond to author" do
        @micropost.should respond_to(:author)
      end

      it "should have the correct format" do
        @micropost.author.should =~ /^@[-]\d*[-]\w/
      end

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
#  id         :integer(4)      not null, primary key
#  content    :string(255)
#  user_id    :integer(4)
#  created_at :datetime
#  updated_at :datetime
#  ancestry   :string(255)
#

