module SessionsHelper

  def log_in(user)
    session[:user_id] = user.id
    #this session is session method of rails
    #not session hash in params
  end

end
