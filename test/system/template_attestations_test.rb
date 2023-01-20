require "application_system_test_case"

class TemplateAttestationsTest < ApplicationSystemTestCase
  setup do
    @template_attestation = template_attestations(:one)
  end

  test "visiting the index" do
    visit template_attestations_url
    assert_selector "h1", text: "Template attestations"
  end

  test "should create template attestation" do
    visit template_attestations_url
    click_on "New template attestation"

    fill_in "Code", with: @template_attestation.code
    fill_in "Name", with: @template_attestation.name
    click_on "Create Template attestation"

    assert_text "Template attestation was successfully created"
    click_on "Back"
  end

  test "should update Template attestation" do
    visit template_attestation_url(@template_attestation)
    click_on "Edit this template attestation", match: :first

    fill_in "Code", with: @template_attestation.code
    fill_in "Name", with: @template_attestation.name
    click_on "Update Template attestation"

    assert_text "Template attestation was successfully updated"
    click_on "Back"
  end

  test "should destroy Template attestation" do
    visit template_attestation_url(@template_attestation)
    click_on "Destroy this template attestation", match: :first

    assert_text "Template attestation was successfully destroyed"
  end
end
