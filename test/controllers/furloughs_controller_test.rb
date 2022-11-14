require "test_helper"

class FurloughsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @furlough = furloughs(:one)
  end

  test "should get index" do
    get furloughs_url
    assert_response :success
  end

  test "should get new" do
    get new_furlough_url
    assert_response :success
  end

  test "should create furlough" do
    assert_difference("Furlough.count") do
      post furloughs_url, params: { furlough: { color: @furlough.color, description: @furlough.description, end: @furlough.end, start: @furlough.start, status: @furlough.status, title: @furlough.title, user_id: @furlough.user_id } }
    end

    assert_redirected_to furlough_url(Furlough.last)
  end

  test "should show furlough" do
    get furlough_url(@furlough)
    assert_response :success
  end

  test "should get edit" do
    get edit_furlough_url(@furlough)
    assert_response :success
  end

  test "should update furlough" do
    patch furlough_url(@furlough), params: { furlough: { color: @furlough.color, description: @furlough.description, end: @furlough.end, start: @furlough.start, status: @furlough.status, title: @furlough.title, user_id: @furlough.user_id } }
    assert_redirected_to furlough_url(@furlough)
  end

  test "should destroy furlough" do
    assert_difference("Furlough.count", -1) do
      delete furlough_url(@furlough)
    end

    assert_redirected_to furloughs_url
  end
end
