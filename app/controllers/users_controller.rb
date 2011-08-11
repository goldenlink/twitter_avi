class UsersController < ApplicationController

  before_filter :authenticate, :except => [:show, :new, :create]
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
    @title = "Following"
    @user = User.find(params[:id])
    @users = @user.following.paginate(:page => params[:page])
    render 'show_follow'
  end

  def followers
    @title = "Followers"
    @user = User.find(params[:id])
    @users = @user.followers.paginate(:page => params[:page])
    render 'show_follow'
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
