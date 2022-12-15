require "application_system_test_case"

class CertificateRequestsTest < ApplicationSystemTestCase
  setup do
    @certificate_request = certificate_requests(:one)
  end

  test "visiting the index" do
    visit certificate_requests_url
    assert_selector "h1", text: "Certificate requests"
  end

  test "should create certificate request" do
    visit certificate_requests_url
    click_on "New certificate request"

    fill_in "Template attestation", with: @certificate_request.template_attestation_id
    fill_in "User", with: @certificate_request.user_id
    click_on "Create Certificate request"

    assert_text "Certificate request was successfully created"
    click_on "Back"
  end

  test "should update Certificate request" do
    visit certificate_request_url(@certificate_request)
    click_on "Edit this certificate request", match: :first

    fill_in "Template attestation", with: @certificate_request.template_attestation_id
    fill_in "User", with: @certificate_request.user_id
    click_on "Update Certificate request"

    assert_text "Certificate request was successfully updated"
    click_on "Back"
  end

  test "should destroy Certificate request" do
    visit certificate_request_url(@certificate_request)
    click_on "Destroy this certificate request", match: :first

    assert_text "Certificate request was successfully destroyed"
  end
end
