require 'spec_helper'
require 'uri'

describe "Users" do

  describe "sign in / sign out" do

    describe "failure" do
      it "should not sign a user in" do
        visit signin_path
        fill_in :email, :with => ""
        fill_in :password, :with => ""
        click_button
        response.should have_selector("div.flash.error", :content => "Invalid")
      end
    end

    describe "success" do
      it "should sign user in and out" do
        user = Factory(:user)
        visit signin_path
        fill_in :email, :with => user.email
        fill_in :password, :with => user.password
        click_button
        controller.should be_signed_in
        click_link "Sign out"
        controller.should_not be_signed_in
      end
    end


  end

  describe "signup" do

    describe "failure" do

      it "should not make a new user" do
        lambda do
          visit signup_path
          fill_in "Name", :with => ""
          fill_in "Email", :with => ""
          fill_in "Password", :with => ""
          fill_in "Confirmation", :with => ""
          click_button
          response.should render_template('users/new')
          response.should have_selector('div#error_explanation')
          field_labeled("password").value.should be_nil
          field_labeled("confirmation").value.should be_nil
        end.should_not change(User, :count)
      end

    end

    describe "success" do

      it "should make a new user" do
        lambda do
          visit signup_path
          fill_in "Name", :with => "Aurelien"
          fill_in "Email", :with => "user@example.com"
          fill_in "Password", :with => "foobar"
          fill_in "Confirmation", :with => "foobar"
          click_button
          response.should render_template('users/show')
          response.should have_selector("div.flash.success",
                                        :content => "Welcome")
        end.should change(User, :count).by(1)
      end

    end

  end

  describe "forgotten password" do

    before(:each) do
      @user = Factory(:user)
    end

    it "should send a forgotten password email" do
      visit forgot_path
      fill_in "Email", :with => @user.email
      click_button
      response.should render_template('pages/home')
      response.should have_selector("div.flash.notice",
                                    :content => "Reset code sent to #{@user.email}")
      change(ActionMailer::Base.deliveries, :size).by(1)
    end

  end

  describe "Reset password" do

    before(:each) do
      # Ask to change the password
      @user = Factory(:user)
      visit forgot_path
      fill_in "Email", :with => @user.email
      click_button
      # Parse email to get the address
      @new_pass = "bipbip"
      mail = ActionMailer::Base.deliveries.last
      body = mail.body.parts.find { |p| p.content_type.match /plain/}.body
      url = body.to_s.scan /(http\:.*)/
      @uri = URI.parse(url[0][0])
    end

    it "should reset password" do
      visit @uri
      fill_in "Password", :with => @new_pass
      fill_in "Password confirmation", :with => @new_pass
      click_button
      response.should render_template('pages/home')
      response.should have_selector("div.flash.notice", :content => "Password reset successfully for #{@user.email}")
    end

  end

end
