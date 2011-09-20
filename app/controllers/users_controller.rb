class UsersController < ApplicationController

  before_filter :authenticate, :except => [:show, :new, :create, :forgot, :reset]
  before_filter :correct_user, :only => [:edit, :update]
  before_filter :admin_user, :only => :destroy
  before_filter :redirect_signed_in, :only => [:new, :create]

  def new
    @user = User.new
    @title = "Sign up"
  end

  def index
    @title = "All users"
    @users = User.paginate(:page => params[:page])
  end

  def show
    @user = User.find(params[:id])
    @microposts = @user.microposts.paginate(:page => params[:page])
    @title = @user.name
  end

  def create
    @user = User.new(params[:user])
    if @user.save
      PostMailer.registration_confirmation(@user).deliver
      sign_in @user
      flash[:success] = "Welcome to the Sample App!"
      redirect_to @user
    else
      @title = "Sign up"
      #Reset passwords fields after failure
      @user.password, @user.password_confirmation = nil,nil
      render 'new'
    end
  end

  def edit
#    @user = User.find(params[:id]) defined in filter
    @title = "Edit user"
  end

  def update
#    @user = User.find(params[:id]) defined in filter1
    if @user.update_attributes(params[:user])
      flash[:success] = "Profile updated."
      redirect_to @user
    else
      @title = "Edit user"
      render 'edit'
    end
  end

  def destroy
    user_to_destroy = User.find(params[:id])
    user_to_destroy.destroy unless current_user?(user_to_destroy)
    flash[:success] = "User destroyed."
    redirect_to users_path
  end

  def following
    show_follow(:following)
  end

  def followers
    show_follow(:followers)
  end

  def show_follow(action)
    @title = action.to_s.capitalize
    @user = User.find(params[:id])
    @users = @user.send(action).paginate(:page => params[:page])
    render 'show_follow'
  end

  # To reset the password, user uses forgot link.
  # it generates a reset code sent by email.
  # in the email, the link to the reset form is sent.
  def forgot
    @title = "Forgot password"
    @user = User.find_by_email(params[:user][:email]) unless params[:user].nil?
    if request.post?

      if @user
        @user.suspend
        # send here reset email
        PostMailer.reset_password(@user).deliver
        flash[:notice] = "Reset code sent to #{@user.email}"
      else
        flash[:error] = "#{params[:email]} does not exist"
      end
      redirect_to(root_path)
    end
  end

  # Reset the password if the reset_code is found and delete it once the password has been
  # submitted.
  def reset
    @title = "Reset your password"
    @user = User.find_by_reset_code(params[:user][:reset_code]) unless params[:user][:reset_code].nil?
    if request.put?
      if @user.update_attributes(:password => params[:user][:password],
                                 :password_confirmation => params[:user][:password_confirmation])
        @user.activate
        flash[:notice] = "Password reset successfully for #{@user.email}"
        # Sign in user automatically after changin the password
        sign_in @user
        redirect_to(root_path)
      else

        render :action => :reset
      end
    end
  end

private

  def correct_user
    @user = User.find(params[:id])
    redirect_to(root_path) unless current_user?(@user)
  end

  def admin_user
    redirect_to(root_path) unless current_user.admin?
  end

  def redirect_signed_in
    if signed_in?
      redirect_to(root_path)
    end
  end

end
