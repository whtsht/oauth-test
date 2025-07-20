require "test_helper"

class UsersControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    post session_url, params: { email_address: @user.email_address, password: "password" }
  end

  test "should get edit" do
    get edit_user_url
    assert_response :success
  end

  test "should get update" do
    patch user_url, params: { user: { name: "Updated Name" } }
    assert_redirected_to edit_user_url
  end
end
