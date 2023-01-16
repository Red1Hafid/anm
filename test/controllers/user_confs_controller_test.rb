require "test_helper"

class UserConfsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user_conf = user_confs(:one)
  end

  test "should get index" do
    get user_confs_url
    assert_response :success
  end

  test "should get new" do
    get new_user_conf_url
    assert_response :success
  end

  test "should create user_conf" do
    assert_difference("UserConf.count") do
      post user_confs_url, params: { user_conf: { ref: @user_conf.ref, user_id: @user_conf.user_id } }
    end

    assert_redirected_to user_conf_url(UserConf.last)
  end

  test "should show user_conf" do
    get user_conf_url(@user_conf)
    assert_response :success
  end

  test "should get edit" do
    get edit_user_conf_url(@user_conf)
    assert_response :success
  end

  test "should update user_conf" do
    patch user_conf_url(@user_conf), params: { user_conf: { ref: @user_conf.ref, user_id: @user_conf.user_id } }
    assert_redirected_to user_conf_url(@user_conf)
  end

  test "should destroy user_conf" do
    assert_difference("UserConf.count", -1) do
      delete user_conf_url(@user_conf)
    end

    assert_redirected_to user_confs_url
  end
end
