require "application_system_test_case"

class UserConfsTest < ApplicationSystemTestCase
  setup do
    @user_conf = user_confs(:one)
  end

  test "visiting the index" do
    visit user_confs_url
    assert_selector "h1", text: "User confs"
  end

  test "should create user conf" do
    visit user_confs_url
    click_on "New user conf"

    fill_in "Ref", with: @user_conf.ref
    fill_in "User", with: @user_conf.user_id
    click_on "Create User conf"

    assert_text "User conf was successfully created"
    click_on "Back"
  end

  test "should update User conf" do
    visit user_conf_url(@user_conf)
    click_on "Edit this user conf", match: :first

    fill_in "Ref", with: @user_conf.ref
    fill_in "User", with: @user_conf.user_id
    click_on "Update User conf"

    assert_text "User conf was successfully updated"
    click_on "Back"
  end

  test "should destroy User conf" do
    visit user_conf_url(@user_conf)
    click_on "Destroy this user conf", match: :first

    assert_text "User conf was successfully destroyed"
  end
end
