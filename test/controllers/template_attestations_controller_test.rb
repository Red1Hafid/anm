require "test_helper"

class TemplateAttestationsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @template_attestation = template_attestations(:one)
  end

  test "should get index" do
    get template_attestations_url
    assert_response :success
  end

  test "should get new" do
    get new_template_attestation_url
    assert_response :success
  end

  test "should create template_attestation" do
    assert_difference("TemplateAttestation.count") do
      post template_attestations_url, params: { template_attestation: { code: @template_attestation.code, name: @template_attestation.name } }
    end

    assert_redirected_to template_attestation_url(TemplateAttestation.last)
  end

  test "should show template_attestation" do
    get template_attestation_url(@template_attestation)
    assert_response :success
  end

  test "should get edit" do
    get edit_template_attestation_url(@template_attestation)
    assert_response :success
  end

  test "should update template_attestation" do
    patch template_attestation_url(@template_attestation), params: { template_attestation: { code: @template_attestation.code, name: @template_attestation.name } }
    assert_redirected_to template_attestation_url(@template_attestation)
  end

  test "should destroy template_attestation" do
    assert_difference("TemplateAttestation.count", -1) do
      delete template_attestation_url(@template_attestation)
    end

    assert_redirected_to template_attestations_url
  end
end
