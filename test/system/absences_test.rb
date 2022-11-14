require "application_system_test_case"

class AbsencesTest < ApplicationSystemTestCase
  setup do
    @absence = absences(:one)
  end

  test "visiting the index" do
    visit absences_url
    assert_selector "h1", text: "Absences"
  end

  test "should create absence" do
    visit absences_url
    click_on "New absence"

    fill_in "Absence type", with: @absence.absence_type_id
    fill_in "End date", with: @absence.end_date
    fill_in "Start date", with: @absence.start_date
    fill_in "User", with: @absence.user_id
    click_on "Create Absence"

    assert_text "Absence was successfully created"
    click_on "Back"
  end

  test "should update Absence" do
    visit absence_url(@absence)
    click_on "Edit this absence", match: :first

    fill_in "Absence type", with: @absence.absence_type_id
    fill_in "End date", with: @absence.end_date
    fill_in "Start date", with: @absence.start_date
    fill_in "User", with: @absence.user_id
    click_on "Update Absence"

    assert_text "Absence was successfully updated"
    click_on "Back"
  end

  test "should destroy Absence" do
    visit absence_url(@absence)
    click_on "Destroy this absence", match: :first

    assert_text "Absence was successfully destroyed"
  end
end
