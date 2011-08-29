require 'test_helper'

class AjaxControllerTest < ActionController::TestCase
  test "should get notes" do
    get :notes
    assert_response :success
  end

end
