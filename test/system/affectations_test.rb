require "application_system_test_case"

class AffectationsTest < ApplicationSystemTestCase
  setup do
    @affectation = affectations(:one)
  end

  test "visiting the index" do
    visit affectations_url
    assert_selector "h1", text: "Affectations"
  end

  test "should create affectation" do
    visit affectations_url
    click_on "New affectation"

    click_on "Create Affectation"

    assert_text "Affectation was successfully created"
    click_on "Back"
  end

  test "should update Affectation" do
    visit affectation_url(@affectation)
    click_on "Edit this affectation", match: :first

    click_on "Update Affectation"

    assert_text "Affectation was successfully updated"
    click_on "Back"
  end

  test "should destroy Affectation" do
    visit affectation_url(@affectation)
    click_on "Destroy this affectation", match: :first

    assert_text "Affectation was successfully destroyed"
  end
end
