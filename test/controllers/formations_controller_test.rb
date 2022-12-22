require "test_helper"

class FormationsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @formation = formations(:one)
  end

  test "should get index" do
    get formations_url
    assert_response :success
  end

  test "should get new" do
    get new_formation_url
    assert_response :success
  end

  test "should create formation" do
    assert_difference("Formation.count") do
      post formations_url, params: { formation: { description: @formation.description, end_date: @formation.end_date, formation_type_id: @formation.formation_type_id, start_date: @formation.start_date, total_hour: @formation.total_hour, user_id: @formation.user_id } }
    end

    assert_redirected_to formation_url(Formation.last)
  end

  test "should show formation" do
    get formation_url(@formation)
    assert_response :success
  end

  test "should get edit" do
    get edit_formation_url(@formation)
    assert_response :success
  end

  test "should update formation" do
    patch formation_url(@formation), params: { formation: { description: @formation.description, end_date: @formation.end_date, formation_type_id: @formation.formation_type_id, start_date: @formation.start_date, total_hour: @formation.total_hour, user_id: @formation.user_id } }
    assert_redirected_to formation_url(@formation)
  end

  test "should destroy formation" do
    assert_difference("Formation.count", -1) do
      delete formation_url(@formation)
    end

    assert_redirected_to formations_url
  end
end
