class PostMailer < ActionMailer::Base
  default :from => "from@example.com"

  def registration_confirmation(user)
    mail(:to => user.email, :subject => "Registration confirmation")
  end

  def notify(user,text)
    @user = user
    @text = text
    mail(:to => user.email, :subject => "Reply to your post")
  end

end
