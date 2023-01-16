require "test_helper"

class CostsControllerTest < ActionDispatch::IntegrationTest
  test "should get name:string" do
    get costs_name:string_url
    assert_response :success
  end
end
