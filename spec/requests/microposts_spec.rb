require 'spec_helper'

describe "Microposts" do
  
  before(:each) do
    @user = Factory(:user)
    content = "Lorem ipsum dolor sit amet"
    @create_post = proc {
      fill_in :micropost_content, :with => content
      click_button
    }
    visit signin_path
    fill_in :email, :with => @user.email
    fill_in :password, :with => @user.password
    click_button
  end

  describe "delete link" do
    before(:each) do
      visit root_path
      @create_post.call()
    end

    describe "authorized user" do
      before(:each) do
        visit user_path(@user)
      end
      
      it "should have a delete link" do
        response.should have_selector("div.delete")
      end
    end

    describe "unauthorized user" do

      before(:each) do
        visit signout_path
        @wrong_user = Factory(:user, :email => "wrong@example.com")
        visit signin_path
        fill_in :email, :with => @wrong_user.email
        fill_in :password, :with => @wrong_user.password
        click_button
      end

      it "should not have a delete link" do
        visit user_path(@user)
        response.should_not have_selector("div.delete")
      end

    end

  end

  describe "count microposts" do

      it "should have 0 microposts" do
        visit root_path
        response.should have_selector("span.microposts", :content => "0 micropost")
      end
    
      it "should have 1 micropost" do
        visit root_path
        @create_post.call()
        response.should have_selector("span.microposts", :content => "1 micropost")
      end
    
      it "should have 2 microposts" do
        visit root_path
        2.times do
          @create_post.call()
        end
        response.should have_selector("span.microposts", :content => "2 microposts")
      end

    end

  describe "micropost pagination" do

    before(:each) do
      visit root_path
      35.times do
        @create_post.call()
      end
    end

    it "should have a previous link not activated" do
      response.should have_selector("div.pagination")
      response.should have_selector("span.disabled", :content => "Previous")
      response.should have_selector("a", :href => "/?page=2", :content => "2")
      response.should have_selector("a", :href => "/?page=2", :content => "Next")
    end

  end
      


  describe "creation" do
    
    describe "failure" do 
      
      it "should not make a new micropost" do
        lambda do
          visit root_path
          fill_in :micropost_content, :with => ""
          click_button
          response.should render_template('pages/home')
          response.should have_selector("div#error_explanation")
        end.should_not change(Micropost, :count)
      end
    end

    describe "success" do
      
      it "should make a new micropost" do
        content = "Lorem ipsum dolor sit amet"
        lambda do
          visit root_path
          fill_in :micropost_content, :with => content
          click_button
          response.should have_selector("span.content", :content => content)
        end.should change(Micropost, :count).by(1)
      end
    end
  end

  describe "from_users_followed_by" do

    before(:each) do
      @other_user = Factory(:user, :email => Factory.next(:email))
      @third_user = Factory(:user, :email => Factory.next(:email))

      @user_post = @user.microposts.create!(:content => "foo")
      @other_post = @other_user.microposts.create!(:content => "bar")
      @third_post = @third_user.microposts.create!(:content => "baz")

      @user.follow!(@other_user)
    end

    it "should have a from_users_followed_by class method" do
      Micropost.should respond_to(:from_users_followed_by)
    end

    it "should include the followed user's microposts" do
      Micropost.from_users_followed_by(@user).should include(@other_post)
    end

    it "should include the user's own microposts" do
      Micropost.from_users_followed_by(@user).should include(@user_post)
    end

    it "should not include an unfollowed user's microposts" do
      Micropost.from_users_followed_by(@user).should_not include(@third_post)
    end
  end

  describe "in reply to" do
    before(:each) do
      # Create the post for user
      @other_user = Factory(:user, :email => Factory.next(:email))
      @other_post = @other_user.microposts.create!(:content => "main test", :parent_id => @post)
      # Follow user
      @user.follow!(@other_user)
      visit root_path
    end

    it "should have a reply link" do
      response.should have_selector("a", :content => "@reply")
      response.should have_selector("span.content", :content => @other_post.content)
    end

    describe "reply to" do
      before(:each) do
        click_link "@reply"
      end        
      
      it "should redirect on root page" do
        response.should render_template "pages/home"
      end
      
      it "should create a reply" do
        fill_in :micropost_content, :with => "Reply to main"
        click_button
        response.should be_successful
        response.should have_selector("span.content", :content => "Reply to main")
        response.should have_selector("span.user") do |data| 
          data.should contain(/@-\d+-\w/)
        end
      end

    end
  end
      
end
