require "application_system_test_case"

class FormationsTest < ApplicationSystemTestCase
  setup do
    @formation = formations(:one)
  end

  test "visiting the index" do
    visit formations_url
    assert_selector "h1", text: "Formations"
  end

  test "should create formation" do
    visit formations_url
    click_on "New formation"

    fill_in "Description", with: @formation.description
    fill_in "End date", with: @formation.end_date
    fill_in "Formation type", with: @formation.formation_type_id
    fill_in "Start date", with: @formation.start_date
    fill_in "Total hour", with: @formation.total_hour
    fill_in "User", with: @formation.user_id
    click_on "Create Formation"

    assert_text "Formation was successfully created"
    click_on "Back"
  end

  test "should update Formation" do
    visit formation_url(@formation)
    click_on "Edit this formation", match: :first

    fill_in "Description", with: @formation.description
    fill_in "End date", with: @formation.end_date
    fill_in "Formation type", with: @formation.formation_type_id
    fill_in "Start date", with: @formation.start_date
    fill_in "Total hour", with: @formation.total_hour
    fill_in "User", with: @formation.user_id
    click_on "Update Formation"

    assert_text "Formation was successfully updated"
    click_on "Back"
  end

  test "should destroy Formation" do
    visit formation_url(@formation)
    click_on "Destroy this formation", match: :first

    assert_text "Formation was successfully destroyed"
  end
end
