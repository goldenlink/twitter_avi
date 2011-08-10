class MicropostsController < ApplicationController

  before_filter :authenticate
  before_filter :authorize_user, :only => :destroy

  def create
    @micropost = current_user.microposts.build(params[:micropost])
    if @micropost.save
      flash[:success] = "Micropost created!"
      redirect_to root_path
    else
      @feed_items = []
      render 'pages/home'
    end
  end

  def destroy
    @micropost.destroy
    redirect_back_or root_path
  end

  def index
    @title = "All microposts"
    @microposts = Micropost.find_all_by_user_id(params[:user_id])
  end

private
  
  def authorize_user
    @micropost = Micropost.find(params[:id])
    redirect_to root_path unless current_user?(@micropost.user)
  end

end
