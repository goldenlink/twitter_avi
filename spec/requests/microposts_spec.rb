require 'spec_helper'

describe "Microposts" do
  
  before(:each) do
    user = Factory(:user)
    content = "Lorem ipsum dolor sit amet"
    @create_post = proc {
      fill_in :micropost_content, :with => content
      click_button
    }
    visit signin_path
    fill_in :email, :with => user.email
    fill_in :password, :with => user.password
    click_button
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
end
