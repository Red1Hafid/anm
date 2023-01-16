require "test_helper"

class CertificateRequestsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @certificate_request = certificate_requests(:one)
  end

  test "should get index" do
    get certificate_requests_url
    assert_response :success
  end

  test "should get new" do
    get new_certificate_request_url
    assert_response :success
  end

  test "should create certificate_request" do
    assert_difference("CertificateRequest.count") do
      post certificate_requests_url, params: { certificate_request: { template_attestation_id: @certificate_request.template_attestation_id, user_id: @certificate_request.user_id } }
    end

    assert_redirected_to certificate_request_url(CertificateRequest.last)
  end

  test "should show certificate_request" do
    get certificate_request_url(@certificate_request)
    assert_response :success
  end

  test "should get edit" do
    get edit_certificate_request_url(@certificate_request)
    assert_response :success
  end

  test "should update certificate_request" do
    patch certificate_request_url(@certificate_request), params: { certificate_request: { template_attestation_id: @certificate_request.template_attestation_id, user_id: @certificate_request.user_id } }
    assert_redirected_to certificate_request_url(@certificate_request)
  end

  test "should destroy certificate_request" do
    assert_difference("CertificateRequest.count", -1) do
      delete certificate_request_url(@certificate_request)
    end

    assert_redirected_to certificate_requests_url
  end
end
