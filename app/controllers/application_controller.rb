class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  include SessionsHelper

  def hello
    render html: "hello world!"
  end

  def logged_in_user

      unless logged_in?      #checking only whether user logged in or not is not enough,
                              #this only fix access to non logged users to edit and update
        store_location
        flash[:danger] = "Please log in."
        redirect_to login_url
      end
  end

end
