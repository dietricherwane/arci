require 'test_helper'

class BooksControllerTest < ActionController::TestCase
  test "should get codes" do
    get :codes
    assert_response :success
  end

  test "should get generate_code" do
    get :generate_code
    assert_response :success
  end

end
