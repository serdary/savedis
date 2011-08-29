require 'test_helper'

class SessionsControllerTest < ActionController::TestCase
  test "should get new" do
    get :new
    assert_response :success
  end
  
  test "user should login" do
    user1 = users(:user1)
    
    post :create, :username => user1.username, :password => 'MyString'
    assert_redirected_to root_url
    assert_equal user1.id, session[:user_id]
  end
  
  test "user should be redirected to login" do
    user1 = users(:user1)
    
    post :create, :username => user1.username, :password => 'wrongcombination'
    assert_redirected_to login_url
  end
end
