require "spec_helper"

describe PostMailer do

  before(:each) do
    @user = Factory(:user)
  end

  describe "Registration notification" do

    it "should not raise an error" do
      lambda { PostMailer.registration_confirmation(@user) }.should_not raise_error
    end

    describe "registration email" do

      before(:each) do
        @mail = PostMailer.registration_confirmation(@user)
      end
      it "should be sent to the user email" do
        @mail.header['to'].to_s.should == @user.email
      end
      it "should have the correct registration text" do
        @mail.body.should contain(/registration/)
      end

      describe "should be added to delivering queue" do
        it "should deliver mail sucessfully" do
          lambda { @mail.deliver }.should_not raise_error
        end
        it "should be delivered" do
          lambda { @mail.deliver }.should
          change(ActionMailer::Base.deliveries, :size).by(1)
        end
      end
    end
  end

  describe "password forgotten reset" do

    before(:each) do
      @user.create_reset_code
    end

    it "should not raise an error" do
      lambda { PostMailer.reset_password(@user) }.should_not raise_error
    end
    describe "forgotten password email" do
      before(:each) do
        @mail = PostMailer.reset_password(@user)
      end

      it "should be a multipart email" do
        @mail.body.parts.length.should == 2
        @mail.body.parts.collect(&:content_type).should == [ "text/plain; charset=UTF-8","text/html; charset=UTF-8"]
      end

      it "should send email to the user email" do
        @mail.header['to'].to_s.should == @user.email
      end

      describe "html part" do
        before(:each) do
          @content = @mail.body.parts.find {|p| p.content_type.match /html/}.body
        end

        it "should include the url" do
          @content.should contain(/http\:\/\/localhost\:3000\/reset\/?.*reset_code/)
        end
        it "should include the user name" do
          @content.should contain(@user.name)
        end
      end

      describe "text part" do
        before(:each) do
          @content = @mail.body.parts.find { |p| p.content_type.match /plain/}.body
        end
        it "should include the url" do
          @content.should contain(/http\:\/\/localhost\:3000\/reset\/?.*reset_code/)
        end
        it "should include the user name" do
          @content.should contain(@user.name)
        end
      end

      describe "should be added to delivering queue" do
        it "should deliver email successfully" do
          lambda { @mail.deliver }.should
          change(ActionMailer::Base.deliveries, :size).by(1)
        end
      end
    end

  end

  describe "Reply notification" do
    before(:each) do
      @post = @user.microposts.create(:content => "My post")
    end

    it "should not raise an error" do
      lambda { PostMailer.notify(@user, @post) }.should_not raise_error
    end

    describe "Notification email" do
      before(:each) do
        @notify = PostMailer.notify(@user, @post)
      end

      it "should be a multipart message" do
        @notify.body.parts.length.should == 2
        @notify.body.parts.collect(&:content_type).should == [ "text/plain; charset=UTF-8","text/html; charset=UTF-8"]
      end

      describe "html part" do

        before(:each) do
          @content = @notify.body.parts.find {|p| p.content_type.match /html/}.body
        end
        it "should have the user name" do
          @content.should have_selector("h1",:content => "Welcome " + @user.name)
        end
        it "should show the reply's author name" do
          @content.should have_selector("#answer_from", :content => @post.user.name)
        end
        it "should contain the reply's text in the mail" do
          @content.should have_selector("p",:content => @post.content)
        end
        it "should be sent to user email" do
          @notify.header['to'].to_s.should ==@user.email
        end
      end

      describe "plain text part" do

        before(:each) do
          @content = @notify.body.parts.find { |p| p.content_type.match /plain/ }.body
        end
        it "should contain user name" do
          @content.should contain(@user.name)
        end
        it "should contain the post reply" do
          @content.should contain(@post.content)
        end
      end
      describe "should be delivered" do

        it "should deliver without error" do
          lambda { @notify.deliver }.should_not raise_error
        end
        it "should be delivered to mail queue" do
          lambda { @notify.deliver }.should change(ActionMailer::Base.deliveries, :size).by(1)
        end
      end
    end
  end

end
