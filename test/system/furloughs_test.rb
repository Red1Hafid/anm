require "application_system_test_case"

class FurloughsTest < ApplicationSystemTestCase
  setup do
    @furlough = furloughs(:one)
  end

  test "visiting the index" do
    visit furloughs_url
    assert_selector "h1", text: "Furloughs"
  end

  test "should create furlough" do
    visit furloughs_url
    click_on "New furlough"

    fill_in "Color", with: @furlough.color
    fill_in "Description", with: @furlough.description
    fill_in "End", with: @furlough.end
    fill_in "Start", with: @furlough.start
    fill_in "Status", with: @furlough.status
    fill_in "Title", with: @furlough.title
    fill_in "User", with: @furlough.user_id
    click_on "Create Furlough"

    assert_text "Furlough was successfully created"
    click_on "Back"
  end

  test "should update Furlough" do
    visit furlough_url(@furlough)
    click_on "Edit this furlough", match: :first

    fill_in "Color", with: @furlough.color
    fill_in "Description", with: @furlough.description
    fill_in "End", with: @furlough.end
    fill_in "Start", with: @furlough.start
    fill_in "Status", with: @furlough.status
    fill_in "Title", with: @furlough.title
    fill_in "User", with: @furlough.user_id
    click_on "Update Furlough"

    assert_text "Furlough was successfully updated"
    click_on "Back"
  end

  test "should destroy Furlough" do
    visit furlough_url(@furlough)
    click_on "Destroy this furlough", match: :first

    assert_text "Furlough was successfully destroyed"
  end
end
