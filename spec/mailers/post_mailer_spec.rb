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

  describe "Reply notification" do
    before(:each) do
      @text = "Reply test text"
    end

    it "should not raise an error" do
      lambda { PostMailer.notify(@user, @text) }.should_not raise_error
    end

    describe "Notification email" do
      before(:each) do
        @notify = PostMailer.notify(@user, @text)
      end

      it "should have the user name" do
        @notify.body.should have_selector("h1",:content => "Welcome " + @user.name)
      end
      it "should contain the reply's text in the mail" do
        @notify.body.should have_selector("p",:content => @text)
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
