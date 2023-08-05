require "test_helper"

class Api::V1::BookControllerTest < ActionDispatch::IntegrationTest
  test "should get ask" do
    get api_v1_book_ask_url
    assert_response :success
  end
end
