class PostMailer < ActionMailer::Base
  default :from => "from@example.com"

  def registration_confirmation(user)
    mail(:to => user.email, :subject => "Registration confirmation")
  end

  def notify(user,post)
    @user = user
    @text = post.content
    @author_name = post.user.name
    mail(:to => user.email, :subject => "Reply to your post")
  end

end
