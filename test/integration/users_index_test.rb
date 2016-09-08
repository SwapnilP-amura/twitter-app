require 'test_helper'

class UsersIndexTest < ActionDispatch::IntegrationTest
  # test "the truth" do
  #   assert true
  # end

  test "should redirect index when not logged in" do
    get users_path
    assert_redirected_to login_url
  end

end
