module SessionsHelper

  def log_in(user)
    session[:user_id] = user.id
    #this session is session method of rails
    #not session hash in params
    #treat it like a hash.
  end

  def current_user
    @current_user ||= User.find_by(id: session[:user_id])
    #because everytime call to current user shouldnt hit databse

  end


  def logged_in?
    !current_user.nil?
  end

  def log_out
    session.delete(:user_id)
    #set current user to nil important
    @current_user = nil
  end

end
