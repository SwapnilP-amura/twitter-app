class StaticPagesController < ApplicationController
  def help
  end

  def home
    #home page should display form to create new page
    #and a feeds from all people being followed.
    if logged_in?
      @micropost = current_user.microposts.build
      @feed_items=current_user.feed.paginate(page: params[:page])

      #user.feed returns list of all posts.
      #pagination is applied on it.
    end
  end

  def about
  end

  def contact
  end
end
