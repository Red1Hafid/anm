require "test_helper"

class AutorizationsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @autorization = autorizations(:one)
  end

  test "should get index" do
    get autorizations_url
    assert_response :success
  end

  test "should get new" do
    get new_autorization_url
    assert_response :success
  end

  test "should create autorization" do
    assert_difference("Autorization.count") do
      post autorizations_url, params: { autorization: { comment: @autorization.comment, date: @autorization.date, end_hour: @autorization.end_hour, start_hour: @autorization.start_hour, user_id: @autorization.user_id } }
    end

    assert_redirected_to autorization_url(Autorization.last)
  end

  test "should show autorization" do
    get autorization_url(@autorization)
    assert_response :success
  end

  test "should get edit" do
    get edit_autorization_url(@autorization)
    assert_response :success
  end

  test "should update autorization" do
    patch autorization_url(@autorization), params: { autorization: { comment: @autorization.comment, date: @autorization.date, end_hour: @autorization.end_hour, start_hour: @autorization.start_hour, user_id: @autorization.user_id } }
    assert_redirected_to autorization_url(@autorization)
  end

  test "should destroy autorization" do
    assert_difference("Autorization.count", -1) do
      delete autorization_url(@autorization)
    end

    assert_redirected_to autorizations_url
  end
end
