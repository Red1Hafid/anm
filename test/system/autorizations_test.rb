require "application_system_test_case"

class AutorizationsTest < ApplicationSystemTestCase
  setup do
    @autorization = autorizations(:one)
  end

  test "visiting the index" do
    visit autorizations_url
    assert_selector "h1", text: "Autorizations"
  end

  test "should create autorization" do
    visit autorizations_url
    click_on "New autorization"

    fill_in "Comment", with: @autorization.comment
    fill_in "Date", with: @autorization.date
    fill_in "End hour", with: @autorization.end_hour
    fill_in "Start hour", with: @autorization.start_hour
    fill_in "User", with: @autorization.user_id
    click_on "Create Autorization"

    assert_text "Autorization was successfully created"
    click_on "Back"
  end

  test "should update Autorization" do
    visit autorization_url(@autorization)
    click_on "Edit this autorization", match: :first

    fill_in "Comment", with: @autorization.comment
    fill_in "Date", with: @autorization.date
    fill_in "End hour", with: @autorization.end_hour
    fill_in "Start hour", with: @autorization.start_hour
    fill_in "User", with: @autorization.user_id
    click_on "Update Autorization"

    assert_text "Autorization was successfully updated"
    click_on "Back"
  end

  test "should destroy Autorization" do
    visit autorization_url(@autorization)
    click_on "Destroy this autorization", match: :first

    assert_text "Autorization was successfully destroyed"
  end
end
