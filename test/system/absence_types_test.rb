require "application_system_test_case"

class AbsenceTypesTest < ApplicationSystemTestCase
  setup do
    @absence_type = absence_types(:one)
  end

  test "visiting the index" do
    visit absence_types_url
    assert_selector "h1", text: "Absence types"
  end

  test "should create absence type" do
    visit absence_types_url
    click_on "New absence type"

    fill_in "Code", with: @absence_type.code
    fill_in "Name", with: @absence_type.name
    click_on "Create Absence type"

    assert_text "Absence type was successfully created"
    click_on "Back"
  end

  test "should update Absence type" do
    visit absence_type_url(@absence_type)
    click_on "Edit this absence type", match: :first

    fill_in "Code", with: @absence_type.code
    fill_in "Name", with: @absence_type.name
    click_on "Update Absence type"

    assert_text "Absence type was successfully updated"
    click_on "Back"
  end

  test "should destroy Absence type" do
    visit absence_type_url(@absence_type)
    click_on "Destroy this absence type", match: :first

    assert_text "Absence type was successfully destroyed"
  end
end
