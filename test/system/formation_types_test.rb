require "application_system_test_case"

class FormationTypesTest < ApplicationSystemTestCase
  setup do
    @formation_type = formation_types(:one)
  end

  test "visiting the index" do
    visit formation_types_url
    assert_selector "h1", text: "Formation types"
  end

  test "should create formation type" do
    visit formation_types_url
    click_on "New formation type"

    fill_in "Code", with: @formation_type.code
    fill_in "Description", with: @formation_type.description
    click_on "Create Formation type"

    assert_text "Formation type was successfully created"
    click_on "Back"
  end

  test "should update Formation type" do
    visit formation_type_url(@formation_type)
    click_on "Edit this formation type", match: :first

    fill_in "Code", with: @formation_type.code
    fill_in "Description", with: @formation_type.description
    click_on "Update Formation type"

    assert_text "Formation type was successfully updated"
    click_on "Back"
  end

  test "should destroy Formation type" do
    visit formation_type_url(@formation_type)
    click_on "Destroy this formation type", match: :first

    assert_text "Formation type was successfully destroyed"
  end
end
