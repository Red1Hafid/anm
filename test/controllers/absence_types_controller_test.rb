require "test_helper"

class AbsenceTypesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @absence_type = absence_types(:one)
  end

  test "should get index" do
    get absence_types_url
    assert_response :success
  end

  test "should get new" do
    get new_absence_type_url
    assert_response :success
  end

  test "should create absence_type" do
    assert_difference("AbsenceType.count") do
      post absence_types_url, params: { absence_type: { code: @absence_type.code, name: @absence_type.name } }
    end

    assert_redirected_to absence_type_url(AbsenceType.last)
  end

  test "should show absence_type" do
    get absence_type_url(@absence_type)
    assert_response :success
  end

  test "should get edit" do
    get edit_absence_type_url(@absence_type)
    assert_response :success
  end

  test "should update absence_type" do
    patch absence_type_url(@absence_type), params: { absence_type: { code: @absence_type.code, name: @absence_type.name } }
    assert_redirected_to absence_type_url(@absence_type)
  end

  test "should destroy absence_type" do
    assert_difference("AbsenceType.count", -1) do
      delete absence_type_url(@absence_type)
    end

    assert_redirected_to absence_types_url
  end
end
