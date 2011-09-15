class PostMailer < ActionMailer::Base
  default :from => "from@example.com"

  # Sends an email to thank for registration
  def registration_confirmation(user)
    mail(:to => user.email, :subject => "Registration confirmation")
  end

  # Sends a notification to a user for a reply to one of his posts.
  def notify(user,post)
    @user = user
    @text = post.content
    @author_name = post.user.name
    mail(:to => user.email, :subject => "Reply to your post")
  end


  # Sends the link to reset the password by email.
  def reset_password(user)
    @user = user
    @url = reset_url(:user => { :reset_code => @user.reset_code })
    mail(:to => @user.email, :subject => "Reset your password")
  end
end
