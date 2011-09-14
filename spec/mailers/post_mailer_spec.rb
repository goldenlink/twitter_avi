require "spec_helper"

describe PostMailer do

  describe "Registration notification" do

    before(:each) do
      @user = Factory(:user)
    end

    it "should send registration email" do
      lambda { PostMailer.registration_confirmation(@user) }.should_not raise_error
    end

    describe "registration email" do

      before(:each) do
        @mail = PostMailer.registration_confirmation(@user)
      end

      it "should have the registration text" do
        @mail.body.should contain(/registration/)
      end

      it "should deliver mail sucessfully" do
        lambda { @mail.deliver }.should_not raise_error
      end

      describe "should be added to devliering queue" do

        it "should be delivered" do
          lambda { @mail.deliver }.should
          change(ActionMailer::Base.deliveries, :size).by(1)
        end

      end
    end

  end

end
