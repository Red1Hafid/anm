require "test_helper"

class FormationTypesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @formation_type = formation_types(:one)
  end

  test "should get index" do
    get formation_types_url
    assert_response :success
  end

  test "should get new" do
    get new_formation_type_url
    assert_response :success
  end

  test "should create formation_type" do
    assert_difference("FormationType.count") do
      post formation_types_url, params: { formation_type: { code: @formation_type.code, description: @formation_type.description } }
    end

    assert_redirected_to formation_type_url(FormationType.last)
  end

  test "should show formation_type" do
    get formation_type_url(@formation_type)
    assert_response :success
  end

  test "should get edit" do
    get edit_formation_type_url(@formation_type)
    assert_response :success
  end

  test "should update formation_type" do
    patch formation_type_url(@formation_type), params: { formation_type: { code: @formation_type.code, description: @formation_type.description } }
    assert_redirected_to formation_type_url(@formation_type)
  end

  test "should destroy formation_type" do
    assert_difference("FormationType.count", -1) do
      delete formation_type_url(@formation_type)
    end

    assert_redirected_to formation_types_url
  end
end
