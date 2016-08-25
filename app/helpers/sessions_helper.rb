module SessionsHelper

  def log_in(user)
    session[:user_id] = user.id
    #this session is session method of rails
    #not session hash in params
    #treat it like a hash.
  end

  def current_user
    #@current_user ||= User.find_by(id: session[:user_id])
    #because everytime call to current user shouldnt hit databse
    if (user_id = session[:user_id])
        @current_user ||= User.find_by(id: user_id)
        #if temporary session exists ,tertieve from it
    elsif (user_id = cookies.signed[:user_id])
        user = User.find_by(id: user_id)
        #if persistent session ,then check authenticity of remember_token
        if user && user.authenticated?(cookies[:remember_token])
          log_in user
          @current_user = user
        end
    end
      #eotherwise current_user returns nil
  end

  def remember(user)
      user.remember                 #genrate random token and save its digest to database
      cookies.permanent.signed[:user_id] = user.id    #save enc(id) to cookies
      cookies.permanent[:remember_token] = user.remember_token    #save "plain text" genrated token in cookies
  end

  def logged_in?
    !current_user.nil?
  end

  def log_out
    session.delete(:user_id)
    #set current user to nil [important]
    @current_user = nil
  end

end
