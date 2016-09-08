require 'test_helper'

class UsersControllerTest < ActionController::TestCase

  def setup
   @user = users(:michael)
  end

  test "should get new" do
    get :new                                      #get take action  not route
    assert_response :success
  end




end
