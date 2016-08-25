module SessionsHelper

  def log_in(user)
    session[:user_id] = user.id
    #this session is session method of rails
    #not session hash in params
    #treat it like a hash.
  end

  def current_user
    @current_user ||= User.find_by(id: session[:user_id])
  end

  def logged_in?
    !current_user.nil?
  end

end
