require 'test_helper'

class UsersSignupTest < ActionDispatch::IntegrationTest
  # test "the truth" do
  #   assert true
  # end

  test "invalid signup information" do
    get signup_path
    assert_no_difference 'User.count' do
      post users_path,  user: { name:  "kucds",
                                         email: "user@invalid.com",
                                         password:              "foo",
                                         password_confirmation: "bar" }
    end
    assert_template 'users/new'
  end

  test "valid signup information" do
    get signup_path
    assert_difference 'User.count', 1 do
      post users_path, user: { name:  "Example User",
                                         email: "user@example.com",
                                         password:              "password",
                                         password_confirmation: "password" }
    end
    follow_redirect!

    #COmmented temporary
    #assert_template 'users/show'
    #assert is_logged_in?
  end
end
