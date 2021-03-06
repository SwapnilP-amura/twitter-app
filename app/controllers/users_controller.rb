class UsersController < ApplicationController

  before_action :logged_in_user, only: [:edit, :update,:index,:destroy,:following, :followers]
  before_action :correct_user,   only: [:edit, :update]
  before_action :admin_user,     only: :destroy

  def index
      @users = User.paginate(page: params[:page])
  end


  def correct_user
     @user = User.find(params[:id])
     redirect_to(root_url) unless current_user?(@user)
  end

  # def logged_in_user
  #     unless logged_in?      #checking only whether user logged in or not is not enough,
  #                             #this only fix access to non logged users to edit and update
  #       store_location
  #       flash[:danger] = "Please log in."
  #       redirect_to login_url
  #     end
  # end
  #Moved to ApplicationController

  def new
    @user=User.new
  end

  def show
    @user=User.find(params[:id])
    @microposts = @user.microposts.paginate(page: params[:page])
    #this displays posts of user only on his profile page
    #page visisted by other user.
  end

  def create
    @user=User.new(user_params)
    if @user.save
      # Handle a successful save.
      #temporary activation digest is alsos saved to database

      #Account Activation
      @user.send_activation_email
      flash[:info] = "Please check your email to activate your account."
      redirect_to root_url

      #Normal Login after Signup
      #DOnt log in Directly without activation email.
      # log_in @user
      # flash[:success] = "Welcome to the Sample App!"        #setting flash for success message
      # redirect_to @user
    else
      render 'new'
      #redirect_to signup_path
    end
  end

  def edit
    @user=User.find(params[:id])
  end

  def update
    @user = User.find(params[:id])
    if @user.update_attributes(user_params)
      # Handle a successful update.
      flash[:success] = "Profile updated"
      redirect_to @user
    else
      render 'edit'
    end
  end

  def destroy
    User.find(params[:id]).destroy
    flash[:success] = "User deleted"
    redirect_to users_url
  end

  def following
    @title = "Following"
    @user  = User.find(params[:id])
    @users = @user.following.paginate(page: params[:page])
    render 'show_follow'
  end

  def followers
    @title = "Followers"
    @user  = User.find(params[:id])
    @users = @user.followers.paginate(page: params[:page])
    render 'show_follow'
  end

  private

    def user_params
      params.require(:user).permit(:name, :email, :password,
                                   :password_confirmation)
    end

    def admin_user
      redirect_to(root_url) unless current_user.admin?
    end
    #if not admin and destroy request is received redirect
end
